classdef directionality<int32



    enumeration
        unidirectional(0)
        bidirectional(1)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('unidirectional')='physmod:ee:library:comments:enum:converters:directionality:map_Unidirectional';
            map('bidirectional')='physmod:ee:library:comments:enum:converters:directionality:map_Bidirectional';
        end
    end
end
