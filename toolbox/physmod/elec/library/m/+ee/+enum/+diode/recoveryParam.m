classdef recoveryParam<int32





    enumeration
        off(0)
        peakstretch(1)
        peaktime(2)
        peakcharge(3)
        reverseenergy(4)
        transittime(5)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('off')='physmod:ee:library:comments:enum:diode:recoveryParam:map_DoNotModelChargeDynamics';
            map('peakstretch')='physmod:ee:library:comments:enum:diode:recoveryParam:map_UsePeakReverseCurrentAndStretchFactor';
            map('peaktime')='physmod:ee:library:comments:enum:diode:recoveryParam:map_UsePeakReverseCurrentAndReverseRecoveryTime';
            map('peakcharge')='physmod:ee:library:comments:enum:diode:recoveryParam:map_UsePeakReverseCurrentAndReverseRecoveryCharge';
            map('reverseenergy')='physmod:ee:library:comments:enum:diode:recoveryParam:map_UsePeakReverseCurrentAndReverseRecoveryEnergy';
            map('transittime')='physmod:ee:library:comments:enum:diode:recoveryParam:map_UseTransitTimeAndCarrierLifetime';
        end
    end
end
