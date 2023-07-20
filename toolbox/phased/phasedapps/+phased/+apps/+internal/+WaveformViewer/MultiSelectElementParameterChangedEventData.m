classdef(ConstructOnLoad)MultiSelectElementParameterChangedEventData<event.EventData



    properties
View
Name
Value
    end

    methods
        function data=MultiSelectElementParameterChangedEventData(view,name,value)
            data.View=view;
            data.Name=name;
            data.Value=value;
        end
    end
end
