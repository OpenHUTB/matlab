classdef rollingResistanceParameterization<int32




    enumeration
        constant(1)
        velocity(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('constant')='physmod:sdl:library:enum:RollingResistanceConstant';
            map('velocity')='physmod:sdl:library:enum:RollingResistancePressureVelocity';
        end
    end
end
