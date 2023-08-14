classdef modelType<int32




    enumeration
        pwl(1)
        exponential(2)
        tabulated(3)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('pwl')='physmod:ee:library:comments:enum:diode:modelType:map_PiecewiseLinear';
            map('exponential')='physmod:ee:library:comments:enum:diode:modelType:map_Exponential';
            map('tabulated')='physmod:ee:library:comments:enum:diode:modelType:map_Tabulated';
        end
    end
end
