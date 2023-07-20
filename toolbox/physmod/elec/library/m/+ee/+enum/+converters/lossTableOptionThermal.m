classdef lossTableOptionThermal<int32



    enumeration
        currentTemp(1)
        currentVoltageTemp(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('currentTemp')='physmod:ee:library:comments:enum:converters:lossTableOptionThermal:map_CurrentTemp';
            map('currentVoltageTemp')='physmod:ee:library:comments:enum:converters:lossTableOptionThermal:map_CurrentVoltageTemp';
        end
    end
end
