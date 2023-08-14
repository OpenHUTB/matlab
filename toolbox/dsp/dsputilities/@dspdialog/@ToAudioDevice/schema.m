function schema




    package=findpackage('dspdialog');
    parent=findclass(package,'DSPDDG');

    this=schema.class(package,'ToAudioDevice',parent);


    m=schema.method(this,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(this,'maskInit','static');
    s=m.Signature;
    s.InputTypes={};
    s.OutputTypes={'mxArray'};


    if isempty(findtype('ToAudioDevice_DeviceDatatypeEnum'))
        schema.EnumType('ToAudioDevice_DeviceDatatypeEnum',...
        {'Determine from input data type'...
        ,'8-bit integer','16-bit integer','24-bit integer','32-bit float'});
    end

    schema.prop(this,'deviceNamePopup','ustring');
    schema.prop(this,'deviceList','mxArray');
    schema.prop(this,'inheritSampleRate','bool');
    schema.prop(this,'sampleRate','ustring');
    schema.prop(this,'deviceDatatype','ToAudioDevice_DeviceDatatypeEnum');
    schema.prop(this,'autoBufferSize','bool');
    schema.prop(this,'bufferSize','ustring');
    schema.prop(this,'queueDuration','ustring');
    schema.prop(this,'defaultOutputChannelMapping','bool');
    schema.prop(this,'outputChannelMapping','ustring');
    schema.prop(this,'outputNumUnderrunSamples','bool');
