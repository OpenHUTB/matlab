function dlgStruct=getDialogSchema(this,path)%#ok<INUSD>











    FileNameEdit=dspGetLeafWidgetBase('edit',getString(message('dspshared:ToMMFile:FileName')),...
    'outputFilename',this,'outputFilename');
    FileNameEdit.Entries=set(this,'outputFilename')';
    FileNameEdit.RowSpan=[1,1];
    FileNameEdit.ColSpan=[1,9];

    BrowseButton=dspGetContainerWidgetBase('pushbutton',getString(message('dspshared:ToMMFile:SaveAs')),...
    'FileSelect');
    BrowseButton.ObjectMethod='FileSelect';
    BrowseButton.MethodArgs={'%dialog'};
    BrowseButton.ArgDataTypes={'handle'};
    BrowseButton.RowSpan=[1,1];
    BrowseButton.ColSpan=[10,10];
    BrowseButton.Tunable=0;

    FileTypeMenu=dspGetLeafWidgetBase('combobox',getString(message('dspshared:ToMMFile:FileType')),...
    'fileTypePopup',this,'fileTypePopup');
    FileTypeMenu.Entries=this.fileType;
    FileTypeMenu.RowSpan=[2,2];
    FileTypeMenu.ColSpan=[1,10];
    FileTypeMenu.DialogRefresh=1;
    FileTypeMenu.Enabled=true;

    isFileTypeFlac=strcmp(this.fileTypePopup,'FLAC');
    isFileTypeOgg=strcmp(this.fileTypePopup,'OGG')||strcmp(this.fileTypePopup,'OPUS');
    isFileTypeMpeg4=strcmp(this.fileTypePopup,'MPEG4');
    isFileTypeMj2000=strcmp(this.fileTypePopup,'MJ2000');



    fileTypeInfo=dspFileTypeInfoToMultimediaFile(this.fileTypePopup);

    StreamSelectionMenu=dspGetLeafWidgetBase('combobox',getString(message('dspshared:ToMMFile:Write')),...
    'stream-Selection',this,'streamSelection');

    supportedStreams=fileTypeInfo.AllWriteableStreams;


    if~ismember(this.streamSelection,supportedStreams)
        this.streamSelection=fileTypeInfo.DefaultWriteableStream;
    end
    StreamSelectionMenu.Entries=supportedStreams;
    StreamSelectionMenu.RowSpan=[3,3];
    StreamSelectionMenu.ColSpan=[1,10];
    StreamSelectionMenu.DialogRefresh=1;


    StreamSelectionMenu.Visible=~isscalar(supportedStreams)||isFileTypeOgg;
    StreamSelectionMenu.Enabled=~isscalar(supportedStreams)&&~isFileTypeOgg;


    streamContainsAudio=~isempty(strfind(this.streamSelection,'udio'));
    streamContainsVideo=~isempty(strfind(this.streamSelection,'Video'));


    AudioCompressorMenu=dspGetLeafWidgetBase('combobox',getString(message('dspshared:ToMMFile:AudioCompressor')),...
    'audioCompressorPopup',this,'audioCompressorPopup');
    audioCompressors=fileTypeInfo.AudioCompressors;


    if~isempty(audioCompressors)


        if~ismember(this.audioCompressorPopup,audioCompressors)
            this.audioCompressorPopup=fileTypeInfo.DefaultAudioCompressor;
        end
        AudioCompressorMenu.Entries=audioCompressors;
    else
        AudioCompressorMenu.Entries={''};
    end

    AudioCompressorMenu.RowSpan=[4,4];
    AudioCompressorMenu.ColSpan=[2,10];
    AudioCompressorMenu.DialogRefresh=1;
    AudioCompressorMenu.Visible=streamContainsAudio&&~isempty(audioCompressors);
    AudioCompressorMenu.Enabled=streamContainsAudio&&~isempty(audioCompressors);
    if~ispc


        isFileTypeAvi=ismember(this.FileTypePopup,{'AVI','WAV'});
        AudioCompressorMenu.Visible=isFileTypeAvi&&streamContainsAudio;
        AudioCompressorMenu.Enabled=false;
    end


    selectedNoneAudioCompression=~isempty(strfind(this.audioCompressorPopup,'uncompressed'));


    AudioDatatype=dspGetLeafWidgetBase('combobox',getString(message('dspshared:ToMMFile:AudioDataType')),...
    'audioDatatype',this,'audioDatatype');
    audioDataTypes=fileTypeInfo.AudioDataTypes;


    if~isempty(audioDataTypes)
        AudioDatatype.Entries=audioDataTypes;


        if~ismember(this.audioDataType,audioDataTypes)
            this.audioDataType=fileTypeInfo.DefaultAudioDataType;
        end
    end
    AudioDatatype.DialogRefresh=1;
    AudioDatatype.RowSpan=[5,5];
    AudioDatatype.ColSpan=[2,10];

    AudioDatatype.Visible=streamContainsAudio&&...
    ((selectedNoneAudioCompression&&~isempty(audioCompressors))||isFileTypeFlac)&&...
    ~isempty(audioDataTypes);
    AudioDatatype.Enabled=streamContainsAudio&&...
    ((selectedNoneAudioCompression&&~isempty(audioCompressors))||isFileTypeFlac)&&...
    ~isempty(audioDataTypes);


    VideoCompressorMenu=dspGetLeafWidgetBase('combobox',getString(message('dspshared:ToMMFile:VideoCompressor')),...
    'videoCompressorPopup',this,'videoCompressorPopup');
    videoCompressors=fileTypeInfo.VideoCompressors;


    if~isempty(videoCompressors)
        VideoCompressorMenu.Entries=videoCompressors;


        if~ismember(this.videoCompressorPopup,videoCompressors)
            this.videoCompressorPopup=fileTypeInfo.DefaultVideoCompressor;
        end
    else
        VideoCompressorMenu.Entries={''};
    end
    VideoCompressorMenu.RowSpan=[6,6];
    VideoCompressorMenu.ColSpan=[2,10];
    VideoCompressorMenu.DialogRefresh=1;
    vCompVisible=streamContainsVideo&&~isempty(videoCompressors);
    vCompEnabled=streamContainsVideo&&~isempty(videoCompressors);
    if~ispc




        isFileTypeAvi=strcmp(this.FileTypePopup,'AVI');

        vCompEnabled=streamContainsVideo&&~isempty(videoCompressors)&&~isFileTypeAvi;



        if isFileTypeAvi&&streamContainsAudio
            this.VideoCompressorPopup=fileTypeInfo.DefaultVideoCompressor;
        end
        vCompVisible=vCompVisible||(isFileTypeAvi&&streamContainsVideo&&~isempty(videoCompressors));
        vCompEnabled=vCompEnabled||(isFileTypeAvi&&streamContainsVideo&&~streamContainsAudio);
    end
    VideoCompressorMenu.Visible=vCompVisible;
    VideoCompressorMenu.Enabled=vCompEnabled;




    QualityEdit=dspGetLeafWidgetBase('edit',getString(message('dspshared:ToMMFile:VideoQuality0100')),...
    'videoQuality',this,'videoQuality');
    QualityEdit.Entries=set(this,'videoQuality')';
    QualityEdit.RowSpan=[7,7];
    QualityEdit.ColSpan=[2,7];
    QualityEdit.DialogRefresh=1;
    qualityEnabled=isFileTypeMpeg4&&streamContainsVideo&&~streamContainsAudio;
    if~ispc

        isMjpegAvi=strcmp(this.fileTypePopup,'AVI')&&strcmp(this.VideoCompressorPopup,'MJPEG Compressor');
        qualityEnabled=qualityEnabled||(isMjpegAvi&&streamContainsVideo&&~streamContainsAudio);
    end
    QualityEdit.Enabled=qualityEnabled;
    QualityEdit.Visible=qualityEnabled;


    selectedLossyVideoCompression=~isempty(strfind(this.videoCompressorPopup,'Lossy'));
    CompressionFactorEdit=dspGetLeafWidgetBase('edit',getString(message('dspshared:ToMMFile:CompressionFactor1')),...
    'mj2000CompFactor',this,'mj2000CompFactor');
    CompressionFactorEdit.Entries=set(this,'mj2000CompFactor')';
    CompressionFactorEdit.RowSpan=[7,7];
    CompressionFactorEdit.ColSpan=[2,9];
    CompressionFactorEdit.DialogRefresh=1;
    CompressionFactorEdit.Enabled=isFileTypeMj2000&&selectedLossyVideoCompression;
    CompressionFactorEdit.Visible=isFileTypeMj2000&&selectedLossyVideoCompression;


    FileColorspace=dspGetLeafWidgetBase('combobox',getString(message('dspshared:ToMMFile:FileColorFormat')),...
    'fileColorspace',this,'fileColorspace');
    fileColorFormats=fileTypeInfo.FileColorFormats;


    if~isempty(fileColorFormats)
        FileColorspace.Entries=fileColorFormats;


        if~ismember(this.fileColorspace,fileColorFormats)
            this.fileColorspace=fileTypeInfo.DefaultFileColorFormat;
        end
    end
    FileColorspace.RowSpan=[8,8];
    FileColorspace.ColSpan=[2,10];
    FileColorspace.DialogRefresh=1;
    FileColorspace.Visible=streamContainsVideo&&(~isempty(fileColorFormats)&&~isscalar(fileColorFormats));
    FileColorspace.Enabled=streamContainsVideo&&(~isempty(fileColorFormats)&&~isscalar(fileColorFormats));


    selectedYCbCr422ColorSpace=~isempty(strfind(this.fileColorspace,'YCbCr 4:2:2'));


    ImagePorts=dspGetLeafWidgetBase('combobox',getString(message('dspshared:ToMMFile:ImageSignal')),'imagePorts',this,'imagePorts');
    inputImagePorts=fileTypeInfo.InputImagePorts;
    if~isempty(inputImagePorts)
        ImagePorts.Entries=inputImagePorts;


        if~ismember(this.imagePorts,inputImagePorts)
            this.imagePorts=fileTypeInfo.DefaultInputImagePort;
        end
    end
    ImagePorts.RowSpan=[9,9];
    ImagePorts.ColSpan=[2,10];
    ImagePorts.DialogRefresh=1;
    ImagePorts.Visible=streamContainsVideo&&~selectedYCbCr422ColorSpace&&~isempty(inputImagePorts);
    ImagePorts.Enabled=streamContainsVideo&&~selectedYCbCr422ColorSpace&&~isempty(inputImagePorts);






    parameterPane=dspGetContainerWidgetBase('group',getString(message('dspshared:FromMMFile:Parameters')),'parameterPane');
    parameterPane.Items=dspTrimItemList({FileNameEdit,BrowseButton,FileTypeMenu,...
    StreamSelectionMenu,AudioCompressorMenu,AudioDatatype,...
    VideoCompressorMenu,QualityEdit,CompressionFactorEdit,...
    FileColorspace,ImagePorts});
    parameterPane.RowSpan=[2,2];
    parameterPane.ColSpan=[1,1];
    parameterPane.LayoutGrid=[3,11];
    parameterPane.Tag='parameterPane';





    dlgStruct=getBaseSchemaStruct(this,parameterPane);
    title=this.Block.Name;
    title(double(title)==10)=' ';
    dlgStruct.DialogTitle=[getString(message('dspshared:ToMMFile:SinkBlockParameters')),title];


    dlgStruct.OpenCallback=@enableApply;
    function enableApply(dialog)
        if~strcmp(this.Block.audioCompressor,this.audioCompressorPopup)||...
            ~strcmp(this.Block.videoCompressor,this.videoCompressorPopup)
            dialog.enableApplyButton(true);
        end
    end

end
