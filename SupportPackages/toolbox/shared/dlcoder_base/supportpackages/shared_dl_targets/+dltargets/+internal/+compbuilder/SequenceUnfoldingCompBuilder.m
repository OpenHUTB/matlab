classdef SequenceUnfoldingCompBuilder<dltargets.internal.compbuilder.CustomCompBuilder




    properties(Constant,Access=private)

        compKey='gpucoder.sequence_unfolding_layer_comp';


        compKind='customlayer';


        cppClassName='MWSequenceUnfoldingLayer';


        createMethodName='createSequenceUnfoldingLayer';
    end

    methods(Static,Access=public)

        function compKey=getCompKey(varargin)
            compKey=dltargets.internal.compbuilder.SequenceUnfoldingCompBuilder.compKey;
        end

        function compKind=getCompKind()
            compKind=dltargets.internal.compbuilder.SequenceUnfoldingCompBuilder.compKind;
        end

        function cppClassName=getCppClassName(varargin)
            cppClassName=dltargets.internal.compbuilder.SequenceUnfoldingCompBuilder.cppClassName;
        end

        function createMethodName=getCreateMethodName()
            createMethodName=dltargets.internal.compbuilder.SequenceUnfoldingCompBuilder.createMethodName;
        end

        function validate(layer,validator)

            unsupportedTargets={'arm-compute-mali','cmsis-nn'};
            dltargets.internal.utils.checkLayerSupportForTarget(layer,validator,unsupportedTargets);

        end

        function comp=convert(layer,converter,comp)

            comp=dltargets.internal.compbuilder.CustomCompBuilder.setCommonCustomLayerProperties(layer,converter,comp);

            comp.setInplaceIndex(0,0);
            comp.setIsDataNOOPLayer(true);
        end
    end
end
