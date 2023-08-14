classdef model_inertia<int32




    enumeration
        off(0)
        on(1)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('off')='physmod:sdl:library:enum:InertiaOff';
            map('on')='physmod:sdl:library:enum:InertiaOn';
        end
    end
end
