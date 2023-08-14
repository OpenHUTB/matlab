classdef clutchFault<int32




    enumeration
        lock(1)
        noPower(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('lock')='physmod:sdl:library:enum:FaultLock';
            map('noPower')='physmod:sdl:library:enum:FaultNoPower';
        end
    end
end
