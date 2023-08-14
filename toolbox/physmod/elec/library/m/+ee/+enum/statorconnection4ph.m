classdef statorconnection4ph<int32
    enumeration
        cross(1)
        square(2)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('cross')='physmod:ee:library:comments:enum:statorconnection4ph:map_Cross';
            map('square')='physmod:ee:library:comments:enum:statorconnection4ph:map_Square';
        end
    end
end
