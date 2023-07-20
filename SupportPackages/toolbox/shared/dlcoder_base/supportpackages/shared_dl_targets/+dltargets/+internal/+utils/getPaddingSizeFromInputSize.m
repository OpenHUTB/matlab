function paddingSize=getPaddingSizeFromInputSize(layer,actualInputSize)













    actualInputSizeHW=actualInputSize(1:2);


    if isa(layer,'nnet.cnn.layer.Layer')

        ilayer=nnet.cnn.layer.Layer.getInternalLayers(layer);
        ilayer=ilayer{1};
    else

        ilayer=layer;
    end


    if isprop(ilayer,'PoolSize')

        filterOrPoolSize=ilayer.PoolSize;
    else

        assert(isprop(ilayer,'EffectiveFilterSize'));
        filterOrPoolSize=ilayer.EffectiveFilterSize;
    end


    paddingSize=iCalculatePaddingSizeFromInputSize(...
    ilayer.PaddingMode,ilayer.PaddingSize,...
    filterOrPoolSize,ilayer.Stride,actualInputSizeHW);

end

function paddingSize=iCalculatePaddingSizeFromInputSize(...
    paddingMode,paddingSize,filterOrPoolSize,stride,spatialInputSize)
    paddingSize=deep.internal.sdk.padding.calculatePaddingSizeFromInputSize(...
    paddingMode,paddingSize,filterOrPoolSize,stride,spatialInputSize);
end
