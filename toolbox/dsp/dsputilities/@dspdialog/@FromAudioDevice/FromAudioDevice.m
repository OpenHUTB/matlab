function this=FromAudioDevice(block)




    this=dspdialog.FromAudioDevice(block);

    this.init(block);


    devInfo=dspAudioDeviceInfo('inputs');
    if isempty(devInfo)
        inputDevices={'No device available.'};
    else
        inputDevices={'Default'};
        for i=1:length(devInfo)
            temp=devInfo(i).name;

            inputDevices{end+1}=regexprep(temp,' \([^\(]*\)$','');
        end
    end
    this.deviceList=inputDevices;



    if strmatch(this.Block.deviceName,this.deviceList)
        this.deviceNamePopup=this.Block.deviceName;
    else
        msg=sprintf(['Could not find the specified device (%s) '...
        ,'in the list of devices.'],this.Block.deviceName);
        uiwait(warndlg(msg,'From Audio Device: Device not found'));
        this.deviceNamePopup=this.deviceList{1};
    end
    this.sampleRate=this.Block.sampleRate;
    this.deviceDatatype=this.Block.deviceDatatype;
    this.autoBufferSize=strcmp(this.Block.autoBufferSize,'on');
    this.bufferSize=this.Block.bufferSize;
    this.queueDuration=this.Block.queueDuration;
    try
        if~strcmp(this.Block.defaultInputChannelMapping,'on')
            [~,numChannels]=evalc(sprintf('numel(%s);',...
            this.Block.inputChannelMapping));
            this.numChannels=sprintf('%d',numChannels);
        else
            this.numChannels=this.Block.numChannels;
        end
    catch ME
        this.numChannels=this.Block.numChannels;
    end
    this.outputNumOverrunSamples=strcmp(this.Block.outputNumOverrunSamples,'on');
    this.frameSize=this.Block.frameSize;
    this.outputDatatype=this.Block.outputDatatype;
    this.defaultInputChannelMapping=strcmp(this.Block.defaultInputChannelMapping,'on');
    this.inputChannelMapping=this.Block.inputChannelMapping;
