classdef field_option<int32



    enumeration
        pm(1)
        wound(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('pm')='physmod:ee:library:comments:enum:field_option:pm';
            map('wound')='physmod:ee:library:comments:enum:field_option:wound';
        end
    end
end

