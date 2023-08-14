classdef type_balanced<int32



    enumeration
        balanced(1)
        unbalanced(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('balanced')='physmod:ee:library:comments:enum:passive:type_balanced:map_Balanced';
            map('unbalanced')='physmod:ee:library:comments:enum:passive:type_balanced:map_Unbalanced';
        end
    end
end
