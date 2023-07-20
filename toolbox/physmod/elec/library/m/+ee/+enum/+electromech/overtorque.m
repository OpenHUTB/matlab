classdef overtorque<int32
    enumeration
        no(0)
        yes(1)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('no')='physmod:ee:library:comments:enum:electromech:overtorque:map_No';
            map('yes')='physmod:ee:library:comments:enum:electromech:overtorque:map_Yes';
        end
    end
end