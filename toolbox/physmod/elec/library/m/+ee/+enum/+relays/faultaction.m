classdef faultaction<int32



    enumeration
        none(1)
        warn(2)
        error(3)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('none')='physmod:ee:library:comments:enum:relays:faultaction:map_None';
            map('warn')='physmod:ee:library:comments:enum:relays:faultaction:map_Warn';
            map('error')='physmod:ee:library:comments:enum:relays:faultaction:map_Error';
        end
    end
end