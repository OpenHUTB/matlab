classdef synchronizerIC<int32

    enumeration
        unlocked(1)
        coneLocked(2)
        locked(3)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('unlocked')='physmod:sdl:library:enum:AllClutchesUnlocked';
            map('coneLocked')='physmod:sdl:library:enum:ConeLocked';
            map('locked')='physmod:sdl:library:enum:AllClutchesLocked';
        end
    end
end