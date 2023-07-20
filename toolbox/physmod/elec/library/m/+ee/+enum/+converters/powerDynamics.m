classdef powerDynamics<int32



    enumeration
        no(0)
        yes(1)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('no')='physmod:ee:library:comments:enum:converters:powerDynamics:map_No';
            map('yes')='physmod:ee:library:comments:enum:converters:powerDynamics:map_Yes';
        end
    end
end
