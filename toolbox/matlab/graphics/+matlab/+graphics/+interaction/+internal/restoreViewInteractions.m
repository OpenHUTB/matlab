function restoreViewInteractions(hAxes)








    hContainer=ancestor(hAxes,'matlab.ui.internal.mixin.CanvasHostMixin','node');
    if(isscalar(hContainer))
        nearestCanvas=hContainer.getCanvas();
        if(isscalar(nearestCanvas)&&isprop(nearestCanvas,'ControlManager'))
            nearestCanvas.ControlManager.sendCommandToClient(hAxes,'restoreView');
        end
    end