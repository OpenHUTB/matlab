classdef dc_ac<int32



    enumeration
        dc(1)
        ac(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('dc')='physmod:ee:library:comments:enum:dc_ac:map_DC';
            map('ac')='physmod:ee:library:comments:enum:dc_ac:map_AC';
        end
    end
end
