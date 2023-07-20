classdef MaxUnpoolingCompBuilder<dltargets.internal.compbuilder.CodegenCompBuilder




    properties(Constant,Access=private)

        compKey='gpucoder.MaxUnpool_layer_comp';


        compKind='maxunpoollayer';
    end

    methods(Static,Access=public)

        function compKey=getCompKey(varargin)
            compKey=dltargets.internal.compbuilder.MaxUnpoolingCompBuilder.compKey;
        end

        function compKind=getCompKind()
            compKind=dltargets.internal.compbuilder.MaxUnpoolingCompBuilder.compKind;
        end

        function validate(layer,validator)

            unsupportedTargets={'arm-compute-mali','cmsis-nn','arm-compute'};
            dltargets.internal.utils.checkLayerSupportForTarget(layer,validator,unsupportedTargets);

        end
    end
end
