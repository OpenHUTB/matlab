classdef parameterization<int32
    enumeration
        constant(1)
        tabulated(2)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('constant')='physmod:ee:library:comments:enum:pmsm:parameterization:map_ConstantLdLqAndPM';
            map('tabulated')='physmod:ee:library:comments:enum:pmsm:parameterization:map_TabulatedLdLqAndPM';
        end
    end
end
