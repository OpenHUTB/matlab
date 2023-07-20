classdef diodeModelType<int32




    enumeration
        pwl(1)
        tabulated(3)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('pwl')='physmod:ee:library:comments:enum:diode:modelType:map_PiecewiseLinear';
            map('tabulated')='physmod:ee:library:comments:enum:diode:modelType:map_Tabulated';
        end
    end
end
