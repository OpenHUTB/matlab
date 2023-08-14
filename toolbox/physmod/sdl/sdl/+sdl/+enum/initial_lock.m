classdef initial_lock<int32




    enumeration
        unlocked(0)
        locked(1)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('unlocked')='physmod:sdl:library:enum:Unlocked';
            map('locked')='physmod:sdl:library:enum:Locked';
        end
    end
end