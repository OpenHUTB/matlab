classdef faultTypes<int32



    enumeration
        winding(1)
        Switch(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('winding')='physmod:ee:library:comments:enum:relays:faultTypes:map_WindingFailedOpenCircuit';
            map('Switch')='physmod:ee:library:comments:enum:relays:faultTypes:map_SwitchFault';
        end
    end
end