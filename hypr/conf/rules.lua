hl.window_rule({
    match = { class = "kitty" },
    opacity = "0.9 0.9",
})

hl.window_rule({
    match = { float = true },
    opacity = "0.9 0.9",
})

hl.window_rule({
    match = { class = "kitty" },
    animation = "slide left",
})

hl.window_rule({
    match = { class = "xwaylandvideobridge" },

    no_initial_focus = true,
    no_focus = true,
    no_anim = true,
    no_blur = true,

    max_size = { 1, 1 },
    opacity = "0.0 override",
})
