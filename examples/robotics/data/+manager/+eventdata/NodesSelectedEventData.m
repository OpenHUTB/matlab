classdef(ConstructOnLoad)NodesSelectedEventData<event.EventData



    properties
ClickedGrid
    end

    methods
        function data=NodesSelectedEventData(grid)
            data.ClickedGrid=grid;
        end
    end
end

