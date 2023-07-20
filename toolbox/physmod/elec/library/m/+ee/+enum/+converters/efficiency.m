classdef efficiency<int32



    enumeration
        constant(1)
        tabulated(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('constant')='physmod:ee:library:comments:enum:converters:efficiency:map_Constant';
            map('tabulated')='physmod:ee:library:comments:enum:converters:efficiency:map_Tabulated';
        end
    end
end
