classdef PropertiesEventData<event.EventData
    properties(SetAccess=private)
AxesIndex
ChangedProperty
OldPropertyValue
NewPropertyValue
    end

    methods
        function data=PropertiesEventData(index,whatChanged,oldValue,newValue)
            data.AxesIndex=index;
            data.ChangedProperty=whatChanged;
            data.OldPropertyValue=oldValue;
            data.NewPropertyValue=newValue;
        end
    end
end