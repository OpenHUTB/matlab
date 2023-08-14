function axesInteraction3d(axesId,cameraPosition,cameraTarget,cameraUpVector,cameraViewAngle)

    hAxes=mls.internal.handleID('toHandle',axesId);

    if ishghandle(hAxes)

        resetplotview(hAxes,'InitializeCurrentView');

        set(hAxes,'CameraPosition',cameraPosition);
        set(hAxes,'CameraTarget',cameraTarget);
        set(hAxes,'CameraUpVector',cameraUpVector);
        set(hAxes,'CameraViewAngle',cameraViewAngle);
    end

end

