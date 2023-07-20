classdef saturation<int32



    enumeration
        exclude(0)
        include(1)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('exclude')='physmod:ee:library:comments:enum:saturation:map_None';
            map('include')='physmod:ee:library:comments:enum:saturation:map_OpencircuitLookupTablevVersusI';
        end
    end
end

