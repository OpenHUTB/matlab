function this=ToAudioDevice(block)




    this=dspdialog.ToAudioDevice(block);

    this.init(block);


    devInfo=dspAudioDeviceInfo('outputs');
    if isempty(devInfo)
        outputDevices={'No device available.'};
    else
        outputDevices={'Default'};
        for i=1:length(devInfo)
            temp=devInfo(i).name;

            outputDevices{end+1}=regexprep(temp,' \([^\(]*\)$','');
        end
    end
    this.deviceList=outputDevices;



    if strmatch(this.Block.deviceName,this.deviceList)
        this.deviceNamePopup=this.Block.deviceName;
    else
        msg=sprintf(['Could not find the specified device (%s) '...
        ,'in the list of devices.'],this.Block.deviceName);
        uiwait(warndlg(msg,'To Audio Device: Device not found'));
        this.deviceNamePopup=this.deviceList{1};
    end
    this.outputNumUnderrunSamples=strcmp(this.Block.outputNumUnderrunSamples,'on');
    this.inheritSampleRate=strcmp(this.Block.inheritSampleRate,'on');
    this.sampleRate=this.Block.sampleRate;
    this.deviceDatatype=this.Block.deviceDatatype;
    this.autoBufferSize=strcmp(this.Block.autoBufferSize,'on');
    this.bufferSize=this.Block.bufferSize;
    this.queueDuration=this.Block.queueDuration;
    this.defaultOutputChannelMapping=strcmp(this.Block.defaultOutputChannelMapping,'on');
    this.outputChannelMapping=this.Block.outputChannelMapping;
