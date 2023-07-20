function[poolSize,stride,actualPaddingSize]=getPoolingParameters(layer,converter)




    layerInfo=getLayerInfo(converter,layer.Name);
    if isa(layer,'nnet.cnn.layer.AveragePooling2DLayer')||isa(layer,'nnet.cnn.layer.MaxPooling2DLayer')
        poolSize=layer.PoolSize;
        stride=layer.Stride;

        actualPaddingSize=dltargets.internal.utils.getPaddingSizeFromInputSize(layer,layerInfo.inputSizes{1});
    else

        poolSize=layerInfo.inputSizes{1}(1:2);
        stride=[1,1];
        actualPaddingSize=[0,0,0,0];
    end
end
