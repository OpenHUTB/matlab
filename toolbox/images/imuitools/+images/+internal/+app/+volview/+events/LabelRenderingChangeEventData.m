

classdef(ConstructOnLoad)LabelRenderingChangeEventData<event.EventData
    properties
LabelIdx
Value
    end

    methods
        function data=LabelRenderingChangeEventData(selection,value)
            data.LabelIdx=selection;
            data.Value=value;
        end
    end
end
