classdef ReLUCompBuilder<dltargets.internal.compbuilder.CodegenCompBuilder




    properties(Constant,Access=private)

        compKey='gpucoder.relu_layer_comp';


        compKind='relulayer';
    end

    methods(Static,Access=public)

        function compKey=getCompKey(varargin)
            compKey=dltargets.internal.compbuilder.ReLUCompBuilder.compKey;
        end

        function compKind=getCompKind()
            compKind=dltargets.internal.compbuilder.ReLUCompBuilder.compKind;
        end
        function validate(layer,validator)

            unsupportedTargets={'cmsis-nn'};
            dltargets.internal.utils.checkLayerSupportForTarget(layer,validator,unsupportedTargets);

        end
    end
end
