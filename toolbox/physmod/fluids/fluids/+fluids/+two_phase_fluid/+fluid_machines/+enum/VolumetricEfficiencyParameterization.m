classdef VolumetricEfficiencyParameterization<int32





    enumeration
        Analytical(1)
        Tabulated(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Analytical')='Analytical';
            map('Tabulated')='Tabulated';
        end
    end
end