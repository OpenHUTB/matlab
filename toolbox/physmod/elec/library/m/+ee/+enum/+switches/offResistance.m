classdef offResistance<int32



    enumeration
        no(1)
        yes(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('no')='physmod:ee:library:comments:enum:switches:offResistance:map_No';
            map('yes')='physmod:ee:library:comments:enum:switches:offResistance:map_Yes';
        end
    end
end