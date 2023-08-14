classdef SystemLevelPressureSpecCondenser2P<int32





    enumeration
        InletPressure(1)
        CondensingTemperature(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('InletPressure')='Inlet pressure';
            map('CondensingTemperature')='Saturation pressure at specified condensing temperature';
        end
    end
end