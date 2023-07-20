classdef intrinsicCapacitance<int32




    enumeration
        none(1)
        meyer(2)
        charge(3)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('none')='physmod:ee:library:comments:enum:intrinsicCapacitance:map_NoIntrinsicCapacitance';
            map('meyer')='physmod:ee:library:comments:enum:intrinsicCapacitance:map_MeyerGateCapacitances';
            map('charge')='physmod:ee:library:comments:enum:intrinsicCapacitance:map_ChargeConservationCapacitances';
        end
    end
end
