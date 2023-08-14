classdef thyristorModelType<int32




    enumeration
        equations(1)
        tabulated(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('equations')='physmod:ee:library:comments:enum:semiconductors:thyristorModelType:map_FundamentalNonlinearEquations';
            map('tabulated')='physmod:ee:library:comments:enum:semiconductors:thyristorModelType:map_LookupTable';
        end
    end
end
