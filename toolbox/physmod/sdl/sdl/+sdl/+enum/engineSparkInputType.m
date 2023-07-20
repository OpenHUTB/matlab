classdef engineSparkInputType<int32




    enumeration
        Const(1)
        Angle(2)
        Trigger(3)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Const')='physmod:sdl:library:enum:EngineSparkInputConst';
            map('Angle')='physmod:sdl:library:enum:EngineSparkInputAngle';
            map('Trigger')='physmod:sdl:library:enum:EngineSparkInputEvent';
        end
    end
end
