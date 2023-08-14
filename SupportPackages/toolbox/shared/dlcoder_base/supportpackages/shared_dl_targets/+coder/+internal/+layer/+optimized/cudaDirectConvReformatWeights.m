function[formattedWeights,formattedBias]=cudaDirectConvReformatWeights(weights,bias,simdLength)































    kernelHeight=size(weights,1);
    kernelWidth=size(weights,2);
    numInputChannels=size(weights,3);
    numOutputChannels=size(weights,4);

    numOutputChannelsExtra=simdLength*ceil(numOutputChannels/simdLength);
    numelWeightsReformatted=kernelHeight*kernelWidth*numInputChannels*numOutputChannelsExtra;



    formattedWeights=zeros(numelWeightsReformatted,1,"like",weights);
    idx1=coder.internal.indexInt(1);
    for a=1:simdLength:numOutputChannelsExtra
        idx2=idx1;
        for b=0:(simdLength-1)
            if a+b>numOutputChannels
                break;
            end
            idx3=idx2;
            for c=1:numInputChannels
                idx4=idx3;
                for d=1:kernelWidth
                    idx5=idx4;
                    for e=1:kernelHeight
                        formattedWeights(idx5)=weights(e,d,c,a+b);
                        idx5=idx5+simdLength;
                    end
                    idx4=idx4+simdLength*kernelHeight;
                end
                idx3=idx3+simdLength*kernelHeight*kernelWidth;
            end
            idx2=idx2+1;
        end
        idx1=idx1+simdLength*numInputChannels*kernelHeight*kernelWidth;
    end

    formattedBias=zeros(numOutputChannelsExtra,1,"like",bias);
    formattedBias(1:numOutputChannels)=bias(1:numOutputChannels);
end
