function[formattedWeights,formattedBias]=cudaImplicitGemmConvReformatWeights(weights,bias,simdLength)







    kernelHeight=size(weights,1);
    kernelWidth=size(weights,2);
    numInputChannels=size(weights,3);
    numOutputChannels=size(weights,4);



    formattedWeights=reshape(weights,[kernelHeight*kernelWidth*numInputChannels,numOutputChannels]);



    formattedWeights=formattedWeights';





    formattedWeights=formattedWeights(:);


    numOutputChannelsExtra=simdLength*ceil(numOutputChannels/simdLength);
    formattedBias=zeros(numOutputChannelsExtra,1,"like",bias);
    formattedBias(1:numOutputChannels)=bias(1:numOutputChannels);

end
