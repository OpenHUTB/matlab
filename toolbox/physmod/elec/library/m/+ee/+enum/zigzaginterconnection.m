classdef zigzaginterconnection<int32



    enumeration
        floatingNeutral(1)
        accessibleInterconnects(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('floatingNeutral')='physmod:ee:library:comments:enum:zigzaginterconnection:map_InternalFloatingNeutral';
            map('accessibleInterconnects')='physmod:ee:library:comments:enum:zigzaginterconnection:map_AccessibleWindingInterconnects';
        end
    end
end

