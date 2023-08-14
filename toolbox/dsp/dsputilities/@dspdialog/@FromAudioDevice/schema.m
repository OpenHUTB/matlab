function schema




    package=findpackage('dspdialog');
    parent=findclass(package,'DSPDDG');

    this=schema.class(package,'FromAudioDevice',parent);


    m=schema.method(this,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(this,'maskInit','static');
    s=m.Signature;
    s.InputTypes={};
    s.OutputTypes={'mxArray'};

    if isempty(findtype('FromAudioDevice_DeviceDatatypeEnum'))
        schema.EnumType('FromAudioDevice_DeviceDatatypeEnum',...
        {'Determine from output data type'...
        ,'8-bit integer','16-bit integer','24-bit integer','32-bit float'});
    end
    if isempty(findtype('FromAudioDevice_OutputDatatypeEnum'))
        schema.EnumType('FromAudioDevice_OutputDatatypeEnum',{'uint8','int16','int32','single','double'});
    end

    schema.prop(this,'deviceNamePopup','ustring');
    schema.prop(this,'deviceList','mxArray');
    schema.prop(this,'sampleRate','ustring');
    schema.prop(this,'deviceDatatype','FromAudioDevice_DeviceDatatypeEnum');
    schema.prop(this,'autoBufferSize','bool');
    schema.prop(this,'bufferSize','ustring');
    schema.prop(this,'queueDuration','ustring');
    schema.prop(this,'numChannels','ustring');
    schema.prop(this,'outputNumOverrunSamples','bool');
    schema.prop(this,'frameSize','ustring');
    schema.prop(this,'outputDatatype','FromAudioDevice_OutputDatatypeEnum');
    schema.prop(this,'defaultInputChannelMapping','bool');
    schema.prop(this,'inputChannelMapping','ustring');
