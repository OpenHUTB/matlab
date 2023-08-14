classdef expParam<int32





    enumeration
        useTwo(1)
        useIsN(2)
        useIVIs(3)
        useIVN(4)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('useTwo')='physmod:ee:library:comments:enum:diode:expParam:map_UseTwoIVCurveDataPoints';
            map('useIsN')='physmod:ee:library:comments:enum:diode:expParam:map_UseParametersISAndN';
            map('useIVIs')='physmod:ee:library:comments:enum:diode:expParam:map_UseAnIVDataPointAndIS';
            map('useIVN')='physmod:ee:library:comments:enum:diode:expParam:map_UseAnIVDataPointAndN';
        end
    end
end
