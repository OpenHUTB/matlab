classdef pilot_pressure_control_spec<int32





    enumeration
        dp(1)
        pX(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('dp')='Pressure differential (pX-pA)';
            map('pX')='Pressure at port X';
        end
    end
end