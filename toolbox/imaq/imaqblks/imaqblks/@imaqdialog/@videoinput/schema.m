function schema







    parentPkg=findpackage('Simulink');
    parent=findclass(parentPkg,'SLDialogSource');
    package=findpackage('imaqdialog');
    hThisClass=schema.class(package,'videoinput',parent);



    p=schema.prop(hThisClass,'Block','handle');%#ok<NASGU>
    schema.prop(hThisClass,'Root','Simulink.BlockDiagram');


    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'updateBlockParams');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};


    if isempty(findtype('VideoInputBlockVideoDataTypeEnum'))
        schema.EnumType('VideoInputBlockVideoDataTypeEnum',...
        {'double',...
        'single',...
        'int8',...
        'uint8',...
        'int16',...
        'uint16',...
        'int32',...
        'uint32'});
    end

    if isempty(findtype('VideoInputBlockFrameRateEnum'))
        schema.EnumType('VideoInputBlockFrameRateEnum',...
        {'5 fps',...
        '10 fps',...
        '15 fps',...
        '20 fps',...
        '25 fps',...
        '30 fps'});
    end

    schema.prop(hThisClass,'VideoDeviceMenu','string');
    schema.prop(hThisClass,'VideoDevice','string');

    schema.prop(hThisClass,'VideoStreamFormatMenu','string');
    schema.prop(hThisClass,'VideoStreamFormat','string');

    schema.prop(hThisClass,'VideoFrameSizeMenu','string');
    schema.prop(hThisClass,'VideoFrameSize','string');

    schema.prop(hThisClass,'FrameRate','VideoInputBlockFrameRateEnum');

    schema.prop(hThisClass,'DataType','VideoInputBlockVideoDataTypeEnum');
