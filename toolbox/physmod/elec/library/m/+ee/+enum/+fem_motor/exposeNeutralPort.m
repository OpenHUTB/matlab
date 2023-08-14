classdef exposeNeutralPort<int32
    enumeration
        no(1)
        yes(2)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('no')='physmod:ee:library:comments:enum:fem_motor:exposeNeutralPort:map_No';
            map('yes')='physmod:ee:library:comments:enum:fem_motor:exposeNeutralPort:map_Yes';
        end
    end
end