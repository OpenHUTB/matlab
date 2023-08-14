classdef(ConstructOnLoad)ProcessTypeEventData<event.EventData

    properties
Index
Value
    end
    methods
        function data=ProcessTypeEventData(index,value)
            data.Index=index;
            data.Value=value;
        end
    end
end