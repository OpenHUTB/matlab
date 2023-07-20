classdef PressureControlSpec<int32





    enumeration
        PressureDifferential(1)
        PressureA(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('PressureDifferential')='Pressure differential';
            map('PressureA')='Pressure at port A';
        end
    end
end