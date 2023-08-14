classdef pmfluxlin<int32
    enumeration
        fluxlinkage(1)
        forceconstant(2)
        backemfconstant(3)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('fluxlinkage')='physmod:ee:library:comments:enum:pmfluxlin:map_SpecifyFluxLinkage';
            map('forceconstant')='physmod:ee:library:comments:enum:pmfluxlin:map_SpecifyForceConstant';
            map('backemfconstant')='physmod:ee:library:comments:enum:pmfluxlin:map_SpecifyBackEMFConstant';
        end
    end
end
