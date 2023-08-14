classdef transmissionShiftModel<int32




    enumeration
        instant(1)
        finite(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('instant')='physmod:sdl:library:enum:Instantaneous';
            map('finite')='physmod:sdl:library:enum:FiniteShift';
        end
    end
end
