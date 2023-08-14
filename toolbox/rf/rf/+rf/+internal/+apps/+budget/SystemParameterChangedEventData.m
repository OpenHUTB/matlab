classdef(ConstructOnLoad)SystemParameterChangedEventData<event.EventData
    properties
Name
Value
    end

    methods
        function data=SystemParameterChangedEventData(name,value)
            data.Name=name;
            data.Value=value;
        end
    end
end
