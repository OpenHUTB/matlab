classdef pressure_control_spec<int32





    enumeration
        dp(1)
        pA(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('dp')='Pressure differential';
            map('pA')='Pressure at port A';
        end
    end
end