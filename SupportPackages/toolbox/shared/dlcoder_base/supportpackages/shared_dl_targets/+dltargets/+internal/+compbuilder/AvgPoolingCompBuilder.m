classdef AvgPoolingCompBuilder<dltargets.internal.compbuilder.CodegenCompBuilder




    properties(Constant,Access=private)

        compKey='gpucoder.avg_pool_layer_comp';


        compKind='avgpoollayer';
    end

    methods(Static,Access=public)

        function compKey=getCompKey(varargin)
            compKey=dltargets.internal.compbuilder.AvgPoolingCompBuilder.compKey;
        end

        function compKind=getCompKind()
            compKind=dltargets.internal.compbuilder.AvgPoolingCompBuilder.compKind;
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

        end

        function validate(layer,validator)


            unsupportedTargets={'cmsis-nn'};
            dltargets.internal.utils.checkLayerSupportForTarget(layer,validator,unsupportedTargets);


            if~isnumeric(layer.PaddingValue)||(layer.PaddingValue~=0)
                errorMessage=message('dlcoder_spkg:cnncodegen:PaddingValueNotSupported',...
                layer.Name,class(layer));
                validator.handleError(layer,errorMessage);
            end

        end

        function aStruct=toStruct(layer)

            aStruct=struct('Class',class(layer),'Name',layer.Name,'PoolSize',layer.PoolSize,...
            'Stride',layer.Stride,'PaddingSize',layer.PaddingSize,...
            'PaddingMode',layer.PaddingMode,'PaddingValue',layer.PaddingValue);
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
