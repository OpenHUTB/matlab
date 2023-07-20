classdef(ConstructOnLoad)NodesEditedEventData<event.EventData



    properties
NodesEditedData
    end

    methods
        function data=NodesEditedEventData(nodeData)
            data.NodesEditedData=nodeData;
        end
    end
end

