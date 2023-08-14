classdef shaftConstruction<int32

    enumeration
        solid(1)
        annular(2)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('solid')='physmod:sdl:library:enum:Solid';
            map('annular')='physmod:sdl:library:enum:Annular';
        end
    end
end



