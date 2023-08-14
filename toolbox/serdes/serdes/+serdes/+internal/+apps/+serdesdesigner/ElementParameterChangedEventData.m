classdef(ConstructOnLoad)ElementParameterChangedEventData<event.EventData




    properties
Index
Name
Value
    end

    methods
        function data=ElementParameterChangedEventData(index,name,value)
            data.Index=index;
            data.Name=name;
            data.Value=value;
        end
    end
end
