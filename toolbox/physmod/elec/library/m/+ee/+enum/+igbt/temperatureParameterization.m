classdef temperatureParameterization<int32




    enumeration
        none(1)
        IcesVce(2)
        VceEG(3)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('none')='physmod:ee:library:comments:enum:igbt:temperatureParameterization:map_NoneSimulateAtParameterMeasurementTemperature';
            map('IcesVce')='physmod:ee:library:comments:enum:igbt:temperatureParameterization:map_SpecifyIcesAndVcesatAtSecondMeasurementTemperature';
            map('VceEG')='physmod:ee:library:comments:enum:igbt:temperatureParameterization:map_SpecifyVcesatAtSecondMeasurementTemperatureEnergyGapEG';
        end
    end
end