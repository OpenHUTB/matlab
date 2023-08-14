function errmsg=validateChanges(this)






    this.Block.deviceName=this.deviceNamePopup;

    if~this.defaultInputChannelMapping
        try
            [~,numChannels]=evalc(sprintf('numel(%s);',...
            this.inputChannelMapping));
            this.Block.numChannels=sprintf('%d',numChannels);
        catch ME
        end
    end

    errmsg='';
