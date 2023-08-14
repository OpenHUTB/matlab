classdef zerosequence<int32
    enumeration
        exclude(0)
        include(1)
    end
    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('exclude')='physmod:ee:library:comments:enum:park:zerosequence:map_Exclude';
            map('include')='physmod:ee:library:comments:enum:park:zerosequence:map_Include';
        end
    end
end
