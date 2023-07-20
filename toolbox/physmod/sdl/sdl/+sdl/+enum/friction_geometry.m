classdef friction_geometry<int32




    enumeration
        radius(1)
        annular(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('radius')='physmod:sdl:library:enum:EffectiveRadius';
            map('annular')='physmod:sdl:library:enum:AnnularRegion';
        end
    end
end
