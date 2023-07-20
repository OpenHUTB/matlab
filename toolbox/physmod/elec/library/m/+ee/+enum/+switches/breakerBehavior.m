classdef breakerBehavior<int32



    enumeration
        zeroCrossingEnable(1)
        zeroCrossingDisable(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('zeroCrossingEnable')='physmod:ee:library:comments:enum:switches:breakerBehavior:map_ZeroCrossingEnable';
            map('zeroCrossingDisable')='physmod:ee:library:comments:enum:switches:breakerBehavior:map_ZeroCrossingDisable';
        end
    end
end
