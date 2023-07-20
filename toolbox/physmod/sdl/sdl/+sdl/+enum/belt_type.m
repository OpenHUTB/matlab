classdef belt_type<int32




    enumeration
        ideal(0)
        flat(1)
        v_belt(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('ideal')='physmod:sdl:library:enum:IdealBelt';
            map('flat')='physmod:sdl:library:enum:FlatBelt';
            map('v_belt')='physmod:sdl:library:enum:VBelt';
        end
    end
end
