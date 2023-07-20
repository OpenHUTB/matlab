classdef deltaconnection<int32



    enumeration
        delta1(1)
        delta11(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('delta1')='physmod:ee:library:comments:enum:deltaconnection:map_Delta1O';
            map('delta11')='physmod:ee:library:comments:enum:deltaconnection:map_Delta11O';
        end
    end
end

