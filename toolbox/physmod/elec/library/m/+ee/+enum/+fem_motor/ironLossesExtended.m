classdef ironLossesExtended<int32
    enumeration
        none(1)
        empirical(2)
        tabulated(3)
        tabulated3D(4)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('none')='physmod:ee:library:comments:enum:fem_motor:ironLossesExtended:map_None';
            map('empirical')='physmod:ee:library:comments:enum:fem_motor:ironLossesExtended:map_Empirical';
            map('tabulated')='physmod:ee:library:comments:enum:fem_motor:ironLossesExtended:map_Tabulated';
            map('tabulated3D')='physmod:ee:library:comments:enum:fem_motor:ironLossesExtended:map_Tabulated3D';
        end
    end
end