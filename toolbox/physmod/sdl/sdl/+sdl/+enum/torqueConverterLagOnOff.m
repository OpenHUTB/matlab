classdef torqueConverterLagOnOff<int32




    enumeration
        LagOff(0)
        LagOn(1)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('LagOff')='physmod:sdl:library:enum:LagOff';
            map('LagOn')='physmod:sdl:library:enum:LagOn';
        end
    end
end
