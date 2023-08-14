classdef numberOfTerminals<int32



    enumeration
        three(1)
        four(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('three')='physmod:ee:library:comments:enum:mosfet:numberOfTerminals:map_Three';
            map('four')='physmod:ee:library:comments:enum:mosfet:numberOfTerminals:map_Four';
        end
    end
end