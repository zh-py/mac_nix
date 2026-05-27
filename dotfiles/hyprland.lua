local terminal = "kitty"
local fileManager = "thunar"
local menu = "fuzzel"
local dmenu = "fuzzel"

local SCR_DIR = os.getenv("HOME") .. "/Pictures/Screenshots"

hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = "auto",
})

hl.on("hyprland.start", function()
	hl.exec_cmd("hyprshell run")
	hl.exec_cmd(
		"iwctl adapter phy0 set-property Powered on & iwctl device eth0 set-property Powered on & /etc/profiles/per-user/py/bin/fusuma -d"
	)
	hl.exec_cmd(
		"dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP QT_QPA_PLATFORMTHEME=qt5ct"
	)
	hl.exec_cmd("swaync")
	hl.exec_cmd(terminal)
	hl.exec_cmd("sleep 4 && maestral start")
	hl.exec_cmd("waypaper --restore")
	hl.exec_cmd("hypridle")
	hl.exec_cmd("wl-paste --type text --watch cliphist store &")
	hl.exec_cmd("wl-paste --type image --watch cliphist store &")
end)

hl.workspace_rule({ workspace = "4", on_created_empty = "foot -e btop" })
hl.workspace_rule({ workspace = "w[tv1]s[false]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]s[false]", gaps_out = 0, gaps_in = 0 })

hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")

hl.config({
	general = {
		gaps_in = 5,
		gaps_out = 8,
		border_size = 0,
		col = {
			active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
			inactive_border = "rgba(595959aa)",
		},
		resize_on_border = false,
		allow_tearing = false,
		layout = "dwindle",
	},
	decoration = {
		rounding = 7,
		rounding_power = 2,
		active_opacity = 1.0,
		inactive_opacity = 1.0,
		dim_inactive = false,
		shadow = {
			enabled = true,
			range = 4,
			render_power = 3,
			color = 0xee1a1a1a,
		},
		blur = {
			enabled = true,
			size = 3,
			passes = 1,
			vibrancy = 0.1696,
		},
	},
	animations = {
		enabled = true,
	},
})

hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })

hl.config({
	dwindle = {
		preserve_split = true,
	},
})

hl.config({
	master = {
		new_status = "master",
	},
})

hl.config({
	misc = {
		force_default_wallpaper = 0,
		disable_hyprland_logo = false,
	},
})

hl.config({
	scrolling = {
		fullscreen_on_one_column = true,
	},
})
---------------
---- INPUT ----
---------------

hl.config({
	input = {
		kb_layout = "us",
		kb_variant = "",
		kb_model = "",
		kb_options = "",
		kb_rules = "",
		follow_mouse = 1,
		sensitivity = 0,
		touchpad = {
			natural_scroll = true,
		},
	},
})

hl.device({
	name = "epic-mouse-v1",
	sensitivity = -0.5,
})

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "ALT"

hl.bind(mainMod .. " + K", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + CTRL + F", hl.dsp.window.fullscreen())
hl.bind("META + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())

hl.bind(mainMod .. " + CTRL + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + CTRL + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + CTRL + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + CTRL + J", hl.dsp.focus({ direction = "down" }))

hl.bind("META + SHIFT + 1", hl.dsp.focus({ workspace = 1 }))
hl.bind("META + SHIFT + 2", hl.dsp.focus({ workspace = 2 }))
hl.bind("META + SHIFT + 3", hl.dsp.focus({ workspace = 3 }))
hl.bind("META + SHIFT + 4", hl.dsp.focus({ workspace = 4 }))
hl.bind("META + SHIFT + 5", hl.dsp.focus({ workspace = 5 }))
hl.bind("META + SHIFT + 6", hl.dsp.focus({ workspace = 6 }))
hl.bind("META + SHIFT + 7", hl.dsp.focus({ workspace = 7 }))
hl.bind("META + SHIFT + 8", hl.dsp.focus({ workspace = 8 }))
hl.bind("META + SHIFT + 9", hl.dsp.focus({ workspace = 9 }))
hl.bind("META + SHIFT + 0", hl.dsp.focus({ workspace = 10 }))

--hl.bind("META + SHIFT + RIGHT", hl.dsp.window.move({ workspace = "+1" }))
--hl.bind("META + SHIFT + LEFT", hl.dsp.window.move({ workspace = "-1" }))
hl.bind(mainMod .. " + SHIFT + RIGHT", hl.dsp.window.move({ workspace = "+1" }))
hl.bind(mainMod .. " + SHIFT + LEFT", hl.dsp.window.move({ workspace = "-1" }))

hl.bind(mainMod .. " + SHIFT + 1", hl.dsp.window.move({ workspace = 1 }))
hl.bind(mainMod .. " + SHIFT + 2", hl.dsp.window.move({ workspace = 2 }))
hl.bind(mainMod .. " + SHIFT + 3", hl.dsp.window.move({ workspace = 3 }))
hl.bind(mainMod .. " + SHIFT + 4", hl.dsp.window.move({ workspace = 4 }))
hl.bind(mainMod .. " + SHIFT + 5", hl.dsp.window.move({ workspace = 5 }))
hl.bind(mainMod .. " + SHIFT + 6", hl.dsp.window.move({ workspace = 6 }))
hl.bind(mainMod .. " + SHIFT + 7", hl.dsp.window.move({ workspace = 7 }))
hl.bind(mainMod .. " + SHIFT + 8", hl.dsp.window.move({ workspace = 8 }))
hl.bind(mainMod .. " + SHIFT + 9", hl.dsp.window.move({ workspace = 9 }))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

hl.gesture({
	fingers = 4,
	direction = "left",
	mods = "SHIFT",
	action = function()
		hl.dispatch(hl.dsp.window.move({ workspace = "-1" }))
	end,
})
hl.gesture({
	fingers = 4,
	direction = "right",
	mods = "SHIFT",
	action = function()
		hl.dispatch(hl.dsp.window.move({ workspace = "+1" }))
	end,
})
hl.gesture({ fingers = 4, direction = "down", action = "fullscreen" })

hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("CTRL + RIGHT", hl.dsp.focus({ workspace = "r+1" }))
hl.bind("CTRL + LEFT", hl.dsp.focus({ workspace = "r-1" }))

hl.bind("CTRL + ALT + M", hl.dsp.exec_cmd(dmenu))

local date_fmt = "$(date +'%Y-%m-%d_%H-%M-%S.png')"
hl.bind("META + CTRL + 3", hl.dsp.exec_cmd("grim " .. SCR_DIR .. "/" .. date_fmt))
hl.bind("META + CTRL + 4", hl.dsp.exec_cmd('grim -g "$(slurp)" ' .. SCR_DIR .. "/" .. date_fmt))
hl.bind("META + SHIFT + CTRL + 3", hl.dsp.exec_cmd("grim - | wl-copy"))
hl.bind("META + SHIFT + CTRL + 4", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("ALT + CTRL + SPACE", hl.dsp.exec_cmd("fcitx5-remote -t"))

hl.bind("CTRL + V", hl.dsp.exec_cmd("rofi -modi clipboard:/home/py/.config/rofi/cliphist-rofi -show clipboard"))

hl.bind("SUPER + SPACE", hl.dsp.exec_cmd("pkill " .. menu .. " || " .. menu))

hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("ddcutil setvcp 10 + 5"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("ddcutil setvcp 10 - 5"))

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

hl.window_rule({
	name = "suppress-maximize-events",
	match = { class = ".*" },
	suppress_event = "maximize",
})

hl.window_rule({
	name = "fix-xwayland-drags",
	match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
	no_focus = true,
})

hl.window_rule({
	name = "no-gaps-wtv1",
	match = { workspace = "w[tv1]s[false]" },
	border_size = 0,
	rounding = 0,
})

hl.window_rule({
	name = "float-dialogs",
	match = { class = "^(popup|dialog|confirm|notification)$" },
	float = true,
})

hl.window_rule({
	name = "float-thunar",
	match = { class = "^thunar$" },
	float = true,
})

hl.window_rule({
	name = "size-thunar",
	match = { class = "^thunar$" },
	size = "1600 1000",
})

hl.window_rule({
	name = "center-thunar",
	match = { class = "^thunar$" },
	center = true,
})

hl.window_rule({
	name = "no-max-size-thunar",
	match = { class = "^thunar$" },
	no_max_size = true,
})

hl.window_rule({
	name = "float-eudic",
	match = { class = "^eudic$" },
	float = true,
})

hl.window_rule({
	name = "move-eudic",
	match = { class = "^eudic$" },
	move = "0 0",
})

hl.window_rule({
	name = "size-eudic",
	match = { class = "^eudic$" },
	size = "(monitor_w*0.5) (monitor_h*0.7)",
})

hl.window_rule({
	name = "position-eudic",
	match = { class = "^eudic$" },
	move = "(monitor_w*0.5) 0",
})

hl.window_rule({
	name = "float-nautilus",
	match = { class = "^org.gnome.Nautilus$" },
	float = true,
})

hl.window_rule({
	name = "size-nautilus",
	match = { class = "^org.gnome.Nautilus$" },
	size = "1200 800",
})

hl.window_rule({
	name = "center-nautilus",
	match = { class = "^org.gnome.Nautilus$" },
	center = true,
})

hl.window_rule({
	name = "no-max-size-nautilus",
	match = { class = "^org.gnome.Nautilus$" },
	no_max_size = true,
})

hl.config({
	debug = {
		disable_logs = false,
	},
})
