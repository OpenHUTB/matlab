classdef snubber<int32



    enumeration
        exclude(0)
        include(1)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('exclude')='physmod:ee:library:comments:enum:converters:snubber:map_None';
            map('include')='physmod:ee:library:comments:enum:converters:snubber:map_RCSnubber';
        end
    end
end
