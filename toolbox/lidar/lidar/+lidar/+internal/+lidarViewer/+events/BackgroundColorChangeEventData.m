classdef(ConstructOnLoad)BackgroundColorChangeEventData<event.EventData




    properties
Color
    end

    methods
        function data=BackgroundColorChangeEventData(c)
            data.Color=c;
        end
    end
end