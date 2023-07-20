classdef port_locations_spdt<int32



    enumeration
        standard(1)
        classic(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('standard')='physmod:ee:library:comments:enum:relays:port_locations_spdt:map_AdjacentToSwitchPorts';
            map('classic')='physmod:ee:library:comments:enum:relays:port_locations_spdt:map_AcrossFromSwitchPorts';
        end
    end
end