classdef transformer_saturation<int32



    enumeration
        exclude(1)
        include(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('exclude')='physmod:ee:library:comments:enum:transformer_saturation:map_None';
            map('include')='physmod:ee:library:comments:enum:transformer_saturation:map_LookupTablePhiVersusI';
        end
    end
end

