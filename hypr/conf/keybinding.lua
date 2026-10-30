local mainMod = "SUPER"
local scriptsPath = "~/.config/hypr/scripts"

hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("thunar"))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(scriptsPath .. "/wofi.sh"))

hl.bind(mainMod .. " + SHIFT + C",
    hl.dsp.exec_cmd(scriptsPath .. "/restart-waybar.sh"))

hl.bind(mainMod .. " + SHIFT + W",
    hl.dsp.exec_cmd(scriptsPath .. "/wlogout.sh"))

hl.bind(mainMod .. " + CTRL + L",
    hl.dsp.exec_cmd(scriptsPath .. "/lock.sh"))

hl.bind(mainMod .. " + SHIFT + S",
    hl.dsp.exec_cmd(scriptsPath .. "/hyprshot.sh"))

hl.bind(mainMod .. " + SHIFT + P",
    hl.dsp.exec_cmd(scriptsPath .. "/cliphist.sh"))

hl.bind(mainMod .. " + SHIFT + F",
    hl.dsp.exec_cmd(
        scriptsPath .. "/restart-awww.sh ~/.config/wallpapers/artix_wallpaper.png"
    ))

hl.bind(mainMod .. " + F",
    hl.dsp.window.fullscreen({
        mode = "fullscreen",
        action = "toggle",
    }))

hl.bind(mainMod .. " + C",
    hl.dsp.window.close())

hl.bind(mainMod .. " + M",
    hl.dsp.exit())

hl.bind(mainMod .. " + SHIFT + Tab",
    hl.dsp.window.float({
        action = "toggle",
    }))

hl.bind(mainMod .. " + P",
    hl.dsp.window.pseudo())

hl.bind(mainMod .. " + left",
    hl.dsp.focus({ direction = "l" }))

hl.bind(mainMod .. " + right",
    hl.dsp.focus({ direction = "r" }))

hl.bind(mainMod .. " + up",
    hl.dsp.focus({ direction = "u" }))

hl.bind(mainMod .. " + down",
    hl.dsp.focus({ direction = "d" }))

hl.bind(mainMod .. " + mouse:272",
    hl.dsp.window.drag(),
    { mouse = true })

hl.bind(mainMod .. " + mouse:273",
    hl.dsp.window.resize(),
    { mouse = true })

for i = 1, 10 do
    local key = i % 10

    hl.bind(mainMod .. " + " .. key,
        hl.dsp.focus({ workspace = i }))

    hl.bind(mainMod .. " + SHIFT + " .. key,
        hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + mouse_down",
    hl.dsp.focus({ workspace = "e+1" }))

hl.bind(mainMod .. " + mouse_up",
    hl.dsp.focus({ workspace = "e-1" }))
