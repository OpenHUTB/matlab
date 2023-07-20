classdef(ConstructOnLoad)WindowClickedEventData<event.EventData





    properties

ClickType

    end

    methods

        function data=WindowClickedEventData(clickType)

            data.ClickType=clickType;

        end

    end

end