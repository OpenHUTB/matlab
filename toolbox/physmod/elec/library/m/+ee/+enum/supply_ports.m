classdef supply_ports<int32



    enumeration
        hidesupply(1)
        showsupply(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('hidesupply')='physmod:ee:library:comments:enum:supply_ports:map_Internal';
            map('showsupply')='physmod:ee:library:comments:enum:supply_ports:map_External';
        end
    end
end