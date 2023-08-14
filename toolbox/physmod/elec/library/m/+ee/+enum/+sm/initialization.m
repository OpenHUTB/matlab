classdef initialization<int32



    enumeration
        mechanical(1)
        electrical(2)
        steadystate(3)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('mechanical')='physmod:ee:library:comments:enum:sm:initialization:map_MechanicalAndMagneticStates';
            map('electrical')='physmod:ee:library:comments:enum:sm:initialization:map_ElectricalPowerAndVoltageOutput';
            map('steadystate')='physmod:ee:library:comments:enum:sm:initialization:map_SetTargetsForLoadFlowVariables';
        end
    end
end

