function schema





    package=findpackage('dvdialog');
    parent=findclass(package,'DSPDDG');

    hThisClass=schema.class(package,'FromMMFile',parent);


    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'FileSelect');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};


    if isempty(findtype('FromMMFileVideoDataTypeEnum'))
        schema.EnumType('FromMMFileVideoDataTypeEnum',...
        {'double',...
        'single',...
        'int8',...
        'uint8',...
        'int16',...
        'uint16',...
        'int32',...
        'uint32',...
        'Inherit from file'});
    end

    if isempty(findtype('FromMMFileAudioDataTypeEnum'))
        schema.EnumType('FromMMFileAudioDataTypeEnum',...
        {'double',...
        'single',...
        'int16',...
        'uint8'});
    end


    if isempty(findtype('FromMMFileVideoFormatEnum'))
        schema.EnumType('FromMMFileVideoFormatEnum',...
        {'RGB',...
        'Intensity',...
        'YCbCr 4:2:2'});
    end

    if isempty(findtype('FromMMFileVideoOutputEnum'))
        schema.EnumType('FromMMFileVideoOutputEnum',...
        {'One multidimensional signal',...
        'Separate color signals',...
        'Simulink image signal'});
    end

    if isempty(findtype('FromMMFileOutSamplingModeEnum'))
        schema.EnumType('FromMMFileOutSamplingModeEnum',...
        {'Sample based',...
        'Frame based'});
    end

    schema.prop(hThisClass,'inputFilename','ustring');
    schema.prop(hThisClass,'loop','bool');
    schema.prop(hThisClass,'numPlays','ustring');
    schema.prop(hThisClass,'readRange','ustring');
    schema.prop(hThisClass,'videoDataType','FromMMFileVideoDataTypeEnum');
    schema.prop(hThisClass,'audioDataType','FromMMFileAudioDataTypeEnum');
    schema.prop(hThisClass,'colorVideoFormat','FromMMFileVideoOutputEnum');
    schema.prop(hThisClass,'inheritSampleTime','bool');
    schema.prop(hThisClass,'userDefinedSampleTime','ustring');
    schema.prop(hThisClass,'isIntensityVideo','ustring');
    schema.prop(hThisClass,'outputFormat','FromMMFileVideoFormatEnum');
    schema.prop(hThisClass,'outputEOF','bool');
    schema.prop(hThisClass,'outputStreamsPopup','ustring');
    schema.prop(hThisClass,'audioFrameSize','ustring');
    schema.prop(hThisClass,'computeAudioFrameSize','bool');
    schema.prop(hThisClass,'outSamplingMode','FromMMFileOutSamplingModeEnum');


