classdef compliance<int32




    enumeration
        off(0)
        on(1)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('off')='physmod:sdl:library:enum:ComplianceOff';
            map('on')='physmod:sdl:library:enum:ComplianceOn';
        end
    end
end
