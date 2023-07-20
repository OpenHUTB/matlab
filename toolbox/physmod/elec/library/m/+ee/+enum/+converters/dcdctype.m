classdef dcdctype<int32



    enumeration
        buck(1)
        boost(2)
        buckboost(3)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('buck')='physmod:ee:library:comments:enum:converters:dcdctype:map_Buck';
            map('boost')='physmod:ee:library:comments:enum:converters:dcdctype:map_Boost';
            map('buckboost')='physmod:ee:library:comments:enum:converters:dcdctype:map_BuckBoost';
        end
    end
end
