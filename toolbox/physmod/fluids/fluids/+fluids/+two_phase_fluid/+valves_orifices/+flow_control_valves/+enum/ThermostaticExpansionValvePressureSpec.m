classdef ThermostaticExpansionValvePressureSpec<int32





    enumeration
        Pressure(1)
        SaturationTemperature(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Pressure')='Specified pressure';
            map('SaturationTemperature')='Pressure at specified saturation temperature';
        end
    end
end