classdef statorparam<int32



    enumeration
        parametric(1)
        tabulated(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('parametric')='physmod:ee:library:comments:enum:srm:statorparam:map_SpecifyParametricData';
            map('tabulated')='physmod:ee:library:comments:enum:srm:statorparam:map_SpecifyTabulatedFluxData';
        end
    end
end

