classdef PressureControlSpec<int32





    enumeration
        PressureDifference(1)
        PressureA(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('PressureDifference')='Pressure difference of port A relative to port B';
            map('PressureA')='Gauge pressure at port A';
        end
    end
end