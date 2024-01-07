classdef(ConstructOnLoad)AddOrDeleteRequestedEventData<event.EventData

    properties
Index
Type
    end


    methods
        function data=AddOrDeleteRequestedEventData(index,type)
            data.Index=index;
            if nargin==2
                data.Type=type;
            end
        end
    end
end
