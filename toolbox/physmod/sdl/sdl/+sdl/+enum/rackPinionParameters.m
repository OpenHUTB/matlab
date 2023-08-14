classdef rackPinionParameters<int32

    enumeration
        radius(1)
        tooth(2)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('radius')='physmod:sdl:library:enum:PinionRadius';
            map('tooth')='physmod:sdl:library:enum:ToothParameters';
        end
    end
end
