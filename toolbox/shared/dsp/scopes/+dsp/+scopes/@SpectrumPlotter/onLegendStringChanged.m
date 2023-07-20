function onLegendStringChanged(this)



    defaultChannelNames=getDefaultChannelNames(this);


    numChannels=sum(this.NumberOfChannels);
    if numel(this.UserDefinedChannelNames)>numChannels
        userChannelNames=this.UserDefinedChannelNames;
    else
        if isrow(this.UserDefinedChannelNames)
            userChannelNames=repmat({''},1,numChannels);
        else
            userChannelNames=repmat({''},numChannels,1);
        end
    end
    maxHoldUserChannelNames=repmat({''},numChannels,1);
    minHoldUserChannelNames=repmat({''},numChannels,1);

    channelIdx=1;
    if this.NormalTraceFlag&&numel(this.Lines)==numChannels
        for indx=1:numChannels
            displayName=get(this.Lines(indx),'DisplayName');
            if isempty(displayName)
                set(this.Lines(indx),'DisplayName',defaultChannelNames{channelIdx});
            elseif~strcmp(displayName,defaultChannelNames{channelIdx})
                userChannelNames{indx}=displayName;
            end
            channelIdx=channelIdx+1;
        end
    else
        userChannelNames=repmat({''},numel(this.Lines),1);
    end

    currChannelNames=this.ChannelNames;
    if~this.CCDFMode&&this.MaxHoldTraceFlag&&numel(this.MaxHoldTraceLines)==numChannels
        currMaxHoldUserNames=this.MaxHoldUserDefinedChannelNames;
        for indx=1:numChannels
            displayName=get(this.MaxHoldTraceLines(indx),'DisplayName');
            if~isempty(displayName)&&~strcmp(displayName,currChannelNames{channelIdx})
                maxHoldUserChannelNames{indx}=displayName;
            elseif length(currMaxHoldUserNames)>=indx
                maxHoldUserChannelNames{indx}=currMaxHoldUserNames{indx};
            end
            channelIdx=channelIdx+1;
        end
    else
        maxHoldUserChannelNames=repmat({''},numel(this.MaxHoldTraceLines),1);
    end

    if~this.CCDFMode&&this.MinHoldTraceFlag&&numel(this.MinHoldTraceLines)==numChannels
        currMinHoldUserNames=this.MinHoldUserDefinedChannelNames;
        for indx=1:numChannels
            displayName=get(this.MinHoldTraceLines(indx),'DisplayName');
            if~isempty(displayName)&&~strcmp(displayName,currChannelNames{channelIdx})
                minHoldUserChannelNames{indx}=displayName;
            elseif length(currMinHoldUserNames)>=indx
                minHoldUserChannelNames{indx}=currMinHoldUserNames{indx};
            end
            channelIdx=channelIdx+1;
        end
    else
        minHoldUserChannelNames=repmat({''},numel(this.MinHoldTraceLines),1);
    end

    if this.CCDFMode&&this.CCDFGaussianReferenceFlag
        set(this.CCDFGaussianReferenceLine,'DisplayName',uiscopes.message('GaussianReference'));
    end


    if any(cellfun(@isempty,this.UserDefinedChannelNames)==false)...
        ||any(cellfun(@isempty,userChannelNames)==false)

        this.UserDefinedChannelNames=userChannelNames;
    end
    if any(cellfun(@isempty,this.MaxHoldUserDefinedChannelNames)==false)...
        ||any(cellfun(@isempty,maxHoldUserChannelNames)==false)

        this.MaxHoldUserDefinedChannelNames=maxHoldUserChannelNames;
    end
    if any(cellfun(@isempty,this.MinHoldUserDefinedChannelNames)==false)...
        ||any(cellfun(@isempty,minHoldUserChannelNames)==false)

        this.MinHoldUserDefinedChannelNames=minHoldUserChannelNames;
    end
end
