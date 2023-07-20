classdef(ConstructOnLoad)MouseEventData<event.EventData



    properties
MouseData
    end

    methods
        function data=MouseEventData(mouseData)
            data.MouseData=mouseData.MouseData;
        end
    end
end