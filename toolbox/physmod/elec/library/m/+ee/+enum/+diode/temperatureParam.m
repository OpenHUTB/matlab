classdef temperatureParam<int32





    enumeration
        off(1)
        iv(2)
        saturation(3)
        egap(4)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('off')='physmod:ee:library:comments:enum:diode:temperatureParam:map_NoneUseCharacteristicsAtParameterMeasurementTemperature';
            map('iv')='physmod:ee:library:comments:enum:diode:temperatureParam:map_UseAnIVDataPointAtSecondMeasurementTemperature';
            map('saturation')='physmod:ee:library:comments:enum:diode:temperatureParam:map_SpecifySaturationCurrentAtSecondMeasurementTemperature';
            map('egap')='physmod:ee:library:comments:enum:diode:temperatureParam:map_SpecifyTheEnergyGapEG';
        end
    end
end
