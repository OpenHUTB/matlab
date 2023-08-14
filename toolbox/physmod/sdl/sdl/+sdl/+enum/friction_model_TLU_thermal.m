classdef friction_model_TLU_thermal<int32




    enumeration
        fixed(1)
        velocity(2)
        temperature(3)
        velocity_temperature(4)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('fixed')='physmod:sdl:library:enum:FixedKineticFriction';
            map('velocity')='physmod:sdl:library:enum:VelocityKineticFriction';
            map('temperature')='physmod:sdl:library:enum:TemperatureFriction';
            map('velocity_temperature')='physmod:sdl:library:enum:TemperatureVelocityFriction';
        end
    end
end
