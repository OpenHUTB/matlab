classdef(Hidden)InvisibleAxesEnterExitEventData<event.EventData





    properties
Axes
Direction
Primitive
    end

    methods
        function obj=InvisibleAxesEnterExitEventData(ax,prim,direction)
            obj.Axes=ax;
            obj.Primitive=prim;
            obj.Direction=direction;
        end
    end
end