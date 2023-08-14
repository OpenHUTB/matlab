classdef SoftmaxCompBuilder<dltargets.internal.compbuilder.CodegenCompBuilder




    properties(Constant,Access=private)

        compKey='gpucoder.softmax_layer_comp';


        compKind='softmaxlayer';
    end

    methods(Static,Access=public)

        function compKey=getCompKey(varargin)
            compKey=dltargets.internal.compbuilder.SoftmaxCompBuilder.compKey;
        end

        function compKind=getCompKind()
            compKind=dltargets.internal.compbuilder.SoftmaxCompBuilder.compKind;
        end
    end
end
