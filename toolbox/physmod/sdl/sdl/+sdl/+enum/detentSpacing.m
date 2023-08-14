classdef detentSpacing<int32

    enumeration
        regular(1)
        vector(2)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('regular')='physmod:sdl:library:enum:RegularlySpaced';
            map('vector')='physmod:sdl:library:enum:AngleVector';
        end
    end
end