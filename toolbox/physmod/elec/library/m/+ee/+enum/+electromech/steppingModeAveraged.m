classdef steppingModeAveraged<int32



    enumeration
        fullStep(0)
        halfStep(1)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('fullStep')='physmod:ee:library:comments:enum:electromech:steppingModeAveraged:map_Full';
            map('halfStep')='physmod:ee:library:comments:enum:electromech:steppingModeAveraged:map_Half';
        end
    end
end