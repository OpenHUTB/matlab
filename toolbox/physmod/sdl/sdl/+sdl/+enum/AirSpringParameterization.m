classdef AirSpringParameterization<int32




    enumeration
        Load(1)
        Stiffness(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('Load')='physmod:sdl:library:enum:AirSpringLoad';
            map('Stiffness')='physmod:sdl:library:enum:AirSpringStiffness';
        end
    end
end
