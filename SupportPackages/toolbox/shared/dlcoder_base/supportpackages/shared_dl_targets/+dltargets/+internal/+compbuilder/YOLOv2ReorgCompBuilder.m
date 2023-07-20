classdef YOLOv2ReorgCompBuilder<dltargets.internal.compbuilder.CustomCompBuilder




    properties(Constant,Access=private)

        compKey='MWYoloReorg2dLayer';


        compKind='customlayer';


        cppClassName='MWYoloReorg2dLayer';


        createMethodName='createYoloReorg2dLayer';
    end

    methods(Static,Access=public)

        function compKey=getCompKey(varargin)
            compKey=dltargets.internal.compbuilder.YOLOv2ReorgCompBuilder.compKey;
        end

        function compKind=getCompKind()
            compKind=dltargets.internal.compbuilder.YOLOv2ReorgCompBuilder.compKind;
        end

        function cppClassName=getCppClassName(varargin)
            cppClassName=dltargets.internal.compbuilder.YOLOv2ReorgCompBuilder.cppClassName;
        end

        function createMethodName=getCreateMethodName()
            createMethodName=dltargets.internal.compbuilder.YOLOv2ReorgCompBuilder.createMethodName;
        end

        function comp=convert(layer,converter,comp)
            comp=dltargets.internal.compbuilder.CustomCompBuilder.setCommonCustomLayerProperties(layer,converter,comp);

            if isa(layer,'nnet.cnn.layer.SpaceToDepthLayer')
                strideHW=layer.BlockSize;
            else
                strideHW=layer.Stride;
            end


            comp.addCreateMethodArg(int32(strideHW(2)));


            comp.addCreateMethodArg(int32(strideHW(1)));

            comp.setIsScaleInvariant(true);
        end

        function aStruct=toStruct(layer)

            aStruct=struct('Class',class(layer),'Name',layer.Name);
            if isa(layer,'nnet.cnn.layer.SpaceToDepthLayer')
                aStruct.BlockSize=layer.BlockSize;
            else
                aStruct.Stride=layer.Stride;
            end
        end
        function validate(layer,validator)
            unsupportedTargets={'cmsis-nn'};
            dltargets.internal.utils.checkLayerSupportForTarget(layer,validator,unsupportedTargets);
        end
    end
end
