classdef symmetry<int32

    enumeration
        symmetric(1)
        twoSided(2)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('symmetric')='physmod:sdl:library:enum:Symmetric';
            map('twoSided')='physmod:sdl:library:enum:TwoSided';
        end
    end
end
