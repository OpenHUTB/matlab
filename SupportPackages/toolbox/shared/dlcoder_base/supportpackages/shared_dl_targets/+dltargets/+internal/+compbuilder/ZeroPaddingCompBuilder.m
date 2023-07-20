classdef ZeroPaddingCompBuilder<dltargets.internal.compbuilder.CustomCompBuilder




    properties(Constant,Access=private)

        compKey='MWZeroPaddingLayer';


        compKind='customlayer';


        cppClassName='MWZeroPaddingLayer';


        createMethodName='createZeroPaddingLayer';
    end

    methods(Static,Access=public)

        function compKey=getCompKey(varargin)
            compKey=dltargets.internal.compbuilder.ZeroPaddingCompBuilder.compKey;
        end

        function compKind=getCompKind()
            compKind=dltargets.internal.compbuilder.ZeroPaddingCompBuilder.compKind;
        end

        function cppClassName=getCppClassName(varargin)
            cppClassName=dltargets.internal.compbuilder.ZeroPaddingCompBuilder.cppClassName;
        end

        function createMethodName=getCreateMethodName()
            createMethodName=dltargets.internal.compbuilder.ZeroPaddingCompBuilder.createMethodName;
        end

        function comp=convert(layer,converter,comp)
            comp=dltargets.internal.compbuilder.CustomCompBuilder.setCommonCustomLayerProperties(layer,converter,comp);

            comp.addCreateMethodArg(int32(layer.Top));
            comp.addCreateMethodArg(int32(layer.Bottom));
            comp.addCreateMethodArg(int32(layer.Left));
            comp.addCreateMethodArg(int32(layer.Right));

            comp.setIsScaleInvariant(true);
        end

        function aStruct=toStruct(layer)

            aStruct=struct('Class',class(layer),'Name',layer.Name,'Top',layer.Top,...
            'Bottom',layer.Bottom,'Left',layer.Left,'Right',layer.Right);
        end
        function validate(layer,validator)
            unsupportedTargets={'cmsis-nn'};
            dltargets.internal.utils.checkLayerSupportForTarget(layer,validator,unsupportedTargets);
        end
    end
end
