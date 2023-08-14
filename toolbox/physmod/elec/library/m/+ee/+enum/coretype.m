classdef coretype<int32



    enumeration
        threelimb(1)
        fivelimb(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('threelimb')='physmod:ee:library:comments:enum:coretype:map_ThreephaseThreelimb';
            map('fivelimb')='physmod:ee:library:comments:enum:coretype:map_ThreephaseFivelimb';
        end
    end
end

