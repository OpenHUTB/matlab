classdef faultTurnsShort<int32




    enumeration
        negativeTerminal(-1)
        no(0)
        positiveTerminal(1)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('negativeTerminal')='physmod:ee:library:comments:enum:faults:faultTurnsShort:map_negativeTerminal';
            map('no')='physmod:ee:library:comments:enum:faults:faultTurnsShort:map_noShort';
            map('positiveTerminal')='physmod:ee:library:comments:enum:faults:faultTurnsShort:map_positiveTerminal';
        end
    end
end
