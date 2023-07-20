classdef windingconnection<int32



    enumeration
        Y(1)
        Yn(2)
        Yg(3)
        delta1(4)
        delta11(5)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('Y')='physmod:ee:library:comments:enum:windingconnection:map_WyeWithFloatingNeutral';
            map('Yn')='physmod:ee:library:comments:enum:windingconnection:map_WyeWithNeutralPort';
            map('Yg')='physmod:ee:library:comments:enum:windingconnection:map_WyeWithGroundedNeutral';
            map('delta1')='physmod:ee:library:comments:enum:windingconnection:map_Delta1O';
            map('delta11')='physmod:ee:library:comments:enum:windingconnection:map_Delta11O';
        end
    end
end

