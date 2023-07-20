classdef initialization<int32





    enumeration
        fluxvariables(1)
        steadystate(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('fluxvariables')='physmod:ee:library:comments:enum:asm:initialization:map_SetTargetsForFluxVariables';
            map('steadystate')='physmod:ee:library:comments:enum:asm:initialization:map_SetTargetsForLoadFlowVariables';
        end
    end
end