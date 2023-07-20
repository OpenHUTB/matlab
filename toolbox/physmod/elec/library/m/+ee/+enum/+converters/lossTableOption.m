classdef lossTableOption<int32



    enumeration
        current(1)
        currentVoltage(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('current')='physmod:ee:library:comments:enum:converters:lossTableOption:map_Current';
            map('currentVoltage')='physmod:ee:library:comments:enum:converters:lossTableOption:map_CurrentVoltage';
        end
    end
end
