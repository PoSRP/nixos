hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE HYPRLAND_INSTANCE_SIGNATURE && systemctl --user start nixos-fake-graphical-session.target")
    hl.exec_cmd("waybar")
    hl.exec_cmd("~/.config/hypr/hyprpaper-rotator.sh")
    hl.exec_cmd("dropbox")
    hl.exec_cmd("mako")
    hl.exec_cmd("sh -c 'test -x ~/.config/hypr/battery-watcher.sh && exec ~/.config/hypr/battery-watcher.sh'")
    hl.exec_cmd("fcitx5 -d")
end)

hl.bind("switch:on:Lid Switch",  hl.dsp.exec_cmd("~/.config/hypr/lock-session.sh"),  { locked = true })
hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd("pkill -SIGUSR2 -x waybar"),        { locked = true })

hl.env("TERMINAL",             "kitty")
hl.env("QT_QPA_PLATFORMTHEME", "kde")
hl.env("QT_STYLE_OVERRIDE",    "breeze")

hl.config({ ecosystem = { no_update_news = true } })

hl.config({
    general = {
        gaps_in = 3,
        gaps_out = 6,
        border_size = 1,
        col = {
            active_border   = { colors = {"rgba(508080ee)", "rgba(204040ee)"}, angle = 90 },
            inactive_border = "rgba(595959aa)",
        },
        resize_on_border = true,
        allow_tearing    = false,
        layout           = "dwindle",
    },
    decoration = {
        rounding       = 5,
        rounding_power = 2,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = "rgba(1a1a1aee)",
        },
    },
    animations = { enabled = true },
    dwindle    = { preserve_split = true },
    master     = { new_status = "master" },
    misc = {
        force_default_wallpaper  = 0,
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
    },
    input = {
        kb_layout  = "us,dk",
        kb_variant = ",",
        kb_model   = "",
        kb_options = "grp:win_space_toggle",
        kb_rules   = "",
        repeat_delay  = 300,
        repeat_rate   = 80,
        follow_mouse  = 1,
        accel_profile = "flat",
        sensitivity   = 0.0,
        touchpad = {
            natural_scroll       = true,
            scroll_factor        = 0.4,
            disable_while_typing = true,
        },
    },
})

hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear",         { type = "bezier", points = { {0,    0},    {1,    1} } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5,  0.5},  {0.75, 1} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1,  1} } })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 7,    bezier = "quick" })

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

local mainMod    = "SUPER"
local terminal   = "kitty"
local fileManager = "thunar"
local menu       = "rofi -show drun"
local browser    = "firefox"
local editor     = "micro"

hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(terminal .. " -e " .. editor))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + K", hl.dsp.exit())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + Z", hl.dsp.window.fullscreen({ action = "toggle", mode = "maximized" }))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("~/.config/hypr/lock-session.sh"))

hl.bind(mainMod .. " + P",       hl.dsp.exec_cmd("hyprshot -m region --output-folder ~/Pictures/Screenshots"))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("hyprshot -m window --output-folder ~/Pictures/Screenshots"))
hl.bind(mainMod .. " + CTRL + P",  hl.dsp.exec_cmd("hyprshot -m output --current --output-folder ~/Pictures/Screenshots"))
hl.bind(mainMod .. " + ALT + P",   hl.dsp.exec_cmd([[sh -c 'd=$HOME/Pictures/Screenshots; mkdir -p "$d"; f="$d/$(date +%Y-%m-%d-%H%M%S)_all.png"; grim "$f" && wl-copy < "$f"']]))

hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.resize({ x = -40, y = 0,   relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.resize({ x = 40,  y = 0,   relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.resize({ x = 0,   y = -40, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.resize({ x = 0,   y = 40,  relative = true }), { repeating = true })

for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),       { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),      { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),        { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),    { locked = true })

hl.window_rule({
    name           = "suppress-maximize-events",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    match = { class = "Nsxiv" },
    tile  = true,
})

hl.window_rule({
    match  = { class = "battery-critical-alert" },
    float  = true,
    size   = "600 300",
    center = true,
    pin    = true,
})
