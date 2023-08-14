classdef fuel_consumption_model<int32




    enumeration
        FuelOff(0)
        FuelConstant(1)
        FuelSpeedTorque(2)
        BSFCSpeedTorque(3)
        BSFCSpeedBMEP(4)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('FuelOff')='physmod:sdl:library:enum:FuelOff';
            map('FuelConstant')='physmod:sdl:library:enum:FuelConstant';
            map('FuelSpeedTorque')='physmod:sdl:library:enum:FuelSpeedTorque';
            map('BSFCSpeedTorque')='physmod:sdl:library:enum:BSFCSpeedTorque';
            map('BSFCSpeedBMEP')='physmod:sdl:library:enum:BSFCSpeedBMEP';
        end
    end
end
