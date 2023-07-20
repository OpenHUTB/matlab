classdef gear_efficiencies_load<int32




    enumeration
        off(1)
        constant(2)
        loadDependent(3)
        temperature(4)
        temperatureLoad(5)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('off')='physmod:sdl:library:enum:MeshingLossesOff';
            map('constant')='physmod:sdl:library:enum:LossesOn';
            map('loadDependent')='physmod:sdl:library:enum:LoadDependentEfficiency';
            map('temperature')='physmod:sdl:library:enum:TemperatureEfficiency';
            map('temperatureLoad')='physmod:sdl:library:enum:TemperatureLoadEfficiency';
        end
    end
end
