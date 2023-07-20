classdef sun_planet_bevel_orientation<int32




    enumeration
        left(1)
        right(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('left')='physmod:sdl:library:enum:SunPlanetLeft';
            map('right')='physmod:sdl:library:enum:SunPlanetRight';
        end
    end
end
