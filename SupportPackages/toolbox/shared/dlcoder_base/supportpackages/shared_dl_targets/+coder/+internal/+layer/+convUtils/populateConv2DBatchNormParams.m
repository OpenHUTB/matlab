function[layerFused,layerUnfused]=populateConv2DBatchNormParams(name,weightsUnfused,...
    biasUnfused,weightsFused,biasFused,stride,paddingSize,dilation,numFilters,...
    filterSize,inputSize,buildContext)





    layerUnfused=iPopulateInternalLayer(name,weightsUnfused,biasUnfused,stride,paddingSize,dilation,...
    numFilters,filterSize,inputSize,buildContext);

    layerFused=iPopulateInternalLayer(name,weightsFused,biasFused,stride,paddingSize,dilation,...
    numFilters,filterSize,inputSize,buildContext);

end

function internalLayer=iPopulateInternalLayer(name,weights,bias,stride,paddingSize,dilation,...
    numFilters,filterSize,inputSize,buildContext)


    internalLayer.Name=name;
    internalLayer.Weights=weights;
    internalLayer.Bias=bias;
    internalLayer.Stride=stride;
    internalLayer.PaddingSize=paddingSize;
    internalLayer.Dilation=dilation;
    internalLayer.NumChannels=size(weights,3);
    internalLayer.NumFilters=numFilters;
    internalLayer.FilterSize=filterSize;



    [internalLayer.Algorithm,internalLayer.Weights,internalLayer.Bias]=...
    coder.internal.layer.convUtils.convolutionDispatcherSelector(internalLayer,inputSize,buildContext);

end
