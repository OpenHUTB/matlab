classdef RowMajorFlattenCompBuilder<dltargets.internal.compbuilder.CustomCompBuilder




    properties(Constant,Access=private)

        compKey='MWRowMajorFlattenLayer';


        compKind='customlayer';


        cppClassName='MWRowMajorFlattenLayer';


        createMethodName='createRowMajorFlattenLayer';
    end

    methods(Static,Access=public)

        function compKey=getCompKey(varargin)
            compKey=dltargets.internal.compbuilder.RowMajorFlattenCompBuilder.compKey;
        end

        function compKind=getCompKind()
            compKind=dltargets.internal.compbuilder.RowMajorFlattenCompBuilder.compKind;
        end

        function cppClassName=getCppClassName(varargin)
            cppClassName=dltargets.internal.compbuilder.RowMajorFlattenCompBuilder.cppClassName;
        end

        function createMethodName=getCreateMethodName()
            createMethodName=dltargets.internal.compbuilder.RowMajorFlattenCompBuilder.createMethodName;
        end

        function comp=convert(layer,converter,comp)

            comp=dltargets.internal.compbuilder.CustomCompBuilder.setCommonCustomLayerProperties(layer,converter,comp);

            comp.setInplaceIndex(0,0);
            comp.setIsScaleInvariant(true);
            comp.setIsDataNOOPLayer(true);
        end
        function validate(layer,validator)

            unsupportedTargets={'cmsis-nn'};
            dltargets.internal.utils.checkLayerSupportForTarget(layer,validator,unsupportedTargets);

        end
    end
end
