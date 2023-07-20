classdef temperatureParameterization<int32




    enumeration
        none(1)
        simulation(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('none')='physmod:ee:library:comments:enum:temperatureParameterization:map_NoneSimulateAtParameterMeasurementTemperature';
            map('simulation')='physmod:ee:library:comments:enum:temperatureParameterization:map_ModelTemperatureDependence';
        end
    end
end