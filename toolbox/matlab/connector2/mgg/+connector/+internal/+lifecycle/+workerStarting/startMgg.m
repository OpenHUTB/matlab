function startMgg()

    mls.internal.feature('graphicsAndGuis','on');
    if usejava('swing')&&~isempty(which('com.mathworks.matlabserver.jcp.GraphicsAndGuis.setFocusTrackingEnabled'))
        feval('com.mathworks.matlabserver.jcp.GraphicsAndGuis.setFocusTrackingEnabled',true);
    end
end
