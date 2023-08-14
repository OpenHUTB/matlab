classdef loadRotation<int32




    enumeration
        circular(1)
        elliptical(2)
        tlu(3)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('circular')='physmod:sdl:library:enum:CircularRotation';
            map('elliptical')='physmod:sdl:library:enum:EllipticalRotation';
            map('tlu')='physmod:sdl:library:enum:TableLookup';
        end
    end
end
