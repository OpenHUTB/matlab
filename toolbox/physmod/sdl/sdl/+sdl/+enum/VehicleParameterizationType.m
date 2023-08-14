classdef VehicleParameterizationType<int32



    enumeration
        RoadLoad(1)
        Regular(2)
        Small(3)
        Medium(4)
        Large(5)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('RoadLoad')='physmod:sdl:library:enum:Vehicle1DRoadLoad';
            map('Regular')='physmod:sdl:library:enum:Vehicle1DRegular';
            map('Small')='physmod:sdl:library:enum:Vehicle1DSmall';
            map('Medium')='physmod:sdl:library:enum:Vehicle1DMedium';
            map('Large')='physmod:sdl:library:enum:Vehicle1DLarge';
        end
    end
end
