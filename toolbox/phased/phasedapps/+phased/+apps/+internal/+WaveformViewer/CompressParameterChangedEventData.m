classdef(ConstructOnLoad)CompressParameterChangedEventData<event.EventData

    properties
Index
Name
Value
    end
    methods
        function data=CompressParameterChangedEventData(index,name,value)
            data.Index=index;
            if nargin>1
                data.Name=name;
                if nargin==3
                    data.Value=value;
                end
            end
        end
    end
end