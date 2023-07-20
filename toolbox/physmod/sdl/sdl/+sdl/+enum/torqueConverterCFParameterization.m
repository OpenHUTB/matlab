classdef torqueConverterCFParameterization<int32





    enumeration
        SpeedToSqrtTorque(1)
        TorqueToSqrSpeed(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('SpeedToSqrtTorque')='physmod:sdl:library:enum:TorqueConverterSpeedToSqrtTorque';
            map('TorqueToSqrSpeed')='physmod:sdl:library:enum:TorqueConverterTorqueToSqrSpeed';
        end
    end
end
