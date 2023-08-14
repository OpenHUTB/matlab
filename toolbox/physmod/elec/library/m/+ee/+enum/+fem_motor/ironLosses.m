classdef ironLosses<int32
    enumeration
        none(1)
        empirical(2)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('none')='physmod:ee:library:comments:enum:fem_motor:ironLossesExtended:map_None';
            map('empirical')='physmod:ee:library:comments:enum:fem_motor:ironLossesExtended:map_Empirical';
        end
    end
end