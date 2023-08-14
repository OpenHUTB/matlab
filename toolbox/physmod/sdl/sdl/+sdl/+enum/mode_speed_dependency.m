classdef mode_speed_dependency<int32




    enumeration
        Static(0)
        Dynamic(1)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('Static')='physmod:sdl:library:enum:ShaftModesStatic';
            map('Dynamic')='physmod:sdl:library:enum:ShaftModesDynamic';
        end
    end
end
