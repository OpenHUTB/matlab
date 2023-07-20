classdef piston_parameterization<int32




    enumeration
        Angle(1)
        AngleThrottle(2)
        AngleThrottleVelocity(3)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('Angle')='physmod:sdl:library:enum:PistonAngle';
            map('AngleThrottle')='physmod:sdl:library:enum:PistonAngleThrottle';
            map('AngleThrottleVelocity')='physmod:sdl:library:enum:PistonAngleThrottleVelocity';
        end
    end
end
