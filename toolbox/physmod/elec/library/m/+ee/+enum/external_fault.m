classdef external_fault<int32



    enumeration
        hidden(1)
        visible(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('hidden')='physmod:ee:library:comments:enum:external_fault:map_Hidden';
            map('visible')='physmod:ee:library:comments:enum:external_fault:map_Visible';
        end
    end
end
