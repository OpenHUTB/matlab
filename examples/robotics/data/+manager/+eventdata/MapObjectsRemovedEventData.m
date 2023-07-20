classdef(ConstructOnLoad)MapObjectsRemovedEventData<event.EventData



    properties
ClickedGrid
    end

    methods
        function data=MapObjectsRemovedEventData(grid)
            data.ClickedGrid=grid;
        end
    end
end

