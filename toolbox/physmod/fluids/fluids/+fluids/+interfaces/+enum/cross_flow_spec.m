classdef cross_flow_spec<int32





    enumeration
        mixed_mixed(1)
        unmixed_unmixed(2)
        mixed_unmixed(3)
        unmixed_mixed(4)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('mixed_mixed')='Both fluids mixed';
            map('unmixed_unmixed')='Both fluids unmixed';
            map('mixed_unmixed')='Controlled Fluid 1 mixed & Controlled Fluid 2 unmixed';
            map('unmixed_mixed')='Controlled Fluid 1 unmixed & Controlled Fluid 2 mixed';
        end
    end
end