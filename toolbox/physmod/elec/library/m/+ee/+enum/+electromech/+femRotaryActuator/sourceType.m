classdef sourceType<int32
    enumeration
        voltage(1)
        current(2)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('voltage')='physmod:ee:library:comments:enum:electromech:femRotaryActuator:sourceType:map_Voltage';
            map('current')='physmod:ee:library:comments:enum:electromech:femRotaryActuator:sourceType:map_Current';
        end
    end
end