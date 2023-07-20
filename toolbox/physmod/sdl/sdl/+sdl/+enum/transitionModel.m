classdef transitionModel<int32




    enumeration
        instant(1)
        timeConstant(2)
        scaled(3)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('instant')='physmod:sdl:library:enum:Instant';
            map('timeConstant')='physmod:sdl:library:enum:TimeConstant';
            map('scaled')='physmod:sdl:library:enum:Scaled';
        end
    end
end
