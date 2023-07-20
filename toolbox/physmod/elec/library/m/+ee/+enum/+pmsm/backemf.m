classdef backemf<int32
    enumeration
        trapezoidflux(1)
        trapezoidbackemf(2)
        tabulatedflux(3)
        tabulatedbackemf(4)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('trapezoidflux')='physmod:ee:library:comments:enum:pmsm:backemf:map_PerfectTrapezoidSpecifyMaximumFluxLinkage';
            map('trapezoidbackemf')='physmod:ee:library:comments:enum:pmsm:backemf:map_PerfectTrapezoidSpecifyMaximumRotorInducedBackEmf';
            map('tabulatedflux')='physmod:ee:library:comments:enum:pmsm:backemf:map_TabulatedSpecifyFluxPartialDerivativeWithRespectToRotorAn';
            map('tabulatedbackemf')='physmod:ee:library:comments:enum:pmsm:backemf:map_TabulatedSpecifyRotorInducedBackEmfAsAFunctionOfRotorAngl';
        end
    end
end
