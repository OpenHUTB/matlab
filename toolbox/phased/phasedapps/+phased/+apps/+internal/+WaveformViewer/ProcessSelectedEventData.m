classdef(ConstructOnLoad)ProcessSelectedEventData<event.EventData

    properties
Index
Value
    end
    methods
        function data=ProcessSelectedEventData(index,process)
            data.Index=index;
            if nargin==2
                data.Value=process;
            end
        end
    end
end
