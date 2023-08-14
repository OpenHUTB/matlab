classdef(ConstructOnLoad)ROISelectedEventData<event.EventData





    properties

NumberSelected

    end

    methods

        function data=ROISelectedEventData(n)

            data.NumberSelected=n;

        end

    end

end