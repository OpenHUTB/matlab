classdef voltageref<int32



    enumeration
        internal(1)
        external(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('internal')='physmod:ee:library:comments:enum:converters:voltageref:map_Internal';
            map('external')='physmod:ee:library:comments:enum:converters:voltageref:map_External';
        end
    end
end
