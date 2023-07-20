classdef PressureControlSpec<int32




    enumeration
        Differential(1)
        Gauge(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Differential')='Pressure differential';
            map('Gauge')='Gauge pressure at port A';
        end
    end
end