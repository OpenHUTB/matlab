function[weights2,bias2]=convReformatWeights(weights,bias,...
    inputChannelMiniblockSize,outputChannelMiniblockSize)




%#codegen

    kernelHeight=size(weights,1);
    kernelWidth=size(weights,2);
    inputChannels=size(weights,3);
    outputChannels=size(weights,4);

    inputChannelMiniblocks=divideCeil(inputChannels,inputChannelMiniblockSize);
    inputChannelsExtra=inputChannelMiniblocks*inputChannelMiniblockSize;
    outputChannelMiniblocks=divideCeil(outputChannels,outputChannelMiniblockSize);
    outputChannelsExtra=outputChannelMiniblocks*outputChannelMiniblockSize;
    numelWeights2=kernelHeight*kernelWidth*inputChannelsExtra*outputChannelsExtra;















    weights2=zeros(numelWeights2,1,"like",weights);
    idx1=coder.internal.indexInt(1);
    for a=1:outputChannelMiniblockSize:outputChannelsExtra
        idx2=idx1;
        for b=1:inputChannelMiniblockSize:inputChannelsExtra
            idx3=idx2;
            for c=0:(outputChannelMiniblockSize-1)
                if a+c>outputChannels

                    break;
                end
                idx4=idx3;
                for d=0:(inputChannelMiniblockSize-1)
                    if b+d>inputChannels

                        break;
                    end
                    idx5=idx4;
                    for e=1:kernelWidth
                        idx6=idx5;
                        for f=1:kernelHeight
                            weights2(idx6)=weights(f,e,b+d,a+c);
                            idx6=idx6+outputChannelMiniblockSize*inputChannelMiniblockSize;
                        end
                        idx5=idx5+outputChannelMiniblockSize*inputChannelMiniblockSize*kernelHeight;
                    end
                    idx4=idx4+outputChannelMiniblockSize;
                end
                idx3=idx3+1;
            end
            idx2=idx2+outputChannelMiniblockSize*inputChannelMiniblockSize*kernelHeight*kernelWidth;
        end
        idx1=idx1+outputChannelMiniblockSize*inputChannelsExtra*kernelHeight*kernelWidth;
    end

    bias2=zeros(outputChannelsExtra,1,"like",weights);
    for i=1:outputChannels
        bias2(i)=bias(i);
    end

end


function quot=divideCeil(num,den)
    quot=ceil(num/den);
end
