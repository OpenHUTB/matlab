classdef elecTopology<int32
    enumeration
        shortShunt(1)
        longShunt(2)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('shortShunt')='physmod:ee:library:comments:enum:electromech:compoundMotor:elecTopology:map_ShortShunt';
            map('longShunt')='physmod:ee:library:comments:enum:electromech:compoundMotor:elecTopology:map_LongShunt';
        end
    end
end