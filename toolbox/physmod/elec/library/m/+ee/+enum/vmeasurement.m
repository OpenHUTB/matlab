classdef vmeasurement<int32



    enumeration
        ll(1)
        lg(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('ll')='physmod:ee:library:comments:enum:vmeasurement:map_phasetophaseVoltage';
            map('lg')='physmod:ee:library:comments:enum:vmeasurement:map_phasetogroundVoltage';
        end
    end
end
