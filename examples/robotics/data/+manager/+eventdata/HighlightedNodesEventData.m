classdef HighlightedNodesEventData<event.EventData



    properties
GridData
    end

    methods
        function data=HighlightedNodesEventData(grid)
            data.GridData=grid;
        end
    end
end



