function new_limits=zoomAroundPoint3D(orig_limits,pt,zoom_factor)
    import matlab.graphics.interaction.internal.zoom.zoomAxisAroundPoint

    xlimit=zoomAxisAroundPoint(orig_limits(1:2),pt(1),zoom_factor);
    ylimit=zoomAxisAroundPoint(orig_limits(3:4),pt(2),zoom_factor);
    zlimit=zoomAxisAroundPoint(orig_limits(5:6),pt(3),zoom_factor);

    new_limits=[xlimit,ylimit,zlimit];