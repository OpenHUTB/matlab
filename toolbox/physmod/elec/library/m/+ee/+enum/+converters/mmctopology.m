classdef mmctopology<int32



    enumeration
        halfbridge(1)
        fullbridge(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('halfbridge')='physmod:ee:library:comments:enum:converters:mmctopology:map_HalfBridge';
            map('fullbridge')='physmod:ee:library:comments:enum:converters:mmctopology:map_FullBridge';
        end
    end
end
