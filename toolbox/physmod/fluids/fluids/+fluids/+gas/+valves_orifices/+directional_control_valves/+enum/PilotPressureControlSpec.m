classdef PilotPressureControlSpec<int32





    enumeration
        PressureDifference(1)
        PressureX(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('PressureDifference')='Pressure difference of port X relative to port A';
            map('PressureX')='Gauge pressure at port X';
        end
    end
end