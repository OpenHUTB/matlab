classdef loadInitialization<int32




    enumeration
        momentum(1)
        velocity(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('momentum')='physmod:sdl:library:enum:AngularMomentum';
            map('velocity')='physmod:sdl:library:enum:AngularVelocity';
        end
    end
end
