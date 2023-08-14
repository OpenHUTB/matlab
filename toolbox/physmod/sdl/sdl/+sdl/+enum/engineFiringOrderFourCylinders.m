classdef engineFiringOrderFourCylinders<int32




    enumeration
        L4_1342(1)
        L4_1324(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('L4_1342')='physmod:sdl:library:enum:EngineFiringOrder_L4_1342';
            map('L4_1324')='physmod:sdl:library:enum:EngineFiringOrder_L4_1324';
        end
    end
end
