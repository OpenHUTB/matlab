classdef faultConditionSPDTps<int32



    enumeration
        cs1stuck(1)
        cs2stuck(2)
        open(3)
        degraded(4)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('cs1stuck')='physmod:ee:library:comments:enum:relays:faultConditionSPDTps:map_CSOneStuckClosed';
            map('cs2stuck')='physmod:ee:library:comments:enum:relays:faultConditionSPDTps:map_CSTwoStuckClosed';
            map('open')='physmod:ee:library:comments:enum:relays:faultConditionSPDTps:map_COpenCircuitNoPathToSOneOrSTwo';
            map('degraded')='physmod:ee:library:comments:enum:relays:faultConditionSPDTps:map_DegradedContactResistance';
        end
    end
end