classdef gear_efficiencies<int32




    enumeration
        off(1)
        constant(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('off')='physmod:sdl:library:enum:MeshingLossesOff';
            map('constant')='physmod:sdl:library:enum:LossesOn';
        end
    end
end
