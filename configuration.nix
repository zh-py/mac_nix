# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  lib,
  ...
}:
#let
#compiledLayout = pkgs.runCommand "keyboard-layout" {} ''
#${pkgs.xorg.xkbcomp}/bin/xkbcomp ${./path/to/layout.xkb} $out
#'';
#in
let
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

  #nix.settings.substituters = [ "https://mirror.sjtu.edu.cn/nix-channels/store" "https://mirrors.ustc.edu.cn/nix-channels/store" "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" ];
  #nix.settings.substituters = lib.mkBefore [ "https://mirror.sjtu.edu.cn/nix-channels/store" "https://mirrors.ustc.edu.cn/nix-channels/store" "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" ];

  systemd.extraConfig = "DefaultLimitNOFILE=4096";
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
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

  services.logind.extraConfig = ''
    HandlePowerKey=suspend
    HandlePowerKeyLongPress=poweroff
  '';
  systemd.sleep.extraConfig = ''
    AllowSuspend=yes
    AllowHibernation=yes
    AllowHybridSleep=yes
    AllowSuspendThenHibernate=yes
    HibernateDelaySec=1h
  '';

  programs.hyprlock.enable = true;

  services.connman.enable = true;
  services.connman.wifi.backend = "iwd";

  networking = {
    hostName = "nixos";
    wireless = {
      iwd = {
        enable = true;
        settings = {
          General = {
            EnableNetworkConfiguration = true;
          };
          Network = {
            EnableIPv6 = false;
            RoutePriorityOffset = 300;
          };
          Settings = {
            AutoConnect = true;
          };
        };
      };
    };

    networkmanager = {
      enable = false;
      wifi.backend = "iwd";
    };
    #proxy = {
    #default = "http://user:password@proxy:port/";
    #noProxy = "127.0.0.1,localhost,internal.domain";
    #};

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
    fcitx5.addons = with pkgs; [
      fcitx5-gtk
      fcitx5-chinese-addons
      fcitx5-pinyin-zhwiki
      fcitx5-nord
    ];
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

  services.gnome.gnome-keyring.enable = true;
  programs.sway = {
    enable = false;
    wrapperFeatures.gtk = true;
  };
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  programs.waybar.enable = true;

  #security.pam.services.ly.enableGnomeKeyring = true;
  #services.displayManager = {
  #autoLogin = {
  #enable = false;
  #user = "py";
  #};
  #ly = {
  #enable = true;
  #};
  #};

  services.haveged.enable = true;

  services.getty.autologinUser = "py";

  security.polkit.enable = true;

  services.xserver = {
    # 47lines
    enable = true;
    displayManager = {
      startx.enable = true;
    };
    videoDrivers = [ "modesetting" ];  # Use modesetting instead of intel
    desktopManager = {
      xterm.enable = false;
    };

    #lightdm = {
    #enable = true;
    #greeters.slick = {
    #enable = true;
    #theme.name = "Zukitre-dark";
    #};
    #};
    #};
    desktopManager.lxqt.enable = true;
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

  #systemd.user.services.set-xhost = { #114
  #description = "Run a one-shot command upon user login";
  #path = [ pkgs.xorg.xhost ];
  #wantedBy = [ "default.target" ];
  #script = "xhost +SI:localuser:root";
  #environment.DISPLAY = ":0.0"; # NOTE: This is hardcoded for this flake
  #};
  #services.xremap = {
  #withX11 = true;
  ##yamlConfig = ''
  ##keymap:
  ##- name: Google
  ##application:
  ##only: Google-chrome
  ##remap:
  ##Super-1: C-1
  ##Super-2: C-2
  ##'';
  #config = {
  #modmap = [
  #{
  #name = "Global";
  #remap = { "KEY_ENTER" = "KEY_BACKSLASH"; };
  #remap = { "KEY_BACKSLASH" = "KEY_ENTER"; };
  ##remap = { "KEY_LSGT" = "KEY_LEFTSHIFT"; };
  #}
  #{
  #name = "Chrome";
  #remap = { "Super_L" = "Ctrl_L"; };
  #application.only = [ "Google-chrome" ];
  #}
  #];

  #keymap = [
  #{
  #name = "Global";
  #remap = {
  #"Super-Shift-T" = "C-Shift-T";
  #"Super-w" = "C-w";
  #"Super-q" = "C-q";
  #"Super-f" = "C-f";
  #"Super-t" = "C-t";
  #"Super-c" = "C-c";
  #"Super-x" = "C-x";
  #"Super-v" = "C-v";
  #"Super-r" = "C-r";
  #"Super-l" = "C-l";
  #"Super-Equal" = "C-Equal";
  #"Super-Minus" = "C-Minus";
  ##"Super-0" = ["C-0" "M-0"];
  ##"Super-1" = ["C-1" "M-1"];
  ##"Super-2" = ["C-2" "M-2"];
  ##"Super-3" = ["C-3" "M-3"];
  ##"Super-4" = ["C-4" "M-4"];
  ##"Super-5" = ["C-5" "M-5"];
  ##"Super-6" = ["C-6" "M-6"];
  ##"Super-7" = ["C-7" "M-7"];
  ##"Super-8" = ["C-8" "M-8"];
  ##"Super-9" = ["C-9" "M-9"];
  ##"Super-1" = "M-1";
  ##"Super-2" = "M-2";
  ##"Super-3" = "M-3";
  ##"Super-4" = "M-4";
  ##"Super-5" = "M-5";
  ##"Super-6" = "M-6";
  ##"Super-7" = "M-7";
  ##"Super-8" = "M-8";
  ##"Super-9" = "M-9";
  ##"Super-BTN_LEFT" = "C-BTN_LEFT";
  #};
  #}
  #{
  #name = "Chrome";
  #remap = {
  #"Super-1" = "C-1";
  #"Super-2" = "C-2";
  #"Super-3" = "C-3";
  #"Super-4" = "C-4";
  #"Super-5" = "C-5";
  #"Super-6" = "C-6";
  #"Super-7" = "C-7";
  #"Super-8" = "C-8";
  #"Super-9" = "C-9";
  #"Super-0" = "C-0";
  #};
  #application.only = [ "Google-chrome" ];
  #}
  #{
  #name = "Firefox";
  #remap = {
  #"Super-1" = "M-1";
  #"Super-2" = "M-2";
  #"Super-3" = "M-3";
  #"Super-4" = "M-4";
  #"Super-5" = "M-5";
  #"Super-6" = "M-6";
  #"Super-7" = "M-7";
  #"Super-8" = "M-8";
  #"Super-9" = "M-9";
  #"Super-0" = "M-0";
  #};
  #application.only = [ "firefox" ];
  #}
  #];
  #};
  #};

  ### Modmap for single key rebinds
  ##services.xremap.config.modmap = [
  ##{
  ##name = "Global";
  ##remap = { "KEY_ENTER" = "KEY_BACKSLASH"; };
  ##remap = { "KEY_BACKSLASH" = "KEY_ENTER"; };
  ##name = "Chrome";
  #remap = { "LEFTMETA" = "LEFTCTRL"; };
  #application.only = [ "Google-chrome" ];
  #}
  #];

  ## Keymap for key combo rebinds
  #services.xremap.config.keymap = [
  #{
  #name = "CMD";
  #remap = { "Super-tab" = "c-tab"; };
  #remap = { "Super-w" = "c-w"; };
  #remap = { "Super-q" = "c-q"; };
  #remap = { "Super-t" = "c-t"; };
  #remap = { "Super-c" = "c-c"; };
  #remap = { "Super-x" = "c-x"; };
  #remap = { "Super-v" = "c-v"; };
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

  #powerManagement = {
  #enable = true;
  #powertop.enable = true;
  #cpuFreqGovernor = "powersave";
  #};

  services = {

    auto-cpufreq = {
      enable = false;
      settings = {
        battery = {
          governor = "powersave";
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
      enable = true;
      settings = {
        START_CHARGE_THRESH_BAT0 = 60;
        STOP_CHARGE_THRESH_BAT0 = 80;
        CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
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
          low_temp = 63;
          high_temp = 66;
          max_temp = 85;
          polling_interval = 7;
        };
      };
    };

  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      # your Open GL, Vulkan and VAAPI drivers
      intel-media-driver
      intel-ocl
      intel-vaapi-driver
      vpl-gpu-rt # or intel-media-sdk for QSV
    ];
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

  fonts.packages = with pkgs; [
    # https://wiki.archlinux.org/title/Font_configuration
    font-awesome
    uw-ttyp0
    gohufont
    terminus_font_ttf
    profont
    efont-unicode
    noto-fonts-emoji
    dina-font

    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.iosevka
    nerd-fonts.hack

    # for Chinese
    source-han-serif
    #source-han-sans

    #noto-fonts
    #noto-fonts-cjk-sans
    #google-fonts
    #meslo-lgs-nf
    #noto-fonts-cjk-serif
    #source-han-sans-vf-ttf
    #source-han-serif-vf-ttf
    #source-han-serif
    ##ark-pixel-font
    ##zpix-pixel-font
    #wqy_microhei
    #helvetica-neue-lt-std
    #aileron
    #ubuntu_font_family
    #fira
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
  users.users.py = {
    isNormalUser = true;
    description = "py";
    extraGroups = [
      "input"
      "uinput"
      "networkmanager"
      "wheel"
      "docker"
      "ydotool"
      "deluge"
      "audio" # for pulseaudio?
      "jackaudio"
    ];
    packages = with pkgs; [
    ];
  };

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
    nordzy-cursor-theme
    numix-cursor-theme
    openzone-cursors
    vimix-cursors
    volantes-cursors
    xdotool
    xautomation
    libinput-gestures
    libinput
    inxi
    ##coreboot-utils #ectool
    #xorg.xmodmap
    xorg.xev
    wev
    keymapper
    #xorg.libX11
    #xorg.libxcb
    #xorg.libXrender
    #xorg.libXi
    #libsForQt5.qt5.qtwayland
    #libsForQt5.qt5.qtbase
    #kdePackages.qtwayland
    #kdePackages.qtbase
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
    playerctl
    qpwgraph
    #pavucontrol
    #pamixer
    #pw-volume
    font-manager
    #fontmatrix
    fontpreview
    keyd
  ];

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [

  ];

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

  programs.bandwhich.enable = true;
  networking.nftables.enable = true;
  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 2283 ]; # 2283:immich
  networking.firewall.allowedUDPPorts = [ 2283 ]; # 2283:immich
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  services.openssh.enable = true;
  services.v2raya.enable = true;
  services.dictd.enable = true;
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
