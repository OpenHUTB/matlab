classdef torqueConverterContinuousTwomode<int32




    enumeration
        twomode(1)
        continuous(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('twomode')='physmod:sdl:library:enum:TorqueConverterTwomode';
            map('continuous')='physmod:sdl:library:enum:TorqueConverterContinuous';
        end
    end
end
