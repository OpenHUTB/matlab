classdef TubePressureLossSpec2P<int32





    enumeration
        LossCoeff(1)
        Haaland(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('LossCoeff')='Pressure loss coefficient';
            map('Haaland')='Correlation for flow inside tubes';
        end
    end
end