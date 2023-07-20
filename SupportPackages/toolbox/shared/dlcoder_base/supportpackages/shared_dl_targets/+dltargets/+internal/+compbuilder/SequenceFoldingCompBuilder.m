classdef SequenceFoldingCompBuilder<dltargets.internal.compbuilder.CustomCompBuilder




    properties(Constant,Access=private)

        compKey='gpucoder.sequence_folding_layer_comp';


        compKind='customlayer';


        cppClassName='MWSequenceFoldingLayer';


        createMethodName='createSequenceFoldingLayer';
    end

    methods(Static,Access=public)

        function compKey=getCompKey(varargin)
            compKey=dltargets.internal.compbuilder.SequenceFoldingCompBuilder.compKey;
        end

        function compKind=getCompKind()
            compKind=dltargets.internal.compbuilder.SequenceFoldingCompBuilder.compKind;
        end

        function cppClassName=getCppClassName(varargin)
            cppClassName=dltargets.internal.compbuilder.SequenceFoldingCompBuilder.cppClassName;
        end

        function createMethodName=getCreateMethodName()
            createMethodName=dltargets.internal.compbuilder.SequenceFoldingCompBuilder.createMethodName;
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
