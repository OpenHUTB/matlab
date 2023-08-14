classdef transformer_magnetizingReactance<int32



    enumeration
        exclude(1)
        include(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('exclude')='physmod:ee:library:comments:enum:transformer_magnetizingReactance:map_Exclude';
            map('include')='physmod:ee:library:comments:enum:transformer_magnetizingReactance:map_Include';
        end
    end
end

