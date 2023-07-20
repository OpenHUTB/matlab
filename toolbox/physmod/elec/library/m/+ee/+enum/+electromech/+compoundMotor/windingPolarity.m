classdef windingPolarity<int32
    enumeration
        cumulative(1)
        differential(2)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('cumulative')='physmod:ee:library:comments:enum:electromech:compoundMotor:windingPolarity:map_Cumulative';
            map('differential')='physmod:ee:library:comments:enum:electromech:compoundMotor:windingPolarity:map_Differential';
        end
    end
end