classdef mmcfidelity<int32



    enumeration
        detailed(1)
        equivalent_pwm(2)
        equivalent_waveform(3)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('detailed')='physmod:ee:library:comments:enum:converters:mmcfidelity:map_DetailedModel';
            map('equivalent_pwm')='physmod:ee:library:comments:enum:converters:mmcfidelity:map_EquivalentModelPWM';
            map('equivalent_waveform')='physmod:ee:library:comments:enum:converters:mmcfidelity:map_EquivalentModelWaveform';
        end
    end
end
