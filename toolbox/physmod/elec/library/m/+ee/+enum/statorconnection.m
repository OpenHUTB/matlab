classdef statorconnection<int32
    enumeration
        wye(1)
        delta(2)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('wye')='physmod:ee:library:comments:enum:statorconnection:map_Wye';
            map('delta')='physmod:ee:library:comments:enum:statorconnection:map_Delta';
        end
    end
end
