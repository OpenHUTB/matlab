function dlgStruct=getDialogSchema(this,~)











    MaxRowsInAnyTab=7;


    foundFilename=dspmaskFromMultimediaFile('searchForFile',this.inputFilename);
    if(isempty(foundFilename))


        [videoFileInfo,audioFileInfo,VErr]=dspaudiovideofileinfo(this.inputFilename);
    else

        [videoFileInfo,audioFileInfo,VErr]=dspaudiovideofileinfo(foundFilename);
    end
    hasAudio=~isempty(audioFileInfo);
    hasVideo=~isempty(videoFileInfo);
    hasAudioVideo=hasVideo&&videoFileInfo.hasAudio;
    if~hasAudio&&~hasVideo
        warning(message('dspshared:FromMMFile:unhandledCase',VErr.message));
    end

    FileNameEdit=dspGetLeafWidgetBase('edit',getString(message('dspshared:FromMMFile:FileName')),...
    'inputFilename',this,'inputFilename');
    FileNameEdit.Entries=set(this,'inputFilename')';
    FileNameEdit.RowSpan=[1,1];
    FileNameEdit.ColSpan=[1,9];
    FileNameEdit.DialogRefresh=1;

    BrowseButton=dspGetContainerWidgetBase('pushbutton',getString(message('dspshared:FromMMFile:Browse')),'FileSelect');
    BrowseButton.ObjectMethod='FileSelect';
    BrowseButton.MethodArgs={'%dialog'};
    BrowseButton.ArgDataTypes={'handle'};
    BrowseButton.RowSpan=[1,1];
    BrowseButton.ColSpan=[10,10];
    BrowseButton.Tunable=0;

    LoopCBox=dspGetLeafWidgetBase('checkbox',getString(message('dspshared:FromMMFile:Loop')),'loop',this,'loop');
    LoopCBox.Entries=set(this,'loop')';
    LoopCBox.RowSpan=[4,4];
    LoopCBox.ColSpan=[1,1];
    LoopCBox.DialogRefresh=1;
    LoopCBox.Visible=0;

    InheritSTimeCBox=dspGetLeafWidgetBase('checkbox',getString(message('dspshared:FromMMFile:InheritSampleTimeFromFile')),...
    'inheritSampleTime',this,'inheritSampleTime');
    InheritSTimeCBox.Entries=set(this,'inheritSampleTime')';
    InheritSTimeCBox.RowSpan=[2,2];
    InheritSTimeCBox.ColSpan=[1,5];
    InheritSTimeCBox.DialogRefresh=1;

    UserSTimeEdit=dspGetLeafWidgetBase('edit',getString(message('dspshared:FromMMFile:DesiredSampleTime')),...
    'userDefinedSampleTime',this,'userDefinedSampleTime');
    UserSTimeEdit.Entries=set(this,'userDefinedSampleTime')';
    UserSTimeEdit.RowSpan=[2,2];
    UserSTimeEdit.ColSpan=[6,10];

    UserSTimeEdit.Visible=this.inheritSampleTime~=1;

    NumLoopsEdit=dspGetLeafWidgetBase('edit',getString(message('dspshared:FromMMFile:NumberOfTimesToPlayFile')),...
    'numPlays',this,'numPlays');
    NumLoopsEdit.Entries=set(this,'numPlays')';
    NumLoopsEdit.RowSpan=[3,3];
    NumLoopsEdit.ColSpan=[1,10];

    ReadRangeEdit=dspGetLeafWidgetBase('edit',getString(message('dspshared:FromMMFile:ReadRange')),...
    'readRange',this,'readRange');
    ReadRangeEdit.Entries=set(this,'readRange')';
    ReadRangeEdit.RowSpan=[4,4];
    ReadRangeEdit.ColSpan=[1,9];
    ReadRangeEdit.DialogRefresh=1;
    ReadRangeEdit.Visible=0;


    if this.loop==1
        NumLoopsEdit.Enabled=1;
    else
        NumLoopsEdit.Enabled=0;
    end




    OutputEOFCBox=dspGetLeafWidgetBase('checkbox',getString(message('dspshared:FromMMFile:OutputEndoffileIndicator')),...
    'outputEOF',this,'outputEOF');
    OutputEOFCBox.Entries=set(this,'outputEOF');
    OutputEOFCBox.RowSpan=[1,1];
    OutputEOFCBox.ColSpan=[1,10];
    OutputEOFCBox.DialogRefresh=1;

    outputFormat=dspGetLeafWidgetBase('combobox',getString(message('dspshared:FromMMFile:OutputColorFormat')),...
    'outputFormat',this,'outputFormat');
    outputFormat.Entries=set(this,'outputFormat');
    outputFormat.RowSpan=[3,3];
    outputFormat.ColSpan=[1,3];
    outputFormat.DialogRefresh=1;

    colorVideoFormat=dspGetLeafWidgetBase('combobox',getString(message('dspshared:FromMMFile:ImageSignal')),...
    'colorVideoFormat',this,'colorVideoFormat');
    colorVideoFormat.Entries=this.Block.getPropAllowedValues('colorVideoFormat',true);

    isImageDataTypeSupported=slfeature('SimulinkImageBlockSupport');

    if isImageDataTypeSupported>0&&strcmp(this.outputFormat,'Intensity')
        colorVideoFormat.Entries(2)=[];
    end

    if isImageDataTypeSupported==0&&strcmp(this.outputFormat,'RGB')
        colorVideoFormat.Entries(3)=[];
    end

    colorVideoFormat.DialogRefresh=1;

    colorVideoFormat.RowSpan=[3,3];
    colorVideoFormat.ColSpan=[4,10];
    colorVideoFormat.DialogRefresh=1;
    colorVideoFormat.Visible=1;



    outputStreams=dspGetLeafWidgetBase('combobox',...
    getString(message('dspshared:FromMMFile:MultimediaOutputs')),...
    'outputStreamsPopup',...
    this,'outputStreamsPopup');
    audioOnly=getString(message('dspshared:FromMMFile:AudioOnly'));
    videoOnly=getString(message('dspshared:FromMMFile:VideoOnly'));
    videoAndAudio=getString(message('dspshared:FromMMFile:VideoAndAudio'));
    outputList={videoAndAudio,videoOnly,audioOnly};
    outputStreams.Entries=outputList;
    outputStreams.RowSpan=[2,2];
    outputStreams.ColSpan=[1,10];
    if hasAudioVideo

        outputStreams.Visible=1;
        outputStreams.Enabled=1;
        outputStreams.DialogRefresh=1;
    elseif~hasAudio&&~hasVideo



    elseif hasAudio&&hasVideo

        outputStreams.Visible=1;
        outputStreams.Enabled=1;
        outputList={videoOnly,audioOnly};
        outputStreams.Entries=outputList;
        if strcmp(this.outputStreamsPopup,videoAndAudio)

            this.outputStreamsPopup=videoOnly;
        end
        outputStreams.DialogRefresh=1;
    else

        outputStreams.Visible=0;
        outputStreams.Enabled=0;
        if hasVideo
            this.outputStreamsPopup=videoOnly;
        elseif hasAudio
            this.outputStreamsPopup=audioOnly;
        else
            this.outputStreamsPopup=videoAndAudio;
        end
        outputStreams.DialogRefresh=1;
    end

    AudioFrameSizeEdit=dspGetLeafWidgetBase('edit',getString(message('dspshared:FromMMFile:SamplesPerAudioChannel')),...
    'audioFrameSize',this,'audioFrameSize');
    AudioFrameSizeEdit.Entries=set(this,'audioFrameSize')';
    AudioFrameSizeEdit.RowSpan=[4,4];
    AudioFrameSizeEdit.ColSpan=[1,10];


    AudioFrameSizeEdit.Visible=strcmp(this.outputStreamsPopup,audioOnly)&&hasAudio;


    outSamplingMode=dspGetLeafWidgetBase('combobox',getString(message('dspshared:FromMMFile:AudioOutputSamplingMode')),...
    'outSamplingMode',this,'outSamplingMode');
    outSamplingMode.Entries=this.Block.getPropAllowedValues('outSamplingMode',true);
    outSamplingMode.Visible=false;
    outSamplingMode.RowSpan=[5,5];
    outSamplingMode.ColSpan=[1,10];


    ReadRangeEdit.Visible=(hasAudio&&~hasVideo)||strcmp(this.outputStreamsPopup,audioOnly);

    if(strcmp(this.outputStreamsPopup,audioOnly))

        outputFormat.Visible=false;
        colorVideoFormat.Visible=false;
    else

        outputFormat.Visible=true;
        if strcmp(this.outputFormat,'RGB')||(strcmp(this.outputFormat,'Intensity')&&isImageDataTypeSupported>0)
            colorVideoFormat.Visible=true;
        else
            colorVideoFormat.Visible=false;
        end
    end



    paramsGroup=dspGetContainerWidgetBase('group',getString(message('dspshared:FromMMFile:Parameters')),'paramsGroup');
    paramsGroup.Items=dspTrimItemList({FileNameEdit,BrowseButton,ReadRangeEdit,LoopCBox,InheritSTimeCBox,...
    UserSTimeEdit,NumLoopsEdit});
    paramsGroup.RowSpan=[1,1];
    paramsGroup.ColSpan=[1,1];
    paramsGroup.LayoutGrid=[7,2];
    paramsGroup.Tag='paramsGroup';

    outputGroup=dspGetContainerWidgetBase('group',getString(message('dspshared:FromMMFile:Outputs')),'outputGroup');
    outputGroup.Items=dspTrimItemList({OutputEOFCBox,outputStreams,AudioFrameSizeEdit,...
    outSamplingMode,outputFormat,colorVideoFormat,});

    outputGroup.RowSpan=[2,2];
    outputGroup.ColSpan=[1,1];
    outputGroup.LayoutGrid=[7,2];
    outputGroup.Tag='outputGroup';



    mainTab.Name=getString(message('dspshared:FixptDialog:main'));
    mainTab.Items={paramsGroup,outputGroup};



    VideoDataTypeMenu=dspGetLeafWidgetBase('combobox',getString(message('dspshared:FromMMFile:VideoOutputDataType')),...
    'videoDataType',this,'videoDataType');
    VideoDataTypeMenu.Entries=this.Block.getPropAllowedValues('videoDataType',true);
    VideoDataTypeMenu.RowSpan=[1,1];
    VideoDataTypeMenu.ColSpan=[1,1];
    VideoDataTypeMenu.DialogRefresh=1;

    AudioDataTypeMenu=dspGetLeafWidgetBase('combobox',getString(message('dspshared:FromMMFile:AudioOutputDataType')),...
    'audioDataType',this,'audioDataType');
    AudioDataTypeMenu.Entries=this.Block.getPropAllowedValues('audioDataType',true);
    AudioDataTypeMenu.RowSpan=[2,2];
    AudioDataTypeMenu.ColSpan=[1,1];
    AudioDataTypeMenu.DialogRefresh=1;

    if(hasAudioVideo||(hasAudio&&hasVideo))
        if(strcmp(this.outputStreamsPopup,videoOnly))
            VideoDataTypeMenu.Visible=true;
            AudioDataTypeMenu.Visible=false;
        elseif(strcmp(this.outputStreamsPopup,audioOnly))
            VideoDataTypeMenu.Visible=false;
            AudioDataTypeMenu.Visible=true;
        else
            VideoDataTypeMenu.Visible=true;
            AudioDataTypeMenu.Visible=true;
        end
    elseif(hasVideo)
        VideoDataTypeMenu.Visible=true;
        AudioDataTypeMenu.Visible=false;
    elseif(hasAudio)
        VideoDataTypeMenu.Visible=false;
        AudioDataTypeMenu.Visible=true;
    else
        VideoDataTypeMenu.Visible=false;
        AudioDataTypeMenu.Visible=false;
    end

    dataTypesGroup=dspGetContainerWidgetBase('group','Parameters','dataTypesGroup');
    dataTypesGroup.Items=dspTrimItemList({VideoDataTypeMenu,AudioDataTypeMenu});


    dataTypesGroup.LayoutGrid=[MaxRowsInAnyTab,2];
    dataTypesGroup.RowStretch=[zeros(1,MaxRowsInAnyTab-1),1];
    dataTypesGroup.Tag='dataTypesGroup';


    datatypeTab.Name=getString(message('dspshared:FixptDialog:dataTypes'));
    datatypeTab.Items={dataTypesGroup};

    tabcontainer=dspGetContainerWidgetBase('tab','','tabPane');
    tabcontainer.Tabs={mainTab,datatypeTab};
    tabcontainer.RowSpan=[2,2];
    tabcontainer.ColSpan=[1,1];





    dlgStruct=this.getBaseSchemaStruct(tabcontainer);


