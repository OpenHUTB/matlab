classdef pilot_pressure_control_spec<int32





    enumeration
        pX(1)
        dp(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('pX')='Pressure at port X';
            map('dp')='Pressure differential (pX-pA)';
        end
    end
end