classdef translationalPowerSensorType<int32




    enumeration
        instantaneous(1)
        period(2)
        vibration(3)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('instantaneous')='physmod:sdl:library:enum:PowerInstantaneous';
            map('period')='physmod:sdl:library:enum:PowerPeriod';
            map('vibration')='physmod:sdl:library:enum:PowerVibration';
        end
    end
end
