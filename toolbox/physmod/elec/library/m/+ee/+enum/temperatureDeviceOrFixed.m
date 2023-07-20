classdef temperatureDeviceOrFixed<int32




    enumeration
        Device(1)
        Fixed(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('Device')='physmod:ee:library:comments:enum:temperatureDeviceOrFixed:map_DeviceTemperature';
            map('Fixed')='physmod:ee:library:comments:enum:temperatureDeviceOrFixed:map_FixedTemperature';
        end
    end
end
