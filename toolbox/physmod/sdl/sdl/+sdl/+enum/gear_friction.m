classdef gear_friction<int32




    enumeration
        none(1)
        constant(2)
        thermal(3)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('none')='physmod:sdl:library:enum:MeshingLossesOff';
            map('constant')='physmod:sdl:library:enum:LossesOn';
            map('thermal')='physmod:sdl:library:enum:TemperatureEfficiency';
        end
    end
end
