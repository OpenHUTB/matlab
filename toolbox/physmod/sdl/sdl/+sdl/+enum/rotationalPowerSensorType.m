classdef rotationalPowerSensorType<int32




    enumeration
        instantaneous(1)
        period(2)
        vibration(3)
        revolution(4)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('instantaneous')='physmod:sdl:library:enum:PowerInstantaneous';
            map('period')='physmod:sdl:library:enum:PowerPeriod';
            map('vibration')='physmod:sdl:library:enum:PowerVibration';
            map('revolution')='physmod:sdl:library:enum:PowerRevolution';
        end
    end
end
