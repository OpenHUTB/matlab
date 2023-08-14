function convLayer=createConvFromFC(FCLayer)

    internalLayer=nnet.cnn.layer.Layer.getInternalLayers(FCLayer);
    weightDims=size(internalLayer{1}.Weights.Value);
    numDims=numel(weightDims);
    weights=internalLayer{1}.Weights.Value;
    bias=internalLayer{1}.Bias.Value;
    filterSize=[weightDims(1),weightDims(2)];
    numChannels=weightDims(3);

    if numDims<4

        numFilters=1;
    else

        numFilters=weightDims(4);
    end

    name=FCLayer.Name;

    convLayer=convolution2dLayer(filterSize,numFilters,...
    'Name',name,...
    'NumChannels',numChannels);
    convLayer.Weights=weights;
    convLayer.Bias=bias;



end