classdef GenericEngineInputType<int32

    enumeration
        NormalizedThrottle(1)
        TorqueCommand(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('NormalizedThrottle')='physmod:sdl:library:enum:NormalizedThrottle';
            map('TorqueCommand')='physmod:sdl:library:enum:TorqueCommand';
        end
    end

end
