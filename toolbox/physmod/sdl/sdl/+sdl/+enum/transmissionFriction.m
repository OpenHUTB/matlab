classdef transmissionFriction<int32




    enumeration
        none(1)
        constant(2)
        gear(3)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('none')='physmod:sdl:library:enum:LossesOff';
            map('constant')='physmod:sdl:library:enum:LossesOn';
            map('gear')='physmod:sdl:library:enum:GearDependentEfficiencies';
        end
    end
end
