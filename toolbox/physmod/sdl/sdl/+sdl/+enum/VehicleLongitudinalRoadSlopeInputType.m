classdef VehicleLongitudinalRoadSlopeInputType<int32



    enumeration
        GradePercent(1)
        Grade(2)
        Angle(3)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('GradePercent')='physmod:sdl:library:enum:Vehicle1DGradePercent';
            map('Grade')='physmod:sdl:library:enum:Vehicle1DGradeNormalized';
            map('Angle')='physmod:sdl:library:enum:Vehicle1DAngle';
        end
    end
end
