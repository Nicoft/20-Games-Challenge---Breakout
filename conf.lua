-- conf.lua
function love.conf(t)
    -- Set the window title
    t.window.title = "Breakout"

    -- Set the window size
    t.window.width = 800
    t.window.height = 600

    -- Enable or disable fullscreen
    t.window.fullscreen = false

    -- Enable or disable vertical sync (vsync)
    t.window.vsync = 0

    -- Enable or disable resizable window
    t.window.resizable = false

    -- Set the default console visibility (useful for debugging on Windows)
    t.console = true
end