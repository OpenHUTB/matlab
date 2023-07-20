classdef torqueConverterInitialMode<int32




    enumeration
        drive(1)
        coast(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('drive')='physmod:sdl:library:enum:TorqueConverterDrive';
            map('coast')='physmod:sdl:library:enum:TorqueConverterCoast';
        end
    end
end
