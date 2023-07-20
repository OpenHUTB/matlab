function channelNames=getDefaultChannelNames(this)



    channelNames=getDefaultChannelNames@matlabshared.scopes.mixin.InputProcessingLegend(this);

    numChannels=sum(this.NumberOfChannels);
    if this.MaxHoldTraceFlag
        names=cell(numChannels,1);
        for idx=1:numChannels
            names{idx}=[channelNames{idx},' Max-Hold'];
        end
        channelNames=[channelNames;names];
    end
    if this.MinHoldTraceFlag
        names=cell(numChannels,1);
        for idx=1:numChannels
            names{idx}=[channelNames{idx},' Min-Hold'];
        end
        channelNames=[channelNames;names];
    end
    if~this.NormalTraceFlag
        channelNames(1:numChannels)=[];
    end
end
