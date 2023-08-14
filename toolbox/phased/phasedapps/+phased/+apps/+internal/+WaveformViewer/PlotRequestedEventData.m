
classdef PlotRequestedEventData<event.EventData



    properties
Index
Type
    end

    methods
        function data=PlotRequestedEventData(index,type)
            data.Index=index;
            data.Type=type;
        end
    end
end