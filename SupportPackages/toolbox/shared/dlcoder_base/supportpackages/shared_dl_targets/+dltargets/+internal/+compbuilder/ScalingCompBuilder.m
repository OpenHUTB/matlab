classdef ScalingCompBuilder<dltargets.internal.compbuilder.CustomCompBuilder




    properties(Constant,Access=private)

        compKey='MWScalingLayer';


        compKind='customlayer';


        cppClassName='MWScalingLayer';


        createMethodName='createScalingLayer';
    end

    methods(Static,Access=public)

        function compKey=getCompKey(varargin)
            compKey=dltargets.internal.compbuilder.ScalingCompBuilder.compKey;
        end

        function compKind=getCompKind()
            compKind=dltargets.internal.compbuilder.ScalingCompBuilder.compKind;
        end

        function cppClassName=getCppClassName(varargin)
            cppClassName=dltargets.internal.compbuilder.ScalingCompBuilder.cppClassName;
        end

        function createMethodName=getCreateMethodName()
            createMethodName=dltargets.internal.compbuilder.ScalingCompBuilder.createMethodName;
        end

        function comp=convert(layer,converter,comp)

            comp=dltargets.internal.compbuilder.CustomCompBuilder.setCommonCustomLayerProperties(layer,converter,comp);

            comp.addCreateMethodArg(double(2/255));
            comp.addCreateMethodArg(double(-1));
            comp.setInplaceIndex(0,0);
        end
        function validate(layer,validator)

            unsupportedTargets={'cmsis-nn'};
            dltargets.internal.utils.checkLayerSupportForTarget(layer,validator,unsupportedTargets);

        end
    end
end
