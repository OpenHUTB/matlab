classdef filterconnection<int32



    enumeration
        Y(1)
        Yn(2)
        Yg(3)
        delta(4)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('Y')='physmod:ee:library:comments:enum:filterconnection:map_WyeWithFloatingNeutral';
            map('Yn')='physmod:ee:library:comments:enum:filterconnection:map_WyeWithNeutralPort';
            map('Yg')='physmod:ee:library:comments:enum:filterconnection:map_WyeWithGroundedNeutral';
            map('delta')='physmod:ee:library:comments:enum:filterconnection:map_Delta';
        end
    end
end

