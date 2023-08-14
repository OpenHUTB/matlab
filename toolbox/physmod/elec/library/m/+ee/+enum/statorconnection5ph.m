classdef statorconnection5ph<int32
    enumeration
        star(1)
        pentagon(2)
        pentacle(3)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('star')='physmod:ee:library:comments:enum:statorconnection5ph:map_Star';
            map('pentagon')='physmod:ee:library:comments:enum:statorconnection5ph:map_Pentagon';
            map('pentacle')='physmod:ee:library:comments:enum:statorconnection5ph:map_Pentacle';
        end
    end
end
