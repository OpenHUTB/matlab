classdef(ConstructOnLoad)BackgroundColorChangeEventData<event.EventData





    properties
Color
    end

    methods
        function data=BackgroundColorChangeEventData(color)
            data.Color=color;
        end
    end
end