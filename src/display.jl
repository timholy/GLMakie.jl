function AbstractPlotting.backend_display(::GLBackend, scene::Scene)
    screen = global_gl_screen(size(scene), AbstractPlotting.use_display[])
    display_loading_image(screen)
    AbstractPlotting.backend_display(screen, scene)
    return screen
end

function AbstractPlotting.backend_display(screen::Screen, scene::Scene)
    empty!(screen)
    # So, the GLFW window events are not guarantee to fire
    # when we close a window, so we ensure this here!
    on(screen.window_open) do open
        events(scene).window_open[] = open
    end
    register_callbacks(scene, screen)
    pollevents(screen)
    insertplots!(screen, scene)
    pollevents(screen)
    return
end

"""
    scene2image(scene::Scene)

Buffers the `scene` in an image buffer.
"""
function scene2image(scene::Scene)
    old = WINDOW_CONFIG.pause_rendering[]
    try
        WINDOW_CONFIG.pause_rendering[] = true
        screen = global_gl_screen(size(scene), false)
        AbstractPlotting.backend_display(screen, scene)
        return AbstractPlotting.colorbuffer(screen), screen
    finally
        WINDOW_CONFIG.pause_rendering[] = old
    end
end

raw_io(io::IO) = io
raw_io(io::IOContext) = raw_io(io.io)

function AbstractPlotting.backend_show(::GLBackend, io::IO, m::MIME"image/png", scene::Scene)
    img, screen = scene2image(scene)
    FileIO.save(FileIO.Stream(FileIO.format"PNG", raw_io(io)), img)
    return screen
end

function AbstractPlotting.backend_show(::GLBackend, io::IO, m::MIME"image/jpeg", scene::Scene)
    img, screen = scene2image(scene)
    FileIO.save(FileIO.Stream(FileIO.format"JPEG", raw_io(io)), img)
    return screen
end
