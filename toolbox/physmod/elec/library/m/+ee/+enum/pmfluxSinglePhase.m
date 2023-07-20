classdef pmfluxSinglePhase<int32






    enumeration
        fluxlinkage(1)
        backemfconstant(2)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('fluxlinkage')='physmod:ee:library:comments:enum:pmflux:map_SpecifyFluxLinkage';
            map('backemfconstant')='physmod:ee:library:comments:enum:pmflux:map_SpecifyBackEMFConstant';
        end
    end
end
