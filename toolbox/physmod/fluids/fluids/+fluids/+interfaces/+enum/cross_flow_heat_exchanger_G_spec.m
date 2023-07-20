classdef cross_flow_heat_exchanger_G_spec<int32





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
            map('mixed_unmixed')='Gas mixed & Controlled Fluid unmixed';
            map('unmixed_mixed')='Gas unmixed & Controlled Fluid mixed';
        end
    end
end