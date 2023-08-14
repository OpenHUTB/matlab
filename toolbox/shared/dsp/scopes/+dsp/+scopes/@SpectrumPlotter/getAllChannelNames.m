function channelNames=getAllChannelNames(this)





    useIndexOffset=0;
    channelNames=[];



    channelNames=[channelNames;getDefaultChannelNames(this)];

    numChannels=sum(this.NumberOfChannels);
    userChannelNames=this.UserDefinedChannelNames;
    useIndex=find(cellfun(@isempty,userChannelNames)==false);
    useIndex=useIndex(useIndex<=numChannels);
    if this.NormalTraceFlag
        channelNames(useIndex+useIndexOffset)=userChannelNames(useIndex);
        useIndexOffset=useIndexOffset+numChannels;
    end
    if~this.CCDFMode&&this.MaxHoldTraceFlag

        userChannelNames_MaxHold=strcat(userChannelNames,{' Max-Hold'});
        channelNames(useIndex+useIndexOffset)=userChannelNames_MaxHold(useIndex);

        userMaxHoldChannelNames=this.MaxHoldUserDefinedChannelNames;
        useIndexMaxHold=find(cellfun(@isempty,userMaxHoldChannelNames)==false);
        useIndexMaxHold=useIndexMaxHold(useIndexMaxHold<=numChannels);
        channelNames(useIndexMaxHold+useIndexOffset)=userMaxHoldChannelNames(useIndexMaxHold);
        useIndexOffset=useIndexOffset+numChannels;
    end
    if~this.CCDFMode&&this.MinHoldTraceFlag

        userChannelNames_MinHold=strcat(userChannelNames,{' Min-Hold'});
        channelNames(useIndex+useIndexOffset)=userChannelNames_MinHold(useIndex);

        userMinHoldChannelNames=this.MinHoldUserDefinedChannelNames;
        useIndexMinHold=find(cellfun(@isempty,userMinHoldChannelNames)==false);
        useIndexMinHold=useIndexMinHold(useIndexMinHold<=numChannels);
        channelNames(useIndexMinHold+useIndexOffset)=userMinHoldChannelNames(useIndexMinHold);
    end
end
