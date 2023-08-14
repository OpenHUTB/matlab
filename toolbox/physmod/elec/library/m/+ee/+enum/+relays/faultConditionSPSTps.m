classdef faultConditionSPSTps<int32



    enumeration
        csstuck(1)
        open(2)
        degraded(3)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('csstuck')='physmod:ee:library:comments:enum:relays:faultConditionSPSTps:map_CSStuckClosed';
            map('open')='physmod:ee:library:comments:enum:relays:faultConditionSPSTps:map_COpenCircuitNoPathToS';
            map('degraded')='physmod:ee:library:comments:enum:relays:faultConditionSPSTps:map_DegradedContactResistance';
        end
    end
end