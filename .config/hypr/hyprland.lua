---- ---------- Hyprland Configurations ----------
-- Converted from hyprland.conf (hyprlang) to Lua (Hyprland 0.55+).
-- Docs: https://wiki.hypr.land/Configuring/

local home = os.getenv("HOME")

-- ---------- Programs ----------
local terminal       = "kitty"
local app_launcher   = "wofi --show run"
-- local app_launcher = [[bemenu-run --fn "Ubuntu 11" --hp 6 --margin 6 --border-radius 6 -H 32 --no-overlap --ch 16 --cw 4]]
local file_manager   = "dolphin"
local browser        = "firefox"
-- Screenshots are copied to clipboard and not saved to system
local screenshot_fullscreen = "grim - | wl-copy"
local screenshot_selection  = [[grim -g "$(slurp -w 0)" - | wl-copy]]

local mainMod = "SUPER"

-- ---------- Monitors ----------
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/

-- hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
hl.monitor({ output = "DP-2", mode = "1920x1080@240", position = "0x0", scale = 1.0 })
-- hl.monitor({ output = "phitab-headless", mode = "1920x1200@60", position = "auto-left", scale = 1.5, transform = 0 })

-- ---------- Autostart ----------
hl.on("hyprland.start", function()
    -- Hyprland ecosystem (was one line chained with &; hl.exec_cmd is already async)
    hl.exec_cmd("waybar")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("hyprsunset -t 5000")

    hl.exec_cmd("systemctl start keyd.service") -- Keyd rebindings
    -- hl.exec_cmd("systemctl --user enable --now hyprpolkitagent.service") -- Polkit authentications
    hl.exec_cmd("/usr/lib/mate-polkit/polkit-mate-authentication-agent-1")
    hl.exec_cmd("wayvnc --config /home/perrorovic/.config/wayvnc/config") -- Wayvnc access
end)

-- ---------- Environment Variables ----------
-- See https://wiki.hypr.land/Configuring/Environment-variables/

-- Cursors
hl.env("XCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "xcursor-theme")

-- Rendering setups
hl.env("GDK_BACKEND", "wayland")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")
-- QT_QPA_PLATFORM was set twice in the original ("wayland", then "wayland;xcb");
-- the later value won, so only that one is kept.
hl.env("QT_QPA_PLATFORM", "wayland;xcb")

-- Ensure desktop environment is properly set
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_CONFIG_HOME", home .. "/.config")

-- Improve GTK and QT theme consistency
hl.env("GTK_THEME", "Adwaita-dark")
-- NOTE: the original line was `env = GTK2_RC_FILES=$HOME/.gtkrc-2.0` (an "=" instead of a comma),
-- which would not have set the variable correctly. Fixed here.
hl.env("GTK2_RC_FILES", home .. "/.gtkrc-2.0")
hl.env("GTK3_RC_FILES", home .. "/.config/gtk-3.0/settings.ini")
hl.env("GTK4_RC_FILES", home .. "/.config/gtk-4.0/settings.ini")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("QT_STYLE_OVERRIDE", "Adwaita-dark")

-- Improve window scaling & appearance
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")

-- Phiarch's environment (disabled)
-- hl.env("GDK_BACKEND", "wayland,x11")
-- hl.env("MOZ_ENABLE_WAYLAND", "1")
-- hl.env("MOZ_DISABLE_RDD_SANDBOX", "1")
-- hl.env("_JAVA_AWT_WM_NONREPARENTING", "1")
-- hl.env("LIBVA_DRIVER_NAME", "nvidia")
-- hl.env("GBM_BACKEND", "nvidia-drm")
-- hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
-- hl.env("WLR_NO_HARDWARE_CURSORS", "1")
-- hl.env("__NV_PRIME_RENDER_OFFLOAD", "1")
-- hl.env("__VK_LAYER_NV_optimus", "NVIDIA_only")
-- hl.env("PROTON_ENABLE_NGX_UPDATER", "1")
-- hl.env("NVD_BACKEND", "direct")
-- hl.env("__GL_GSYNC_ALLOWED", "0")
-- hl.env("__GL_VRR_ALLOWED", "0")
-- hl.env("WLR_DRM_NO_ATOMIC", "1")
-- hl.env("WLR_USE_LIBINPUT", "1")
-- hl.env("XWAYLAND_NO_GLAMOR", "1") -- Gamescope exclusive
-- hl.env("__GL_MaxFramesAllowed", "1")
-- hl.env("WLR_RENDERER_ALLOW_SOFTWARE", "1")
-- hl.env("WLR_RENDERER_DRM_BACKEND", "1")

-- Force electron-based app to use native Wayland instead of XWayland
hl.env("NVD_BACKEND", "direct")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")

-- NVIDIA CUDA 12.9.1-1 (disabled)
-- hl.env("PATH", "/opt/cuda/bin:" .. os.getenv("PATH"))
-- hl.env("LD_LIBRARY_PATH", "/opt/cuda/lib64:" .. (os.getenv("LD_LIBRARY_PATH") or ""))
-- hl.env("NVCC_CCBIN", "/usr/bin/gcc-12") -- if nvcc needs a specific gcc

-- ---------- Windows and Animations ----------
-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/

hl.config({
    general = {
        gaps_in = 3,          -- Between windows (per-window)
        gaps_out = 6,         -- To actual screen (per-workspace)
        gaps_workspaces = 0,  -- Does nothing, visible more spaces for animation

        border_size = 0,
        col = {
            -- active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            -- inactive_border = "rgba(595959aa)",
            active_border = "rgba(0DB7D4FF)",
            inactive_border = "rgba(31313600)",
        },

        resize_on_border = false, -- Set to true to resize windows by dragging borders and gaps
        -- Please see https://wiki.hypr.land/Configuring/Tearing/ before you turn this on
        allow_tearing = true,
        layout = "dwindle",
    },

    decoration = {
        rounding = 10,

        blur = {
            enabled = true,
            xray = true,
            special = false,
            new_optimizations = true,
            size = 2,
            passes = 4,
            brightness = 1,
            noise = 0.01,
            contrast = 1,
            popups = true,
            popups_ignorealpha = 0.6,
        },

        shadow = {
            enabled = true,
            range = 20,
            offset = "0 2", -- TODO: verify vec2 form against hl.meta.lua ({ 0, 2 } may be needed)
            render_power = 4,
            color = "rgba(0000002A)",
        },

        -- Window opacities
        active_opacity = 0.92,
        inactive_opacity = 0.82,
        fullscreen_opacity = 1.0,

        -- Dim
        dim_inactive = false,
        dim_strength = 0.1,
        dim_special = 0,
    },

    animations = {
        enabled = true,
    },
})

-- Curves (must be defined before the animations that use them)
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1} } })
hl.curve("md3_standard",   { type = "bezier", points = { {0.2, 0},     {0, 1} } })
hl.curve("md3_decel",      { type = "bezier", points = { {0.05, 0.7},  {0.1, 1} } })
hl.curve("md3_accel",      { type = "bezier", points = { {0.3, 0},     {0.8, 0.15} } })
hl.curve("overshot",       { type = "bezier", points = { {0.05, 0.9},  {0.1, 1.1} } })
hl.curve("crazyshot",      { type = "bezier", points = { {0.1, 1.5},   {0.76, 0.92} } })
hl.curve("hyprnostretch",  { type = "bezier", points = { {0.05, 0.9},  {0.1, 1.0} } })
hl.curve("menu_decel",     { type = "bezier", points = { {0.1, 1},     {0, 1} } })
hl.curve("menu_accel",     { type = "bezier", points = { {0.38, 0.04}, {1, 0.07} } })
hl.curve("easeInOutCirc",  { type = "bezier", points = { {0.85, 0},    {0.15, 1} } })
hl.curve("easeOutCirc",    { type = "bezier", points = { {0, 0.55},    {0.45, 1} } })
hl.curve("easeOutExpo",    { type = "bezier", points = { {0.16, 1},    {0.3, 1} } })
hl.curve("softAcDecel",    { type = "bezier", points = { {0.26, 0.26}, {0.15, 1} } })
hl.curve("md2",            { type = "bezier", points = { {0.4, 0},     {0.2, 1} } }) -- use with .2s duration

-- Animations
hl.animation({ leaf = "windows",          enabled = true, speed = 3,   bezier = "md3_decel", style = "popin 60%" })
hl.animation({ leaf = "windowsIn",        enabled = true, speed = 3,   bezier = "md3_decel", style = "popin 60%" })
hl.animation({ leaf = "windowsOut",       enabled = true, speed = 3,   bezier = "md3_accel", style = "popin 60%" })
hl.animation({ leaf = "border",           enabled = true, speed = 10,  bezier = "default" })
hl.animation({ leaf = "fade",             enabled = true, speed = 3,   bezier = "md3_decel" })
-- hl.animation({ leaf = "layers",        enabled = true, speed = 2,   bezier = "md3_decel", style = "slide" })
hl.animation({ leaf = "layersIn",         enabled = true, speed = 3,   bezier = "menu_decel", style = "slide" })
hl.animation({ leaf = "layersOut",        enabled = true, speed = 1.6, bezier = "menu_accel" })
hl.animation({ leaf = "fadeLayersIn",     enabled = true, speed = 2,   bezier = "menu_decel" })
hl.animation({ leaf = "fadeLayersOut",    enabled = true, speed = 4.5, bezier = "menu_accel" })
hl.animation({ leaf = "workspaces",       enabled = true, speed = 12,  bezier = "menu_decel", style = "slide" })
-- hl.animation({ leaf = "workspaces",    enabled = true, speed = 2.5, bezier = "softAcDecel", style = "slide" })
-- hl.animation({ leaf = "workspaces",    enabled = true, speed = 7,   bezier = "menu_decel", style = "slidefade 15%" })
-- hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "md3_decel", style = "slidefadevert 15%" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3,   bezier = "md3_decel", style = "slidevert" })

-- ---------- Dwindle Layouts and Miscs ----------
hl.config({
    dwindle = {
        preserve_split = true, -- You probably want this
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = 0,  -- 0 or 1 disables the anime mascot wallpapers
        disable_hyprland_logo = true,
    },
})

-- ---------- Input and Gestures ----------
hl.config({
    input = {
        kb_layout = "us",
        kb_variant = "",
        kb_model = "",
        kb_options = "",
        kb_rules = "",
        follow_mouse = 1,
        sensitivity = -0.5,
        touchpad = {
            natural_scroll = false,
        },
    },
})

-- ---------- Keybindings ----------
-- See https://wiki.hypr.land/Configuring/Basics/Binds/

-- Hyprland actions
hl.bind(mainMod .. " + Q", hl.dsp.window.close())                                          -- Close current window
hl.bind(mainMod .. " + S", hl.dsp.window.float({ action = "toggle" }))                    -- Toggle floating
hl.bind(mainMod .. " + A", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" })) -- Fullscreen

-- Applications
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(app_launcher))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(file_manager))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("elecwhat --toggle")) -- WhatsApp alternative

-- Screenshots
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd(screenshot_fullscreen))
hl.bind(mainMod .. " + Shift_R + S", hl.dsp.exec_cmd(screenshot_selection))

-- Dwindle functions
-- hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
-- hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

-- Whisper keybinds
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("~/.config/hypr/whisper-transcriber.sh --copy"))   -- saved to clipboard
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("~/.config/hypr/whisper-transcriber.sh --cancel"))  -- cancel the transcriber
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("~/.config/hypr/whisper-transcriber.sh --type")) -- typed to field

-- Claude TTS
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("~/.config/hypr/claude-stream-tts.sh --skip")) -- skip tts

-- Spotify keybinds
hl.bind(mainMod .. " + backslash",    hl.dsp.exec_cmd("~/.config/hypr/spotify.sh -pp"))
hl.bind(mainMod .. " + bracketleft",  hl.dsp.exec_cmd("~/.config/hypr/spotify.sh -p"))
hl.bind(mainMod .. " + bracketright", hl.dsp.exec_cmd("~/.config/hypr/spotify.sh -n"))
hl.bind(mainMod .. " + equal",        hl.dsp.exec_cmd("~/.config/hypr/spotify.sh -vu"))
hl.bind(mainMod .. " + minus",        hl.dsp.exec_cmd("~/.config/hypr/spotify.sh -vd"))

-- Audio keybinds
hl.bind(mainMod .. " + BackSpace", hl.dsp.exec_cmd("~/.config/hypr/cycle-audio.sh"))            -- cycle audio output
hl.bind(mainMod .. " + Delete",    hl.dsp.exec_cmd("~/.config/hypr/volume-control.sh -o m"))    -- toggle audio mute
hl.bind(mainMod .. " + Next",  hl.dsp.exec_cmd("~/.config/hypr/volume-control.sh -o d"), { repeating = true }) -- volume down
hl.bind(mainMod .. " + Prior", hl.dsp.exec_cmd("~/.config/hypr/volume-control.sh -o i"), { repeating = true }) -- volume up

-- Move focus between windows
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.focus({ direction = "down" }))

-- Move focus between workspaces (relative)
hl.bind(mainMod .. " + l", hl.dsp.focus({ workspace = "r+1" }), { description = "change active workspace forwards" })
hl.bind(mainMod .. " + h", hl.dsp.focus({ workspace = "r-1" }), { description = "change active workspace backwards" })

-- Switch workspaces / move active window to a workspace (1-10, key 0 = workspace 10)
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = tostring(i) }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = tostring(i), follow = true }))
end

-- Scroll through workspaces (disabled)
-- hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
-- hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mouse dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true }) -- Move window
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true }) -- Resize window

-- ---------- Window and Workspace Rules ----------
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- Check window properties with `hyprctl clients`.
--
-- NOTE: many rules in the original were only `match:float true, match:...` with NO effect.
-- `match:float` is a condition (window is already floating), not "make it float", so those
-- did nothing. They're kept below as commented-out rules with `float = true` in case that
-- was the intent; uncomment the ones you want.

-- hl.window_rule({ match = { class = ".*" }, no_blur = true })   -- (was reported to enable blur)

-- Dialogs / popups (no effect in original)
-- hl.window_rule({
--     match = { title = "^(.*dialog.*|.*popup.*|.*error.*|.*warning.*|.*preferences.*|.*settings.*|.*properties.*)$" },
--     float = true,
-- })

-- General floating & centered windows
-- hl.window_rule({
--     match = { title = "^(Open File|Select a File|Choose wallpaper|Open Folder|Save As|Library|File Upload).*$" },
--     float = true,
-- })
hl.window_rule({
    name = "file-dialogs-size",
    match = { title = "^(Open File|Select a File|Choose wallpaper|Open Folder|Save As|Library|File Upload).*$" },
    size = { "monitor_w * 0.25", "monitor_h * 0.25" }, -- original: `size 25%`
})

-- Application launcher (wofi)
-- (original `match:float true, match:class wofi` had no effect)
hl.window_rule({
    name = "wofi",
    match = { class = "wofi" },
    size = { "monitor_w * 0.5", "monitor_h * 0" }, -- original: `size 50% 0%`
    move = { "monitor_w * 0.25", "monitor_h * 0.09" }, -- original: `move 25% 9%`
    stay_focused = true,
})

-- File manager (Dolphin)
-- hl.window_rule({
--     match = { title = "^(Copying|Already Exists as Folder|Folder Already Exists).*$" },
--     float = true,
-- })
hl.window_rule({
    name = "dolphin-dialogs-size",
    match = { title = "^(Copying|Already Exists as Folder|Folder Already Exists|File Already Exists).*$" },
    size = { "monitor_w * 0.25", "monitor_h * 0.25" },
})
hl.window_rule({
    name = "dolphin-dialogs-center",
    match = { title = "^(Copying|Already Exists as Folder|Folder Already Exists|File Already Exists|Choose Application).*$" },
    center = true,
})
hl.window_rule({
    name = "dolphin-copying-no-focus",
    match = { title = "^(Copying).*$" },
    no_initial_focus = true,
})
hl.window_rule({
    name = "dolphin-dialogs-stay-focused",
    match = { title = "^(Already Exists as Folder|Folder Already Exists|Choose Application).*$" },
    stay_focused = true,
})

-- Steam and Pavucontrol pop-ups
-- hl.window_rule({ match = { class = "^(steam)$" }, float = true })
hl.window_rule({
    name = "steam-maximize",
    match = { title = "Steam" },
    maximize = true,
})
-- hl.window_rule({ match = { class = "^(org.pulseaudio.pavucontrol)$" }, float = true })
hl.window_rule({
    name = "pavucontrol-size",
    match = { class = "^(org.pulseaudio.pavucontrol)$" },
    size = { "monitor_w * 0.73", "monitor_h * 0.72" },
})

-- Video player (VLC)
-- hl.window_rule({ match = { class = "^(vlc)$" }, float = true })
hl.window_rule({
    name = "vlc-maximize",
    match = { class = "^(vlc)$" },
    maximize = true,
})

-- Picture-in-Picture
hl.window_rule({
    name = "pip",
    match = { title = "^(Picture(-| )in(-| )[Pp]icture)$" },
    keep_aspect_ratio = true,
    move = { "monitor_w * 0.73", "monitor_h * 0.72" },
    size = { "monitor_w * 0.25", "monitor_h * 0.25" },
    pin = true,
    -- float = true, -- original only matched on float, never set it; uncomment if intended
})
-- Alternate PiP title regex (had no effect in original):
-- hl.window_rule({ match = { title = [[^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$]] }, float = true })

-- Tearing (disabled)
-- hl.window_rule({ match = { class = [[.*\.exe]] }, immediate = true })
-- hl.window_rule({ match = { class = "(steam_app)" }, immediate = true })
-- hl.window_rule({ match = { class = "(Godot)" }, immediate = true })

-- No shadow for floating windows
-- (original comment said "tiled windows" but the rule matched float = yes; kept as written)
hl.window_rule({
    name = "no-shadow-floating",
    match = { float = true },
    no_shadow = true,
})

