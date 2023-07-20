classdef(ConstructOnLoad)RGBLimitsEventData<event.EventData





    properties

Red
Green
Blue

    end

    methods

        function data=RGBLimitsEventData(r,g,b)

            data.Red=r;
            data.Green=g;
            data.Blue=b;

        end

    end

end