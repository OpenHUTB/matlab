classdef GlobalMaxPoolingCompBuilder<dltargets.internal.compbuilder.CodegenCompBuilder




    properties(Constant,Access=private)

        compKey='gpucoder.max_pool_layer_comp';


        compKind='maxpoollayer';
    end

    methods(Static,Access=public)

        function compKey=getCompKey(varargin)
            compKey=dltargets.internal.compbuilder.GlobalMaxPoolingCompBuilder.compKey;
        end

        function compKind=getCompKind()
            compKind=dltargets.internal.compbuilder.GlobalMaxPoolingCompBuilder.compKind;
        end

        function comp=convert(~,~,comp)

            comp.setPoolSizeH(int32(-1));
            comp.setPoolSizeW(int32(-1));
            comp.setStrideH(int32(1));
            comp.setStrideW(int32(1));
            comp.setPaddingH_Top(int32(0));
            comp.setPaddingW_Left(int32(0));
        end
        function validate(layer,validator)

            unsupportedTargets={'cmsis-nn'};
            dltargets.internal.utils.checkLayerSupportForTarget(layer,validator,unsupportedTargets);
        end
    end
end
