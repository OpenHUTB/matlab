classdef engineParameterization<int32

    enumeration
        polynomial(1)
        torque(2)
        tabulatedPower(3)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('polynomial')='physmod:sdl:library:enum:EngineNormalizedPoly';
            map('torque')='physmod:sdl:library:enum:EngineTorque';
            map('tabulatedPower')='physmod:sdl:library:enum:EnginePower';
        end
    end
end
