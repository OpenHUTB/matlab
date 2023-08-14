classdef PassthroughCompBuilder<dltargets.internal.compbuilder.CodegenCompBuilder




    properties(Constant,Access=private)

        compKey='gpucoder.pass_through_layer_comp';


        compKind='passthroughlayer';
    end

    methods(Static,Access=public)

        function compKey=getCompKey(varargin)
            compKey=dltargets.internal.compbuilder.PassthroughCompBuilder.compKey;
        end

        function compKind=getCompKind()
            compKind=dltargets.internal.compbuilder.PassthroughCompBuilder.compKind;
        end
    end
end
