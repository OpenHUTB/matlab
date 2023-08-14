classdef max_tension<int32




    enumeration
        off(0)
        on(1)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('off')='physmod:sdl:library:enum:MaxTensionOff';
            map('on')='physmod:sdl:library:enum:MaxTensionOn';
        end
    end
end
