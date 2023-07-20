classdef ConnectionType<int32




    enumeration
        PS(1)
        Conserving(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('PS')='physmod:sdl:library:enum:PSMultiplePorts';
            map('conserving')='physmod:sdl:library:enum:ConservingPort';
        end
    end
end
