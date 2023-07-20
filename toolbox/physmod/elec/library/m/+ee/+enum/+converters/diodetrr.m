classdef diodetrr<int32



    enumeration
        trr_factor(1)
        trr(2)
        Qrr(3)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('trr_factor')='physmod:ee:library:comments:enum:converters:diodetrr:map_SpecifyStretchFactor';
            map('trr')='physmod:ee:library:comments:enum:converters:diodetrr:map_SpecifyReverseRecoveryTimeDirectly';
            map('Qrr')='physmod:ee:library:comments:enum:converters:diodetrr:map_SpecifyReverseRecoveryCharge';
        end
    end
end
