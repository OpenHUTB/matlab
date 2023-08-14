classdef zigzagconfiguration<int32



    enumeration
        Delta(1)
        Wye(2)
        WyeAndDelta(3)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('Delta')='physmod:ee:library:comments:enum:zigzagconnection:map_Delta';
            map('Wye')='physmod:ee:library:comments:enum:zigzagconnection:map_Wye';
            map('WyeAndDelta')='physmod:ee:library:comments:enum:zigzagconnection:map_WyeAndDelta';
        end
    end
end

