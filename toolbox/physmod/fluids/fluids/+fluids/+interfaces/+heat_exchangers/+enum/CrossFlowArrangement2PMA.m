classdef CrossFlowArrangement2PMA<int32





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
            map('MixedUnmixed')='Two-Phase Fluid 1 mixed & Moist Air 2 unmixed';
            map('UnmixedMixed')='Two-Phase Fluid 1 unmixed & Moist Air 2 mixed';
        end
    end
end