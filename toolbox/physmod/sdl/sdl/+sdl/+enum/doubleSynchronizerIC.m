classdef doubleSynchronizerIC<int32

    enumeration
        lockedA(1)
        coneLockedA(2)
        unlocked(3)
        coneLockedB(4)
        lockedB(5)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('lockedA')='physmod:sdl:library:enum:ConeDogLockedA';
            map('coneLockedA')='physmod:sdl:library:enum:ConeLockedA';
            map('unlocked')='physmod:sdl:library:enum:AllClutchesUnlocked';
            map('coneLockedB')='physmod:sdl:library:enum:ConeLockedB';
            map('lockedB')='physmod:sdl:library:enum:ConeDogLockedB';
        end
    end
end