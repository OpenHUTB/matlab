classdef statorparam3phase<int32



    enumeration
        parametric(1)
        parametricgeo(2)
        tabulated(3)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('parametric')='physmod:ee:library:comments:enum:srm:statorparam3phase:map_SpecifyParametricData';
            map('parametricgeo')='physmod:ee:library:comments:enum:srm:statorparam3phase:map_SpecifyParametricAndGeometricData';
            map('tabulated')='physmod:ee:library:comments:enum:srm:statorparam3phase:map_SpecifyTabulatedFluxData';
        end
    end
end

