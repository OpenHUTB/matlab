function[hFig,hContainer]=getContainers(hObj)
    hContainer=ancestor(hObj,'matlab.ui.internal.mixin.CanvasHostMixin');
    if isempty(hContainer)
        hFig=matlab.ui.Figure.empty;
    else
        if ishghandle(hContainer,'figure')
            hFig=hContainer;
        else
            hFig=ancestor(hContainer,'figure');
        end
    end
end
