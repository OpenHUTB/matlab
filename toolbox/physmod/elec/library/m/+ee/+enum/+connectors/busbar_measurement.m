classdef busbar_measurement<int32




    enumeration
        false(0)
        true(1)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('false')='physmod:ee:library:comments:enum:connectors:busbar_measurement:map_false';
            map('true')='physmod:ee:library:comments:enum:connectors:busbar_measurement:map_true';
        end
    end
end