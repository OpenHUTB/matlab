classdef CrossFlowArrangementTL2P<int32





    enumeration
        MixedMixed(1)
        UnmixedUnmixed(2)
        MixedUnmixed(3)
        UnmixedMixed(4)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('MixedMixed')='Both fluids mixed';
            map('UnmixedUnmixed')='Both fluids unmixed';
            map('MixedUnmixed')='Thermal Liquid 1 mixed & Two-Phase Fluid 2 unmixed';
            map('UnmixedMixed')='Thermal Liquid 1 unmixed & Two-Phase Fluid 2 mixed';
        end
    end
end