classdef wrap_parameterization<int32




    enumeration
        centers(1)
        angles(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('centers')='physmod:sdl:library:enum:PulleyCenters';
            map('angles')='physmod:sdl:library:enum:PulleyWrapAngles';
        end
    end
end
