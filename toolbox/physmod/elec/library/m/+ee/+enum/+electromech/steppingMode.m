classdef steppingMode<int32



    enumeration
        fullStep(0)
        halfStep(1)
        microStep(2)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('fullStep')='physmod:ee:library:comments:enum:electromech:steppingMode:map_Full';
            map('halfStep')='physmod:ee:library:comments:enum:electromech:steppingMode:map_Half';
            map('microStep')='physmod:ee:library:comments:enum:electromech:steppingMode:map_Micro';
        end
    end
end