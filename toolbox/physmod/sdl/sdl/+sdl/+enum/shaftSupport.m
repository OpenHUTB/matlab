classdef shaftSupport<int32

    enumeration
        clamp(1)
        pin(2)
        free(3)
        bearingMatrix(4)
        bearingMatrix_speed(5)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('clamp')='physmod:sdl:library:enum:Clamped';
            map('pin')='physmod:sdl:library:enum:Pinned';
            map('free')='physmod:sdl:library:enum:Free';
            map('bearingMatrix')='physmod:sdl:library:enum:BearingMatrix';
            map('bearingMatrix_speed')='Speed-dependent bearing matrix';
        end
    end
end



