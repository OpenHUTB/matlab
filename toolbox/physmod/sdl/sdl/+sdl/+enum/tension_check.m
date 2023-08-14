classdef tension_check<int32




    enumeration
        off(0)
        on(1)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('off')='physmod:sdl:library:enum:TensionCheckOff';
            map('on')='physmod:sdl:library:enum:TensionCheckOn';
        end
    end
end
