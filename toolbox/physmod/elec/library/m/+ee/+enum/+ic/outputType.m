classdef outputType<int32





    enumeration
        linear(1)
        quadratic(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('linear')='physmod:ee:library:comments:enum:ic:outputType:map_Linear';
            map('quadratic')='physmod:ee:library:comments:enum:ic:outputType:map_Quadratic';
        end
    end
end