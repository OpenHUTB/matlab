function[reshapedWeights,reshapedBias]=transform1x1ConvParamsTo2DMatrix(layer,inputSize)















    weights=layer.Weights;
    bias=layer.Bias;
    numFilters=layer.NumFilters;
    numFilterChannel=layer.NumChannels;
    filterSize=layer.FilterSize;
    kernelHeight=filterSize(1);
    kernelWidth=filterSize(2);


    M=inputSize(1)*inputSize(2)*inputSize(4);
    reshapedWeights=reshape(weights,kernelHeight*kernelWidth*numFilterChannel,numFilters);
    N=size(reshapedWeights,2);
    reshapedBias=reshape(repelem(bias(:),M),[M,N]);

end
