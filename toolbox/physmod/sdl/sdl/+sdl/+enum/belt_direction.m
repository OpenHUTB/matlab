classdef belt_direction<int32




    enumeration
        same(1)
        opposite(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('same')='physmod:sdl:library:enum:EndsSameDirection';
            map('opposite')='physmod:sdl:library:enum:EndsOppositeDirection';
        end
    end
end
