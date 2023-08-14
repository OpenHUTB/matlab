function schema





    package=findpackage('dvdialog');
    parent=findclass(package,'DSPDDG');

    hThisClass=schema.class(package,'ToMMFile',parent);


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


    if isempty(findtype('ToMMFileWriteStreamsEnum'))
        schema.EnumType('ToMMFileWriteStreamsEnum',...
        {'Video and audio',...
        'Video only',...
        'Audio only'});
    end


    if isempty(findtype('ToMMFile_AudioDatatypeEnum'))
        schema.EnumType('ToMMFile_AudioDatatypeEnum',...
        {'Determine from input data type'...
        ,'8-bit integer','16-bit integer','24-bit integer'...
        ,'32-bit integer','32-bit float','64-bit float'});
    end

    if isempty(findtype('ToMMFile_ImagePortsEnum'))
        schema.EnumType('ToMMFile_ImagePortsEnum',...
        {'One multidimensional signal',...
'Separate color signals'
        });
    end

    if isempty(findtype('ToMMFile_FileColorspaceEnum'))
        schema.EnumType('ToMMFile_FileColorspaceEnum',...
        {'RGB',...
'YCbCr 4:2:2'
        });
    end

    schema.prop(hThisClass,'outputFilename','ustring');
    schema.prop(hThisClass,'streamSelection','ustring');
    schema.prop(hThisClass,'videoCompressorPopup','ustring');
    schema.prop(hThisClass,'audioCompressorPopup','ustring');
    schema.prop(hThisClass,'imagePorts','ToMMFile_ImagePortsEnum');
    schema.prop(hThisClass,'audioDatatype','ToMMFile_AudioDatatypeEnum');
    schema.prop(hThisClass,'fileTypePopup','ustring');
    schema.prop(hThisClass,'fileType','mxArray');
    schema.prop(hThisClass,'fileColorspace','ToMMFile_FileColorspaceEnum');
    schema.prop(hThisClass,'videoQuality','ustring');
    schema.prop(hThisClass,'mj2000CompFactor','ustring');
