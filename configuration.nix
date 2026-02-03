# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
#let
#autoSamba = pkgs.writeText "auto.samba" ''
#sambamnt -fstype=cifs,rw,soft,_netdev,vers=3.1.1,credentials=/home/py/smb-credentials,iocharset=utf8,noserverino,cache=none,actimeo=30 ://192.168.2.1/myfiles
#'';
let
  #compiledLayout = pkgs.runCommand "keyboard-layout" {} ''
  #${pkgs.xorg.xkbcomp}/bin/xkbcomp ${./path/to/layout.xkb} $out
  #'';
  #in
  customKeyboardLayout = pkgs.writeText "custom-keyboard-layout" ''
    xkb_keymap {
      xkb_keycodes  { include "evdev+aliases(qwerty)"	};
      xkb_types     { include "complete"	};
      xkb_compat    { include "complete"	};
        partial
        xkb_symbols "swap" {
            include "pc+us+inet(evdev)+altwin(ctrl_win)"
            replace key <RTRN> { [ backslash, bar ] };
            replace key <BKSL> { [ Return, Return ] };
            replace key <LSGT> { [ Shift_L, Super_L ] };
          };
      };
  '';

  # Help catch errors in the custom keyboard layout at build time

  compiledKeyboardLayout = pkgs.runCommand "compiled-keyboard-layout" { } ''
    ${pkgs.xorg.xkbcomp}/bin/xkbcomp ${customKeyboardLayout} $out
  '';
in

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  nix.settings.substituters = [
    "https://mirror.sjtu.edu.cn/nix-channels/store"
    "https://mirrors.ustc.edu.cn/nix-channels/store"
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
  ];
  #nix.settings.substituters = lib.mkBefore [ "https://mirror.sjtu.edu.cn/nix-channels/store" "https://mirrors.ustc.edu.cn/nix-channels/store" "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" ];
  #systemd.extraConfig = "DefaultLimitNOFILE=4096";

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 50d";
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  #boot.extraModprobeConfig = ''
  #options hid_apple fnmode=1
  #'';

  boot.kernelModules = [
    "tun"
    "cifs"
    "kvm-intel"
    "wl"
    "brcmfmac"
    "i2c-dev"
  ];
  boot.blacklistedKernelModules = [
    "b43"
    "ssb"
    "brcmfmac"
    "brcmsmac"
    "bcma"
  ];
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  hardware.enableRedistributableFirmware = true;
  nixpkgs.config.permittedInsecurePackages = [
    "broadcom-sta-6.30.223.271-59-6.12.68"
  ];

  # options: https://www.freedesktop.org/software/systemd/man/latest/logind.conf.html
  # options: https://github.com/NixOS/nixpkgs/blob/nixos-25.11/nixos/modules/system/boot/systemd/logind.nix
  services.logind.settings.Login = {
    HandlePowerKey = "suspend";
    HandlePowerKeyLongPress = "reboot";
    HandleLidSwitch = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  boot.kernelParams = [
    "mem_sleep_default=s2idle"
    "sleep.deep=disabled"
    "usbcore.autosuspend=1"
    #"vt.handoff=0"
    #"acpi_sleep=s3_bios"
    #"acpi_osi=Darwin"
    #"acpi_sleep=nonvs"
    #"acpi_osi=!Darwin"
    #"acpi_osi=\"Windows 2015\""
  ];
  systemd.sleep.extraConfig = ''
    [Sleep]
    AllowSuspend=yes
    AllowHibernation=no
    AllowSuspendThenHibernate=no
    HibernateDelaySec=3h
  '';

  #systemd.services.disable-wakeups = {
  #description = "Disable unwanted wakeup sources";
  #wantedBy = [ "multi-user.target" ];
  #serviceConfig = {
  #Type = "oneshot";
  #ExecStart = pkgs.writeShellScript "disable-wakeups" ''
  #echo XHC1 > /proc/acpi/wakeup
  #echo LID0 > /proc/acpi/wakeup
  #echo RP01 > /proc/acpi/wakeup
  #echo RP02 > /proc/acpi/wakeup
  #echo RP03 > /proc/acpi/wakeup
  #echo RP05 > /proc/acpi/wakeup
  #echo RP06 > /proc/acpi/wakeup
  #'';
  #User = "root";
  #};
  #};

  #systemd.services.disable-wakeup-devices = {
  #description = "Disable wakeup for LID0 and XHC1 to improve suspend stability";
  #wantedBy = [ "multi-user.target" ];
  #serviceConfig.ExecStart = ''
  #/run/current-system/sw/bin/bash -c '
  #for dev in LID0 XHC1; do
  #if grep -q "^$dev.*enabled" /proc/acpi/wakeup; then
  #echo "Disabling $dev wakeup..."
  #echo $dev > /proc/acpi/wakeup
  #fi
  #done
  #'
  #'';
  #};

  systemd.network = {
    enable = false;
    networks."eth0" = {
      matchConfig.Name = "eth0";
      networkConfig = {
        DHCP = "yes";
      };
    };
  };

  networking = {
    hostName = "nixos";
    wireless = {
      userControlled = true;
      enable = true; # Whether to enable wpa_supplicant.
      iwd = {
        enable = false;
        settings = {
          General = {
            EnableNetworkConfiguration = true;
          };
          Network = {
            EnableIPv6 = true;
            RoutePriorityOffset = 300;
          };
          Settings = {
            AutoConnect = true;
          };
        };
      };
    };
    networkmanager = {
      enable = true;
      #wifi.backend = "iwd";
      wifi.backend = "wpa_supplicant";
      #dns = "systemd-resolved";
    };

    #proxy = {
    #default = "http://192.168.124.8:10808/";
    ##noProxy = "127.0.0.1,localhost,internal.domain";
    #};

  };

  services.connman = {
    enable = false;
    wifi.backend = "wpa_supplicant";
    extraFlags = [
      "--nodnsproxy"
      #"--with-dns-backend=systemd-resolved"
    ];
  };

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-gtk
        qt6Packages.fcitx5-chinese-addons
        fcitx5-pinyin-zhwiki
        fcitx5-nord
        kdePackages.fcitx5-qt
        libsForQt5.fcitx5-qt
      ];
    };
  };
  #i18n.inputMethod = {
  #enable = true;
  #type = "ibus";
  #ibus.engines = with pkgs.ibus-engines; [ libpinyin ];
  ##type = "fcitx5";
  ##fcitx5.addons = with pkgs; [ fcitx5-chinese-addons ];
  #};

  #options = {
  #+    services.xserver.windowManager.fvwm3 = {
  #+      enable = mkEnableOption "Fvwm3 window manager";
  #+    };
  #+  };
  #services.xserver.windowManager.fvwm3.enable = true
  #services.xserver.desktopManager.default = "fvwm3";
  #services.xserver.desktopManager.session =
  #[ { manage = "desktop";
  #name = "fvwm3";
  #start =
  #''
  ##xmodmap ~/.Xmodmap
  #${pkgs.fvwm3}/bin/fvwm3 &
  #waitPID=$!
  #'';
  #}
  #];
  #services.xserver.displayManager.defaultSession = "fvwm3";
  #services.xserver.windowManager.fvwm3.enable = true;
  #services.xserver.displayManager.sessionCommands = "${pkgs.xorg.xkbcomp}/bin/xkbcomp ${customKeyboardLayout} $DISPLAY";

  services.seatd.enable = true;

  services.gnome.gnome-keyring.enable = true;
  programs.sway = {
    enable = false;
    wrapperFeatures.gtk = true;
  };

  programs.hyprland = {
    enable = true;
    withUWSM = true; # recommended for most users
    xwayland.enable = true; # Xwayland can be disabled.
  };

  programs.waybar.enable = true;

  programs.labwc = {
    enable = false;
  };

  #environment.sessionVariables = {
  ##QT_NO_PLASMA_INTEGRATION = "1";
  ##QT_STYLE_OVERRIDE = "Fusion";
  ##XMODIFIERS = "@im=fcitx";

  ##GTK_IM_MODULE = "fcitx";
  ##QT_IM_MODULE = "fcitx";
  ##QT_QPA_PLATFORM = "wayland";
  ##SDL_VIDEODRIVER = "wayland";
  ##XDG_SESSION_TYPE = "wayland";
  ##XDG_DATA_DIRS = "/run/current-system/sw/share:${pkgs.kdePackages.plasma-workspace}/share";

  ##QT_QPA_PLATFORMTHEME = "qt6ct";
  ##QT_PLATFORM_PLUGIN = "qt5ct" this two lines in session window
  #};

  #security.pam.services.ly.enableGnomeKeyring = true;
  #services.displayManager = {
  #autoLogin = {
  #enable = false;
  #user = "py";
  #};
  #ly = {
  #enable = true;
  ##sessions = [
  ##{
  ##name = "LXQt";
  ##start = "${pkgs.lxqt.lxqt-session}/bin/lxqt-session";
  ##}
  ##{
  ##name = "Hyprland";
  ##start = "${pkgs.hyprland}/bin/Hyprland";
  ##}
  ##];
  #};
  #};
  #services.xserver.displayManager.sessionPackages = [
  #pkgs.lxqt.lxqt-session # Adds LXQt session
  #pkgs.hyprland # Adds Hyprland session
  #];
  #services.displayManager.ly.configFile = pkgs.writeText "ly-config.ini" ''
  #[main]
  #wayland_cmd = Hyprland
  #tty = 2
  #'';

  services.haveged.enable = true;

  security.polkit.enable = true;

  services.dbus.enable = true;

  services.hypridle.enable = true;
  programs.hyprlock.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      kdePackages.xdg-desktop-portal-kde
      xdg-desktop-portal-hyprland
    ];
    lxqt.enable = true;
  };

  services.picom = {
    enable = false;
    backend = "xrender";
    #backend = "egl"; # Force GLX backend
    #vSync = true; # Enable vertical sync to reduce tearing

    #settings = {
    #glx-no-stencil = true;
    #glx-no-rebind-pixmap = true;
    #use-damage = true; # Critical for performance
    #glx-use-copysubbuffermesa = true;
    #xrender-sync = true;
    #xrender-sync-fence = true;
    #};
  };

  services.getty.autologinUser = "py";
  #systemd.services."getty@tty1" = {
  #enable = true;
  #wantedBy = [ "multi-user.target" ];
  ##overrideStrategy = "asDropin";
  ##serviceConfig.Restart = "always";
  #};
  services = {
    #displayManager = {
    #defaultSession = "lxqt-wayland";
    #};
    xserver = {
      # 47lines
      enable = true;
      autorun = false;
      displayManager = {
        startx.enable = true;
      };
      videoDrivers = [ "modesetting" ]; # Use modesetting instead of intel
      desktopManager = {
        lxqt.enable = true;
        xterm.enable = false;
      };
    };

    displayManager = {
      #autoLogin.user = "py";
      ly = {
        enable = false;
        x11Support = true;
        settings = {
          load = true;
          save = true;
        };
      };
    };

    greetd = {
      enable = true;
      settings = {
        initial_session = {
          command = "start-hyprland";
          user = "py";
        };
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd start-hyprland";
          user = "py";
        };
      };
    };

    #desktopManager = {
    #plasma6 = {
    #enable = true;
    #enableQt5Integration = false;
    #};
    #};

    #lightdm = {
    #enable = true;
    #greeters.slick = {
    #enable = true;
    #theme.name = "Zukitre-dark";
    #};
    #};
    #};
    #windowManager.icewm.enable = true;
    #windowManager.i3.enable = true;
    #xkb.layout = "us";
    #xkb.variant = "";
    #displayManager.sessionCommands = "xkbcomp dotfiles/mylayout.xkb $DISPLAY";
    #displayManager.sessionCommands = "${pkgs.xorg.xkbcomp}/bin/xkbcomp ${compiledLayout} $DISPLAY";
    #displayManager.sessionCommands =
    #${pkgs.xorg.xmodmap}/bin/xmodmap "${pkgs.writeText  "xkb-layout" ''
    #keycode 51 = Return
    #keycode 36 = backslash bar
    #''}"
    #xkb.extraLayouts.mylayout = {
    #description = "swap Return and Backslash";
    #languages   = [ "eng" ];
    #symbolsFile = /etc/nixos/dotfiles/mylayout;
    #};

    # Load custom keyboard layout on boot/resume
    #displayManager.sessionCommands = "sleep 8 && ${pkgs.xorg.xkbcomp}/bin/xkbcomp ${customKeyboardLayout} $DISPLAY";
    #displayManager.sessionCommands = "${pkgs.xorg.xkbcomp}/bin/xkbcomp ${customKeyboardLayout} $DISPLAY && xmodmap /etc/nixos/dotfiles/.Xmodmap";
    #displayManager.sessionCommands = "sleep 5 && xmodmap -e 'keycode 51 = Return'";
    #displayManager.sessionCommands = "sleep 5 && xkbcomp mylayout.xkb ${customKeyboardLayout} $DISPLAY";
    #displayManager.defaultSession = "cinnamon-wayland";
    #displayManager.sessionCommands = "xkbcomp ${customKeyboardLayout} $DISPLAY";
    #displayManager.sessionCommands = "xmodmap -e 'keycode 51 = Return'";

    #displayManager.sessionCommands =
    #${pkgs.xorg.xmodmap}/bin/xmodmap "${pkgs.writeText  "xkb-layout" ''
    #keycode 51 = Return
    #keycode 36 = backslash bar
    #''}"

    #displayManager.sessionCommands = "${pkgs.xorg.xkbcomp}/bin/xkbcomp ${customKeyboardLayout} $DISPLAY && /etc/profiles/per-user/py/bin/fusuma -d"; #use which to find out the path.
    #displayManager.sessionCommands = "iwctl adapter phy0 set-property Powered on && iwctl device eth0 set-property Powered on && /etc/profiles/per-user/py/bin/fusuma -d && /etc/profiles/per-user/py/bin/maestral start -f"; # use which to find out the path.
    #put to .xinitrc
  };

  #environment.sessionVariables = {
  #DISPLAY = ":0";
  #};
  #environment.variables = {
  #DISPLAY = ":0";
  #};

  # keycode https://www.toptal.com/developers/keycode

  #services.kmonad = {
  ## https://satler.dev/blog/nixos-kmonad-install/
  #enable = true;
  #keyboards = {
  #myKMonadOutput = {
  #name = "laptop-internal";
  ## sudo modprobe uinput line 102 tutorial
  #device = "/dev/input/by-id/usb-Apple_Inc._Apple_Internal_Keyboard___Trackpad_D3H5506WVQ1FTV3AT6KF-if01-event-kbd";
  ##device = "/dev/input/by-path/pci-0000:00:14.0-usb-0:5:1.1-event-kbd";
  #defcfg = {
  #enable = true;
  #fallthrough = true;
  #};
  #config = builtins.readFile dotfiles/conf.kbd;
  #};
  #};
  #};

  #services.kanata = {
  ## https://satler.dev/blog/nixos-kmonad-install/
  #enable = true;
  #keyboards = {
  #"internal" = {
  ##devices = [
  ##"/dev/input/by-id/usb-Apple_Inc._Apple_Internal_Keyboard___Trackpad_D3H5506WVQ1FTV3AT6KF-if01-event-kbd"
  ##];
  ##device = "/dev/input/by-path/pci-0000:00:14.0-usb-0:5:1.1-event-kbd";
  #config = builtins.readFile dotfiles/conf.kbd;
  #};
  #};
  #};

  hardware.uinput.enable = true;

  #systemd.user.services.libinput-gestures = {
  #description = "Libinput Gestures";
  #wantedBy = [ "graphical-session.target" ];
  ##partOf = [ "graphical-session.target" ];

  ## Make sure it starts after the graphical session has initialized
  #after = [ "graphical-session-pre.target" ];

  #serviceConfig = {
  ##ExecStart = "${pkgs.libinput-gestures}/bin/libinput-gestures";
  #ExecStart = "libinput-gestures";
  ##Restart = "always";
  ##RestartSec = 3;
  #Restart = "on-failure";
  #Type = "simple";
  #};
  #};

  #systemd.services.keyd = {
  #serviceConfig = {
  #CapabilityBoundingSet = [
  #"CAP_SETGID"
  #];
  #Group = "keyd";
  #User = "keyd";
  #};
  #};
  services.input-remapper.enable = true;
  security.sudo = {
    extraConfig = ''
      Defaults:py timestamp_timeout=60

      Defaults:py timestamp_type=global
    '';
    extraRules = [
      {
        users = [ "py" ];
        #options = [ "timestamp_timeout=30" ];
        commands = [
          {
            command = "${pkgs.systemd}/bin/systemctl stop keyd.service";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };
  services.keyd = {
    # 93
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings = {
          main = {
          };
        };
        extraConfig = ''
          leftmeta = layer(meta_mac)
          rightmeta = layer(meta_mac)
          [meta_mac:C]
          1 = A-1
          2 = A-2
          3 = A-3
          4 = A-4
          5 = A-5
          6 = A-6
          7 = A-7
          8 = A-8
          9 = A-9
          space = M-space
          backspace = delete
          # Copy
          c = C-insert
          # Paste
          v = S-insert
          # Cut
          x = S-delete

          q = M-q

          #p = M-p
          #n = M-n
          #h = M-h
          #b = M-b

          ## Move cursor to beginning of line
          #left = home
          ## Move cursor to end of Line
          #right = end
          left=A-left
          right=A-right
          up=A-up
          down=A-down
          # As soon as tab is pressed (but not yet released), we switch to the
          # "app_switch_state" overlay where we can handle Meta-Backtick differently.
          # Also, send a 'M-tab' key tap before entering app_switch_sate.
          tab = swapm(app_switch_state, M-tab)

          # Meta-Backtick: Switch to next window in the application group
          # - A-f6 is the default binding for 'cycle-group' in gnome
          # - keybinding: `gsettings get org.gnome.desktop.wm.keybindings cycle-group`
          ` = A-f6
          #tab = M-tab
          #` = M-S-tab # This makes Super+` cycle backwards, a common Mac-like behavior

          [meta_mac+control]
          #H = M-C-H
          #L = M-C-L
          3 = M-C-3
          4 = M-C-4

          # app_switch_state modifier layer; inherits from 'Meta' modifier layer
          [app_switch_state:M]

          # Meta-Tab: Switch to next application
          # - keybinding: `gsettings get org.gnome.desktop.wm.keybindings switch-applications`
          tab = M-tab
          right = M-tab

          # Meta-Backtick: Switch to previous application
          # - keybinding: `gsettings get org.gnome.desktop.wm.keybindings switch-applications-backward`
          ` = M-S-tab
          left = M-S-tab

          # https://github.com/canadaduane/my-nixos-conf/blob/main/system/keyd/keyd.conf#L80C1-L83C14
          #shift = layer(meta_mac_shift)
          #[meta_mac_shift:C-S]
          ## Highlight to beginning of line
          #left = S-home
          ## Highlight to end of Line
          #right = S-end
          #[meta_mac+alt:C-A]
          #1 = M-A-1
          #2 = M-A-2
          #3 = M-A-3
          [meta_mac+shift]
          h = M-S-h
          l = M-S-l
          / = M-S-/
          e = M-S-e
          c = C-S-c
          v = C-S-v
          1 = M-S-1
          2 = M-S-2
          3 = M-S-3
          4 = M-S-4
          5 = M-S-5
          6 = M-S-6
          7 = M-S-7
          8 = M-S-8
          9 = M-S-9
        '';
      };
    };
  };

  #services.input-remapper = {
  #enable = true;
  #};

  #systemd.user.services.set-xhost = {
  ## 121
  #description = "Run a one-shot command upon user login";
  #path = [ pkgs.xorg.xhost ];
  #wantedBy = [ "default.target" ];
  #script = "xhost +SI:localuser:root";
  #environment.DISPLAY = ":0.0"; # NOTE: This is hardcoded for this flake
  #};
  services.xremap = {
    enable = true;
    # NOTE: since this sample configuration does not have any DE, xremap needs to be started manually by systemctl --user start xremap
    serviceMode = "user";
    userName = "py";
    withX11 = true;
    withHypr = false;
    #yamlConfig = ''
    #keymap:
    #- name: Google
    #application:
    #only: Google-chrome
    #remap:
    #Super-1: C-1
    #Super-2: C-2
    #'';
    config = {
      modmap = [
        #{
        #name = "Global";
        #}
        {
          name = "Chrome";
          remap = {
            "Super_L" = "Ctrl_L";
            "Super_R" = "Ctrl_R";
          };
          application.only = [ "Google-chrome" ];
        }
      ];

      keymap = [
        {
          name = "Global";
          remap = {
            "Super-Shift-T" = "C-Shift-T";
            "Super-w" = "C-w";
            "Super-q" = "C-q";
            "Super-f" = "C-f";
            "Super-t" = "C-t";
            "Super-c" = "C-insert";
            "Super-v" = "SHIFT-insert";
            "Super-x" = "SHIFT-delete";
            "Super-backspace" = "delete";
            "Super-r" = "C-r";
            "Super-l" = "C-l";
            "Super-Equal" = "C-Equal";
            "Super-Minus" = "C-Minus";
            #"Super-BTN_LEFT" = "send_key: KEY_LEFTCTRL && click: BTN_LEFT && send_key: KEY_LEFTCTRL";
            #"Super-BTN_LEFT" = "C-Minus";
            #"Super-0" = ["C-0" "M-0"];
            #"Super-1" = ["C-1" "M-1"];
            #"Super-2" = ["C-2" "M-2"];
            #"Super-3" = ["C-3" "M-3"];
            #"Super-4" = ["C-4" "M-4"];
            #"Super-5" = ["C-5" "M-5"];
            #"Super-6" = ["C-6" "M-6"];
            #"Super-7" = ["C-7" "M-7"];
            #"Super-8" = ["C-8" "M-8"];
            #"Super-9" = ["C-9" "M-9"];
            #"Super-1" = "M-1";
            #"Super-2" = "M-2";
            #"Super-3" = "M-3";
            #"Super-4" = "M-4";
            #"Super-5" = "M-5";
            #"Super-6" = "M-6";
            #"Super-7" = "M-7";
            #"Super-8" = "M-8";
            #"Super-9" = "M-9";
            #"Super-BTN_LEFT" = "C-BTN_LEFT";
          };
        }
        {
          name = "Chrome";
          remap = {
            "Super-1" = "C-1";
            "Super-2" = "C-2";
            "Super-3" = "C-3";
            "Super-4" = "C-4";
            "Super-5" = "C-5";
            "Super-6" = "C-6";
            "Super-7" = "C-7";
            "Super-8" = "C-8";
            "Super-9" = "C-9";
            "Super-0" = "C-0";
            "Super-Tab" = "Super-Tab";
          };
          application.only = [ "Google-chrome" ];
        }
        {
          name = "krusader";
          remap = {
            "Super-1" = "M-1";
            "Super-2" = "M-2";
            "Super-3" = "M-3";
            "Super-4" = "M-4";
            "Super-5" = "M-5";
            "Super-6" = "M-6";
            "Super-7" = "M-7";
            "Super-8" = "M-8";
            "Super-9" = "M-9";
            "Super-0" = "M-0";
          };
          application.only = [ "kitty" ];
        }
        {
          name = "Kitty";
          remap = {
            "Super-1" = "M-1";
            "Super-2" = "M-2";
            "Super-3" = "M-3";
            "Super-4" = "M-4";
            "Super-5" = "M-5";
            "Super-6" = "M-6";
            "Super-7" = "M-7";
            "Super-8" = "M-8";
            "Super-9" = "M-9";
            "Super-0" = "M-0";
          };
          application.only = [ "kitty" ];
        }
        {
          name = "Firefox";
          remap = {
            "Super-1" = "M-1";
            "Super-2" = "M-2";
            "Super-3" = "M-3";
            "Super-4" = "M-4";
            "Super-5" = "M-5";
            "Super-6" = "M-6";
            "Super-7" = "M-7";
            "Super-8" = "M-8";
            "Super-9" = "M-9";
            "Super-0" = "M-0";
          };
          application.only = [ "firefox" ];
        }
      ];
    };
  };

  ## Modmap for single key rebinds
  #services.xremap.config.modmap = [
  #{
  #name = "Global";
  #remap = {
  #"KEY_ENTER" = "KEY_BACKSLASH";
  #};
  #remap = {
  #"KEY_BACKSLASH" = "KEY_ENTER";
  #};
  #name = "Chrome";
  #remap = {
  #"LEFTMETA" = "LEFTCTRL";
  #};
  #application.only = [ "Google-chrome" ];
  #}
  #];

  ### Keymap for key combo rebinds
  #services.xremap.config.keymap = [
  #{
  #name = "CMD";
  #remap = {
  #"Super-tab" = "c-tab";
  #};
  #remap = {
  #"Super-w" = "c-w";
  #};
  #remap = {
  #"Super-q" = "c-q";
  #};
  #remap = {
  #"Super-t" = "c-t";
  #};
  #remap = {
  #"Super-c" = "c-c";
  #};
  #remap = {
  #"Super-x" = "c-x";
  #};
  #remap = {
  #"Super-v" = "c-v";
  #};
  ## NOTE: no application-specific remaps work without features (see configuration)
  #}
  #];

  services.libinput = {
    enable = true;
    touchpad.tapping = true;
    touchpad.naturalScrolling = true;
    touchpad.scrollMethod = "twofinger";
    touchpad.disableWhileTyping = true;
    touchpad.clickMethod = "clickfinger";
    touchpad.tappingDragLock = true;
  };
  programs.ydotool.enable = true;

  programs.wayfire = {
    enable = false;
    plugins = with pkgs.wayfirePlugins; [
      wcm
      wf-shell
    ];
  };

  #services.xserver.desktopManager.session =
  #[ { manage = "desktop";
  #start = ''
  #xmodmap /etc/nixos/dotfiles/.Xmodmap
  #'';
  #}
  #];

  ## Configure the console keymap from the xserver keyboard settings
  #console.useXkbConfig = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.usbmuxd = {
    enable = true;
    package = pkgs.usbmuxd2;
  };

  powerManagement = {
    enable = true;
    powertop.enable = false;
    cpuFreqGovernor = "performance";
    #cpuFreqGovernor = "scheldutil";
  };

  services.upower = {
    enable = true;
    criticalPowerAction = "Hibernate";
    usePercentageForPolicy = true;
    percentageLow = 30;
    percentageCritical = 10;
    percentageAction = 5;
    ignoreLid = true;
  };

  services = {

    auto-cpufreq = {
      enable = false;
      settings = {
        battery = {
          governor = "performance";
          turbo = "never";
          enable_thresholds = true;
          start_threshold = 20;
          stop_threshold = 60;
        };
        charger = {
          governor = "performance";
          turbo = "never";
        };
      };
    };

    thermald.enable = true;
    power-profiles-daemon.enable = false;

    tlp = {
      enable = false;
      settings = {
        START_CHARGE_THRESH_BAT0 = 60;
        STOP_CHARGE_THRESH_BAT0 = 80;
        CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        MAX_CHARGE_RATE_BAT0 = 60;
        PLATFORM_PROFILE_ON_AC = "balanced";
        PLATFORM_PROFILE_ON_BAT = "low-power";
        MEM_SLEEP_ON_AC = "s2idle";
        MEM_SLEEP_ON_BAT = "deep";
      };
    };

    mbpfan = {
      enable = true;
      settings = {
        general = {
          min_fan1_speed = 2000;
          max_fan1_speed = 6200;
          low_temp = 55;
          high_temp = 65;
          max_temp = 80;
          polling_interval = 5;
        };
      };
    };

  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      vaapi-intel-hybrid
      #libva-vdpau-driver
      libvdpau-va-gl
      #libvdpau
      intel-media-driver
      intel-ocl
      intel-vaapi-driver
      mesa
      #vpl-gpu-rt # or intel-media-sdk for QSV
    ];
  };
  hardware.intel-gpu-tools.enable = true;
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD"; # Explicitly tells Chrome which driver to use
    ANV_VIDEO_DECODE = "1";
    # This environment variable forces Mesa to use the legacy HasVK driver
    MESA_VK_DEVICE_SELECT = "intel_hasvk";
  };

  #hardware.facetimehd.enable = true;
  #hardware.facetimehd.withCalibration = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        #Enable = "Source,Sink,Media,Socket";
      };
    };
  };

  #systemd.user.services.mpris-proxy = {
  #description = "Mpris proxy";
  #after = [
  #"network.target"
  #"sound.target"
  #];
  #wantedBy = [ "default.target" ];
  #serviceConfig.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
  #};
  # in home manager services /mpris-proxy = true; already included the lines above.

  #hardware.system76.power-daemon.enable = true;
  #hardware.system76.enableAll = true;
  services.blueman.enable = true;
  #hardware.pulseaudio = {
  #enable = true;
  ##package = pkgs.pulseaudioFull.override { jackaudioSupport = true; };
  #package = pkgs.pulseaudioFull;
  #support32Bit = true;
  #};
  #services.jack = {
  #jackd.enable = true;
  ## support ALSA only programs via ALSA JACK PCM plugin
  #alsa.enable = true;
  ## support ALSA only programs via loopback device (supports programs like Steam)
  ##loopback = {
  ##enable = true;
  ### buffering parameters for dmix device to work with ALSA only semi-professional sound programs
  ###dmixConfig = ''
  ###  period_size 2048
  ###'';
  ##};
  #};
  security.rtkit.enable = true;
  musnix.enable = true;

  services.pipewire = {
    enable = true;
    audio.enable = true;
    pulse.enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    jack.enable = true;
    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
    extraConfig.pipewire = {
      "10-clock-rate" = {
        "context.properties" = {
          "default.clock.rate" = 44100;
          "default.clock.quantum" = 1024;
          "default.clock.min-quantum" = 1024;
          "default.clock.max-quantum" = 1024;
        };
      };
    };
    wireplumber = {
      enable = true;
      extraConfig.bluetoothEnhancements = {

        "monitor.bluez.properties" = {
          "bluez5.default.rate" = 44100;
          "bluez5.enable-sbc-xq" = true;
          "bluez5.enable-msbc" = true;
          "bluez5.enable-hw-volume" = true;
          "bluez5.roles" = [
            "a2dp_sink"
            "a2dp_source"
            "bap_sink"
            "bap_source"
            "hfp_hf"
            "hfp_ag"
            "hsp_hs"
            "hsp_ag"
          ];
        };

        "monitor.bluez.rules" = {
          matches = [
            {
              "node.name" = "~bluez_input.*";
            }
            {
              "node.name" = "~bluez_output.*";
            }
          ];
          actions = {
            update-props = {
              "session.suspend-timeout-seconds" = 0;
            };
          };
        };

      };
    };
  };

  fonts.fontconfig = {
    enable = true;
    useEmbeddedBitmaps = true;
    defaultFonts = {
      serif = [
        "Noto Serif"
        "Liberation Serif"
        "FreeSerif"
      ];
      sansSerif = [
        "Noto Sans"
        "Ubuntu"
        "Cantarell"
        "DejaVu Sans"
        "Roboto"
        "Inter"
      ];
      monospace = [
        "JetBrains Mono Nerd Font"
        "DejaVu Sans Mono"
        "FreeMono"
      ];
    };
  };

  fonts.packages = with pkgs; [
    # https://wiki.archlinux.org/title/Font_configuration
    #xorg.fontmicromisc
    font-awesome
    uw-ttyp0
    gohufont
    terminus_font_ttf
    profont
    efont-unicode
    noto-fonts-color-emoji
    dina-font
    fanwood

    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.iosevka
    nerd-fonts.hack

    # for Chinese
    source-han-serif
    source-han-sans
    freefont_ttf
    roboto
    inter
    corefonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    source-han-serif

    noto-fonts
    vista-fonts
    ubuntu-classic
    cantarell-fonts
    liberation_ttf

    #google-fonts
    #dejavu_fonts
    #meslo-lgs-nf
    #source-han-sans-vf-ttf
    #source-han-serif-vf-ttf
    ##ark-pixel-font
    ##zpix-pixel-font
    #wqy_microhei
    #helvetica-neue-lt-std
    #aileron
    ##maple-mono
    #julia-mono
    #jetbrains-mono
    #paratype-pt-sans
    ##tamsyn
    #vistafonts
    ##unscii
    #xorg.xbitmaps
    ##ucs-fonts
    #cozette
    #terminus_font
    #roboto
    #unscii
    #tamzen
    #envypn-font
    #spleen
    #ucs-fonts
    #corefonts
    #wineWowPackages.fonts
  ];

  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.

  #users.groups.keyd.members = [ "py" ];
  #users.groups.media = {};
  #users.users.plex.extraGroups = [ "media" ];
  #users.groups.media.members = [ ... ];

  #users.groups.keyd = {};
  #users.users.keyd = {
  #group = "keyd";
  #isSystemUser = true;
  #};
  services.udev.extraRules = ''
    KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
    SUBSYSTEM=="i2c-dev", GROUP="i2c", MODE="0660"
  '';
  users.groups.i2c = { };

  users.users.py = {
    isNormalUser = true;
    description = "py";
    group = "users";
    extraGroups = [
      "input"
      "evdev"
      "uinput"
      "networkmanager"
      "wheel"
      "docker"
      "ydotool"
      "deluge"
      "audio" # for pulseaudio?
      "jackaudio"
      "seat"
      "sambashare"
      "i2c"
    ];
    packages = with pkgs; [
    ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # wayland
    grim # screenshot functionality
    slurp # screenshot functionality
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    xsel
    xclip
    mako # notification system developed by swaywm maintainer
    #nur.repos.xddxdd.wine-wechat
    #nur.repos.xddxdd.wechat-uos-without-sandbox
    #grim # screenshot functionality
    #slurp # screenshot functionality
    #wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    #mako # notification system developed by swaywm maintainer
    qjackctl
    libjack2
    jack2
    pavucontrol
    bluez-tools
    #libcamera
    pulseaudioFull
    #jack_capture

    thermald
    powertop
    smartmontools
    dmidecode
    acpi
    #auto-cpufreq
    #linuxKernel.packages.linux_6_6.facetimehd
    brightnessctl
    libimobiledevice
    ifuse
    wget
    gsimplecal
    wmctrl
    #xorg.xprop

    kdePackages.qt6ct
    libsForQt5.qt5ct
    lxqt.lxqt-menu-data

    nwg-look
    lxappearance

    # cd /run/current-system/sw/share/icons  they are stored here!!
    # cd /etc/profiles/per-user/py/share/icons/ here for home.nix pointcursor and xdg
    #inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default
    rose-pine-hyprcursor
    bibata-cursors
    nordzy-cursor-theme
    numix-cursor-theme
    openzone-cursors
    vimix-cursors
    volantes-cursors
    xdotool
    xbindkeys
    xautomation
    libinput-gestures
    libinput
    inxi
    ##coreboot-utils #ectool
    #xorg.xmodmap
    xorg.xev
    wev
    keymapper
    sxhkd
    #xorg.libX11
    #xorg.libxcb
    #xorg.libXrender
    #xorg.libXi
    #libsForQt5.qt5.qtwayland
    libsForQt5.qt5.qtbase
    #kdePackages.qtwayland
    kdePackages.qtbase
    kdePackages.kglobalacceld
    kdePackages.kglobalaccel
    libsForQt5.kglobalaccel
    kdePackages.qttools
    kdePackages.qtmultimedia
    libsForQt5.ki18n
    libsForQt5.qt5ct
    kdePackages.ki18n
    qt6.qtwayland
    qt5.qtwayland
    #kdePackages.qt6gtk2
    #kdePackages.qt6ct
    #xorg.setxkbmap
    #xorg.xkbcomp
    #xorg.xhost # for gparted
    #xkeysnail
    #xfce.xfce4-dict
    #xfce.xfce4-panel
    #xfce.xfce4-appfinder
    #xfce.xfce4-settings
    #xfce.xfwm4
    #xfce.xfce4-dict
    #xfce.xfce4-pulseaudio-plugin
    libnotify
    playerctl
    qpwgraph
    #virtualgl
    #pavucontrol
    #pamixer
    #pw-volume
    font-manager
    fontpreview
    #fontmatrix

    lxqt.lxqt-wayland-session
    wayfire # Wayland compositor
    wlroots # Required for wayfire

    swayidle
    gparted
    cpu-x
    vulkan-tools
    linuxKernel.packages.linux_6_12.turbostat
    pciutils
    ddcutil
    inetutils
    libva-utils # VA-API
    usbutils
    tcpdump
    mtr
    #wlsunset
    libcap
    systemdUkify
    #mihomo-party
    #gui-for-singbox
    #v2rayn
    #xray
    #v2ray-geoip
    #hysteria
    #clash-meta
    #mihomo
    #clash-verge-rev
    #clashtui
    #clash-rs
    #clash-nyanpasu
    #shadowsocks-rust
    #hiddify-app
    #metacubexd
    daed

    cifs-utils
    #autofs5
    lxqt.lxqt-policykit

    trash-cli
    xdg-utils
    gnome-shell

    gnome-menus
    desktop-file-utils

    kdePackages.plasma-workspace
    kdePackages.plasma-integration
    kdePackages.kservice # for kbuildsycoca6
    kdePackages.kde-cli-tools
    kdePackages.dolphin
    kdePackages.qtsvg
    kdePackages.kio-fuse
    kdePackages.kio-extras
  ];
  environment.etc."xdg/menus/applications.menu".source =
    "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";
  environment.pathsToLink = [
    "/libexec"
    "/share/kservices6"
    "/share/kservicetypes6"
  ]; # kde
  programs.dconf.enable = true; # for gnome packages outside of gnome
  nixpkgs.overlays = [
    (self: super: {
      gnome = super.gnome.overrideScope (
        gself: gsuper: {
          nautilus = gsuper.nautilus.overrideAttrs (nsuper: {
            buildInputs =
              nsuper.buildInputs
              ++ (with super.gst_all_1; [
                gst-plugins-good
                gst-plugins-bad
              ]);
          });
        }
      );
    })
  ];

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [

  ];
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin
      thunar-volman
    ];
  };

  system.activationScripts.diff = {
    supportsDryActivation = true;
    text = ''
      ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff \
           /run/current-system "$systemConfig"
    '';
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  services.redsocks = {
    enable = false;

    redsocks = [
      {
        ip = "127.0.0.1"; # Safe bind address
        port = 12345; # Any free local port
        type = "socks5";
        proxy = "192.168.124.8:10808"; # External proxy
        disclose_src = "false";
      }
    ];
  };
  #networking.nftables.ruleset = ''
  #table ip nat {
  #chain REDSOCKS {
  #type nat hook output priority filter; policy accept;
  ## Skip local/LAN traffic
  #ip daddr { 0.0.0.0/8, 10.0.0.0/8, 127.0.0.0/8, 169.254.0.0/16, 172.16.0.0/12, 192.168.0.0/16, 224.0.0.0/4, 240.0.0.0/4 } return
  ## Redirect all other TCP traffic to redsocks
  #meta l4proto tcp redirect to :12345
  #}
  #}
  #'';

  #security.krb5.enable = true; # for samba?

  programs.bandwhich.enable = true;
  # Open ports in the firewall.
  networking = {

    nftables.enable = true;

    firewall = {
      enable = true;
      allowedTCPPorts = [
        2283
        56789
        7890
        7891
        10808
        #7878 # radarr
        #8989 # sonarr
        #9696 # prowlarr
        #22000 # Syncthing transfer
        #22001 # Syncthing transfer (TLS)
        #21027 # Syncthing discovery
      ];
      allowedUDPPorts = [
        #21027 # Syncthing Discovery
        2283
        9
        7890 # mihomo
        10808
        53
      ]; # 2283:immich 9 wakeonlan
      allowedTCPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];
      allowedUDPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];
      trustedInterfaces = [
        "eth0"
        "tun0"
      ];
    };
    #nameservers = [
    #"127.0.0.1"
    #];
    useHostResolvConf = false;
    resolvconf.enable = false;
  };

  services.tailscale.enable = false;

  services.resolved = {
    enable = true;
    #fallbackDns = [ "127.0.0.1" ];
    settings = {
      Resolve = {
        Domains = [ "~." ];
        DNSStubListener = "yes";
      };
    };

  };
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
    };
    #knownHosts."NixNAS" = {
    #hostNames = [ "192.168.124.76" ];
    #publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINhppLSZ+s+f27ZY7YkDwCQFF5dILpqV9uqj1UmyuPqs";
    #};
  };
  programs.mosh = {
    enable = true;
    openFirewall = true;
  };

  #fileSystems."/home/py/sambamnt" = {
  #device = "//192.168.2.1/myfiles";
  #fsType = "cifs";
  #options =
  #let
  #automountOpts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
  #in
  #[
  #"${automountOpts}"
  #"credentials=/home/py/Dropbox (Maestral)/mac_config/Scripts/smb-credentials"
  #"vers=3.1.1"
  #"soft"
  #"_netdev"
  #"noserverino"
  #"cache=none"
  #"actimeo=30"
  #"iocharset=utf8"
  #"rw"
  #];
  #};
  services.gvfs = {
    enable = true;
    package = pkgs.gnome.gvfs;
  };

  #fileSystems."/home/py/sambamnt/myfiles" = {
  #device = "//192.168.2.1/myfiles";
  #fsType = "cifs";
  #options = [
  #"credentials=/home/py/Dropbox (Maestral)/mac_config/Scripts/smb-credentials"
  #"uid=1000"
  #"gid=1000"
  #"iocharset=utf8"
  #"vers=3.1.1"
  #"soft"
  #"x-systemd.automount"
  #"_netdev"
  #"nofail"
  #"noauto"
  #"idle-timeout=10"
  #];
  #};

  #myfiles -fstype=cifs,rw,soft,_netdev,vers=3.1.1,credentials=/home/py/Dropbox\040(Maestral\)/mac_config/Scripts/smb-credentials,iocharset=utf8,noserverino ://192.168.2.1/myfiles
  #environment.etc."auto.smb".text = ''
  #/home/py/sambamnt -fstype=cifs,rw,soft,_netdev,vers=3.1.1,credentials=/home/py/smb-credentials,iocharset=utf8,noserverino ://192.168.2.1/myfiles
  #'';

  #myfiles  -fstype=cifs,rw,soft,_netdev,vers=3.1.1,credentials=/home/py/smb-credentials,iocharset=utf8,noserverino  ://192.168.2.1/myfiles
  #/home/py/sambamnt -fstype=cifs,rw,soft,_netdev,vers=3.1.1,credentials=/home/py/smb-credentials,iocharset=utf8,noserverino,cache=none,actimeo=5,uid=py,gid=users ://192.168.2.1/myfiles
  #myfiles -fstype=cifs,mountprog=/bin/mount.cifs,rw,soft,_netdev,vers=3.1.1,credentials=/home/py/smb-credentials,iocharset=utf8,serverino,cache=none,actimeo=1,echo_interval=5,retrans=3,uid=py,gid=users ://192.168.2.1/myfiles
  #fileSystems."/home/py/sambamnt" = {
  #device = "/mnt/smb/myfiles";
  #fsType = "none";
  #options = [ "bind" ];
  #};

  #myfiles -fstype=cifs,rw,soft,_netdev,vers=3.1.1,credentials=/home/py/smb-credentials,iocharset=utf8,noserverino,cache=loose,uid=py,gid=users ://192.168.2.1/myfiles
  #myfiles -fstype=cifs,rw,soft,_netdev,vers=3.1.1,credentials=/home/py/smb-credentials,iocharset=utf8,uid=py,gid=users ://192.168.2.1/myfiles
  services.autofs = {
    enable = true;
    autoMaster =
      let
        smbMap = pkgs.writeText "auto.smb" ''
          myfiles -fstype=cifs,rw,soft,_netdev,vers=3.1.1,credentials=/home/py/smb-credentials,iocharset=utf8,noserverino,cache=loose,uid=py,gid=users ://192.168.2.1/myfiles
        '';
      in
      ''
        /home/py/sambamnt file:${smbMap} --ghost
      '';
    timeout = 600;
    debug = true;
  };
  #systemd.services.autofs-refresh = {
  #description = "Restart autofs after resume";
  #after = [
  #"network-online.target"
  #"autofs.service"
  #];
  #requires = [ "network-online.target" ];
  #wantedBy = [
  #"suspend.target"
  #"hibernate.target"
  #"sleep.target"
  #];
  #serviceConfig = {
  #Type = "oneshot";
  #ExecStartPre = "${pkgs.util-linux}/bin/umount -l /home/py/sambamnt || true";
  #ExecStart = "${pkgs.systemd}/bin/systemctl try-restart autofs.service";
  #};
  #};
  systemd.services.autofs-refresh = {
    description = "Refresh autofs after resume (force unmount + pre-mount)";
    after = [
      "network-online.target"
      "autofs.service"
    ];
    wants = [ "network-online.target" ];
    wantedBy = [
      "suspend.target"
      "hibernate.target"
      "sleep.target"
    ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = ''
        # Force unmount any stale mounts (won't fail if clean)
        ${pkgs.util-linux}/bin/umount -lf /home/py/sambamnt/myfiles || true

        # Restart autofs
        ${pkgs.systemd}/bin/systemctl try-restart autofs.service

        # Pre-mount the indirect share so GUI sees files immediately
        ls /home/py/sambamnt/myfiles > /dev/null || true
      '';
    };
  };
  #systemd.services.autofs-refresh = {
  #description = "Restart autofs after resume";
  #after = [ "network-online.target" ];
  #requires = [ "network-online.target" ];
  #wantedBy = [
  #"suspend.target"
  #"hibernate.target"
  #"sleep.target"
  #];
  #serviceConfig = {
  #Type = "oneshot";
  #ExecStart = "${pkgs.systemd}/bin/systemctl restart autofs.service";
  #};
  #};

  services.mihomo = {
    enable = false;
    tunMode = true;
    webui = pkgs.metacubexd;
    configFile = "/home/py/Downloads/mihomo/config.yaml";
  };
  #security.wrappers.mihomo = {
  #source = "${pkgs.mihomo}/bin/mihomo";
  ##source = "/home/py/.local/share/v2rayN/bin/mihomo";
  #capabilities = "cap_net_admin,cap_net_bind_service+eip";
  #owner = "py";
  #group = "users";
  #};
  programs.clash-verge = {
    enable = false;
    autoStart = false;
    tunMode = true;
    serviceMode = true;
  };
  services.v2raya = {
    enable = true;
  };

  services.sing-box.enable = false;
  services.dae.enable = false;
  services.shadowsocks.enable = false;
  services.v2ray.enable = false;
  services.xray = {
    enable = false;
    settings = {
      inbounds = [
        {
          listen = "127.0.0.1";
          port = 1080;
          protocol = "http";
        }
      ];
      outbounds = [
        {
          protocol = "freedom";
        }
      ];
    };
  };

  services.dictd.enable = false;

  services.syncthing = {
    enable = true;
    user = "py";
    dataDir = "/home/py/Sync";
    openDefaultPorts = true;
  };

  #services.radarr = {
  #enable = true;
  #};
  #services.sonarr = {
  #enable = true;
  #};
  #services.prowlarr = {
  #enable = true;
  #};

  services.deluge = {
    enable = true;
    #web = {
    #enable = true;
    #openFirewall = true;
    #};
    declarative = true;
    user = "py";
    dataDir = "/home/py";
    openFirewall = true;
    authFile =
      let
        deluge_auth_file = (
          builtins.toFile "auth" ''
            localclient::10
          ''
        );
      in
      deluge_auth_file;
    config = {
      allow_remote = true;
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

  #services.logind.lidSwitch = "ignore";

}
