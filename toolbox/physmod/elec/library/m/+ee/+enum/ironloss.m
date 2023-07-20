classdef ironloss<int32
    enumeration
        none(1)
        empirical(2)
    end
    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('none')='physmod:ee:library:comments:enum:ironloss:map_None';
            map('empirical')='physmod:ee:library:comments:enum:ironloss:map_Empirical';
        end
    end
end
