classdef FanMechanicalPowerSpec<int32




    enumeration
        Efficiency(1)
        Power(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Efficiency')='Fan efficiency';
            map('Power')='Brake power';
        end
    end
end
