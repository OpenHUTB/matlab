classdef MaxPoolingCompBuilder<dltargets.internal.compbuilder.CodegenCompBuilder




    properties(Constant,Access=private)

        compKey='gpucoder.max_pool_layer_comp';


        compKind='maxpoollayer';
    end

    methods(Static,Access=public)

        function compKey=getCompKey(varargin)
            compKey=dltargets.internal.compbuilder.MaxPoolingCompBuilder.compKey;
        end

        function compKind=getCompKind()
            compKind=dltargets.internal.compbuilder.MaxPoolingCompBuilder.compKind;
        end

        function comp=convert(layer,converter,comp)

            layerInfo=converter.getLayerInfo(layer.Name);
            layeroutputSize=layerInfo.outputSizes{1};

            paddingSize=iGetPaddingSizeFromInputSize(layer,converter.NetworkInfo);

            comp.setPoolSizeH(layer.PoolSize(1));
            comp.setPoolSizeW(layer.PoolSize(2));
            comp.setStrideH(layer.Stride(1));
            comp.setStrideW(layer.Stride(2));
            comp.setPaddingH_Top(paddingSize(1));
            comp.setPaddingH_Bottom(paddingSize(2));
            comp.setPaddingW_Left(paddingSize(3));
            comp.setPaddingW_Right(paddingSize(4));
            comp.setNumOutChannels(layeroutputSize(3));
            comp.setHasIndices(layer.HasUnpoolingOutputs);
        end

        function aStruct=toStruct(layer)

            aStruct=struct('Class',class(layer),'Name',layer.Name,'Stride',layer.Stride,...
            'PoolSize',layer.PoolSize,'PaddingSize',layer.PaddingSize,...
            'PaddingMode',layer.PaddingMode,'HasUnpoolingOutputs',layer.HasUnpoolingOutputs);
        end
        function validate(layer,validator)

            unsupportedTargets={'cmsis-nn'};
            dltargets.internal.utils.checkLayerSupportForTarget(layer,validator,unsupportedTargets);

        end
    end
end


function paddingSize=iGetPaddingSizeFromInputSize(layer,networkInfo)
    ilayer=nnet.cnn.layer.Layer.getInternalLayers(layer);
    ilayer=ilayer{1};

    layerInfo=networkInfo.getLayerInfo(layer.Name);
    actualInputSize=layerInfo.inputSizes;

    actualInputSize=actualInputSize{1};

    actualInputSize=actualInputSize(1:2);
    paddingSize=iCalculatePaddingSizeFromInputSize(...
    ilayer.PaddingMode,ilayer.PaddingSize,...
    ilayer.PoolSize,ilayer.Stride,actualInputSize);
end


function paddingSize=iCalculatePaddingSizeFromInputSize(...
    paddingMode,paddingSize,filterOrPoolSize,stride,spatialInputSize)
    paddingSize=deep.internal.sdk.padding.calculatePaddingSizeFromInputSize(...
    paddingMode,paddingSize,filterOrPoolSize,stride,spatialInputSize);
end
