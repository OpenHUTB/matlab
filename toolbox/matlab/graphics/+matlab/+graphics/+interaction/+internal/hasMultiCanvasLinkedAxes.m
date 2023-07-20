function isMultipleFigures=hasMultiCanvasLinkedAxes(linkAxesArray)










    isMultipleFigures=false;
    if(isempty(linkAxesArray))
        return;
    end

    nearestCanvasParent=ancestor(linkAxesArray(1),'matlab.ui.internal.mixin.CanvasHostMixin');
    for i=1:numel(linkAxesArray)
        if(ancestor(linkAxesArray(i),'matlab.ui.internal.mixin.CanvasHostMixin')~=nearestCanvasParent)
            isMultipleFigures=true;
            return;
        end
    end