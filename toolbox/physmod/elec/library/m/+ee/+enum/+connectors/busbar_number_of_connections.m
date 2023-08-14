classdef busbar_number_of_connections<int32




    enumeration
        one(1)
        two(2)
        three(3)
        four(4)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('one')='physmod:ee:library:comments:enum:connectors:busbar_number_of_connections:map_one';
            map('two')='physmod:ee:library:comments:enum:connectors:busbar_number_of_connections:map_two';
            map('three')='physmod:ee:library:comments:enum:connectors:busbar_number_of_connections:map_three';
            map('four')='physmod:ee:library:comments:enum:connectors:busbar_number_of_connections:map_four';
        end
    end
end