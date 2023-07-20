classdef(ConstructOnLoad)ScrollWheelSpunEventData<event.EventData





    properties

VerticalScrollCount

    end

    methods

        function data=ScrollWheelSpunEventData(count)

            data.VerticalScrollCount=count;

        end

    end

end