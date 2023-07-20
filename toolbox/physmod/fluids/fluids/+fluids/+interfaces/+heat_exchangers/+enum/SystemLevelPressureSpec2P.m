classdef SystemLevelPressureSpec2P<int32





    enumeration
        InletPressure(1)
        SaturationTemperature(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('InletPressure')='Inlet pressure';
            map('SaturationTemperature')='Pressure at specified saturation temperature';
        end
    end
end