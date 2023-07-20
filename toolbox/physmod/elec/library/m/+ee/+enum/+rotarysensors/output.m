classdef output<int32
    enumeration
        elec(1)
        decoded_ps(2)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('elec')='physmod:ee:library:comments:enum:rotarysensors:output:map_ElectricalConnections';
            map('decoded_ps')='physmod:ee:library:comments:enum:rotarysensors:output:map_DecodedPosition';
        end
    end
end
