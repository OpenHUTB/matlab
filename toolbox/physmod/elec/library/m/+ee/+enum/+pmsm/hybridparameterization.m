classdef hybridparameterization<int32
    enumeration
        constant(1)
        tabulated(2)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('constant')='physmod:ee:library:comments:enum:pmsm:hybridparameterization:map_ConstantLdLqLmfLfAndPM';
            map('tabulated')='physmod:ee:library:comments:enum:pmsm:hybridparameterization:map_TabulatedLdLqLmfLfAndPM';
        end
    end
end
