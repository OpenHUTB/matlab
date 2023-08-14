classdef shuntparam_option<int32



    enumeration
        ByEquivalentCircuitParameters(1)
        ByRatedPowerRatedSpeedampNoLoadSpeed(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('ByEquivalentCircuitParameters')='physmod:ee:library:comments:enum:electromech:shuntparam_option:ByEquivalentCircuitParameters';
            map('ByRatedPowerRatedSpeedampNoLoadSpeed')='physmod:ee:library:comments:enum:electromech:shuntparam_option:ByRatedPowerRatedSpeedampNoLoadSpeed';
        end
    end
end

