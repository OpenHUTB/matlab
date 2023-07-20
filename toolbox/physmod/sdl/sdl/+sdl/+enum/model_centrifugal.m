classdef model_centrifugal<int32




    enumeration
        off(0)
        on(1)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('off')='physmod:sdl:library:enum:CentrifugalForceOff';
            map('on')='physmod:sdl:library:enum:CentrifugalForceOn';
        end
    end
end
