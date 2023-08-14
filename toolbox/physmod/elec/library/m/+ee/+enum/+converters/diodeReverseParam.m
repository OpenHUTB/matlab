classdef diodeReverseParam<int32



    enumeration
        trr_factor(1)
        trr(2)
        Qrr(3)
        Erec(4)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('trr_factor')='physmod:ee:library:comments:enum:converters:diodeReverseParam:map_SpecifyStretchFactor';
            map('trr')='physmod:ee:library:comments:enum:converters:diodeReverseParam:map_SpecifyReverseRecoveryTimeDirectly';
            map('Qrr')='physmod:ee:library:comments:enum:converters:diodeReverseParam:map_SpecifyReverseRecoveryCharge';
            map('Erec')='physmod:ee:library:comments:enum:converters:diodeReverseParam:map_SpecifyReverseRecoveryEnergy';
        end
    end
end
