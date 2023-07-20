classdef dqparameterization<int32
    enumeration
        constant(1)
        tabulated(2)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('constant')='physmod:ee:library:comments:enum:dqparameterization:map_ConstantLdAndLq';
            map('tabulated')='physmod:ee:library:comments:enum:dqparameterization:map_TabulatedLdAndLq';
        end
    end
end
