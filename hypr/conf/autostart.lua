hl.on("hyprland.start", function()
    hl.exec_cmd(
        "waybar -c ~/.config/waybar/config -s ~/.config/waybar/style.css"
    )

    hl.exec_cmd("hypridle")
    hl.exec_cmd("~/.config/hypr/scripts/pipewire.sh")
    hl.exec_cmd("/usr/lib/xdg-desktop-portal-hyprland")
    hl.exec_cmd("wl-paste --watch cliphist store")
    hl.exec_cmd(
        "~/.config/hypr/scripts/restart-awww.sh ~/.config/wallpapers/artix_wallpaper.png"
    )

    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("udiskie")
    hl.exec_cmd("dbus-run-session xwaylandvideobridge")

    hl.exec_cmd("swaync")
end)
