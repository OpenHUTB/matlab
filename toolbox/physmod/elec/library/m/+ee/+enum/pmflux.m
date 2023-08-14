classdef pmflux<int32
    enumeration
        fluxlinkage(1)
        torqueconstant(2)
        backemfconstant(3)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('fluxlinkage')='physmod:ee:library:comments:enum:pmflux:map_SpecifyFluxLinkage';
            map('torqueconstant')='physmod:ee:library:comments:enum:pmflux:map_SpecifyTorqueConstant';
            map('backemfconstant')='physmod:ee:library:comments:enum:pmflux:map_SpecifyBackEMFConstant';
        end
    end
end
