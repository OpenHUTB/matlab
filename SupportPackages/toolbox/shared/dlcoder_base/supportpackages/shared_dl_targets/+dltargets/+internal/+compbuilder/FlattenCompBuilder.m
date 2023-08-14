classdef FlattenCompBuilder<dltargets.internal.compbuilder.CustomCompBuilder




    properties(Constant,Access=private)

        compKey='MWFlattenLayer';


        compKind='customlayer';


        cppClassName='MWFlattenLayer';


        createMethodName='createFlattenLayer';
    end

    methods(Static,Access=public)

        function compKey=getCompKey(varargin)
            compKey=dltargets.internal.compbuilder.FlattenCompBuilder.compKey;
        end

        function compKind=getCompKind()
            compKind=dltargets.internal.compbuilder.FlattenCompBuilder.compKind;
        end

        function cppClassName=getCppClassName(varargin)
            cppClassName=dltargets.internal.compbuilder.FlattenCompBuilder.cppClassName;
        end

        function createMethodName=getCreateMethodName()
            createMethodName=dltargets.internal.compbuilder.FlattenCompBuilder.createMethodName;
        end

        function validate(layer,validator)

            unsupportedTargets={'arm-compute-mali','cmsis-nn'};
            dltargets.internal.utils.checkLayerSupportForTarget(layer,validator,unsupportedTargets);

        end

        function comp=convert(layer,converter,comp)

            comp=dltargets.internal.compbuilder.CustomCompBuilder.setCommonCustomLayerProperties(layer,converter,comp);

            comp.setIsScaleInvariant(true);
        end
    end
end
