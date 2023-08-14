classdef lagOffOn<int32




    enumeration
        off(0)
        on(1)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('off')='physmod:sdl:library:enum:LagOff';
            map('on')='physmod:sdl:library:enum:LagOn';
        end
    end
end
