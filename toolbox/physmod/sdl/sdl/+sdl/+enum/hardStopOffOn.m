classdef hardStopOffOn<int32

    enumeration
        off(0)
        on(1)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('off')='physmod:sdl:library:enum:HardStopOff';
            map('on')='physmod:sdl:library:enum:HardStopOn';
        end
    end
end



