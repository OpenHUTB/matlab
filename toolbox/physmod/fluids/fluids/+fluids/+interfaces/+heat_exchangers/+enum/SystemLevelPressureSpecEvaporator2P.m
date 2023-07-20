classdef SystemLevelPressureSpecEvaporator2P<int32





    enumeration
        InletPressure(1)
        EvaporatingTemperature(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('InletPressure')='Inlet pressure';
            map('EvaporatingTemperature')='Saturation pressure at specified evaporating temperature';
        end
    end
end