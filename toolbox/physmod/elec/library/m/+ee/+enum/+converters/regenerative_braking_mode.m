classdef regenerative_braking_mode<int32



    enumeration
        depends_on_rev(1)
        always_enabled(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('depends_on_rev')='physmod:ee:library:comments:enum:converters:regenerative_braking_mode:map_depends_on_rev';
            map('always_enabled')='physmod:ee:library:comments:enum:converters:regenerative_braking_mode:map_always_enabled';
        end
    end
end