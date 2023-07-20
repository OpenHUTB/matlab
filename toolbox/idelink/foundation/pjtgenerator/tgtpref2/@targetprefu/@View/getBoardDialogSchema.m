function dlgstruct=getBoardDialogSchema(hView,Data,name)%#ok<INUSD>




    tagprefix='TargetPrefBoard_';

    BoardNameLabel.Name=hView.mLabels.Board.BoardName;
    BoardNameLabel.Type='text';
    BoardNameLabel.RowSpan=[1,1];
    BoardNameLabel.ColSpan=[1,1];
    BoardNameLabel.Buddy=[tagprefix,'BoardName'];

    BoardName.Type='combobox';
    BoardName.Entries=Data.getBoardTypeList();
    BoardName.Value=Data.getBoardTypeDisplayName();
    BoardName.Tag=[tagprefix,'BoardName'];
    BoardName.RowSpan=[1,1];
    BoardName.ColSpan=[2,2];
    if(1==length(BoardName.Entries))
        BoardName.Enabled=false;
    else
        BoardName.Enabled=true;
    end
    if(hView.mController.isFactoryBoard())
        BoardName.ToolTip=sprintf(hView.mToolTips.Board.BoardNameFactory,BoardName.Value);
    else
        BoardName.ToolTip=hView.mToolTips.Board.BoardName;
    end
    BoardName.DialogRefresh=true;
    BoardName=hView.addControllerCallBack(BoardName,'setBoardType','%value');

    ProcessorNameLabel.Name=hView.mLabels.Board.ProcessorName;
    ProcessorNameLabel.Type='text';
    ProcessorNameLabel.RowSpan=[2,2];
    ProcessorNameLabel.ColSpan=[1,1];
    ProcessorNameLabel.Buddy=[tagprefix,'ProcessorName'];

    ProcessorName.Type='combobox';
    ProcessorName.Entries=hView.mController.getChipNameList();
    ProcessorName.Value=Data.getCurChipName();
    ProcessorName.Tag=[tagprefix,'ProcessorName'];
    ProcessorName.ToolTip=hView.mToolTips.Board.ProcessorName;
    ProcessorName.DialogRefresh=true;
    ProcessorName.RowSpan=[2,2];
    ProcessorName.ColSpan=[2,2];
    if(1==length(ProcessorName.Entries))
        ProcessorName.Enabled=false;
    else
        ProcessorName.Enabled=true;
    end
    ProcessorName=hView.addControllerCallBack(ProcessorName,'setProcessorName','%value');

    AddProcessor.Name=hView.mLabels.Board.AddProcessor;
    AddProcessor.Type='pushbutton';
    AddProcessor.Tag=[tagprefix,'AddProcessor'];
    AddProcessor.ToolTip=hView.mToolTips.Board.AddProcessor;
    AddProcessor.RowSpan=[2,2];
    AddProcessor.ColSpan=[3,3];
    AddProcessor.DialogRefresh=true;
    AddProcessor.Enabled=hView.mController.isAddProcessorEnabled();
    AddProcessor=hView.addControllerCallBack(AddProcessor,'addProcessor',ProcessorName.Tag);

    DeleteProcessor.Name=hView.mLabels.Board.DeleteProcessor;
    DeleteProcessor.Type='pushbutton';
    DeleteProcessor.Tag=[tagprefix,'DeleteProcessor'];
    DeleteProcessor.RowSpan=[2,2];
    DeleteProcessor.ColSpan=[4,4];
    DeleteProcessor.DialogRefresh=true;
    DeleteProcessor.Enabled=hView.mController.isDeleteProcessorEnabled();
    DeleteProcessor=hView.addControllerCallBack(DeleteProcessor,'deleteProcessor',ProcessorName.Tag);

    CpuClockLabel.Name=hView.mLabels.Board.CpuClock;
    CpuClockLabel.Type='text';
    CpuClockLabel.RowSpan=[3,3];
    CpuClockLabel.ColSpan=[1,1];
    CpuClockLabel.Buddy=[tagprefix,'ClockSpeed'];
    CpuClockLabel.Visible=hView.mController.isClockVisible();

    CpuClock.Type='edit';
    CpuClock.Value=Data.getClockSpeedInMHZ();
    CpuClock.Tag=[tagprefix,'ClockSpeed'];
    CpuClock.ToolTip=hView.mToolTips.Board.CpuClock;
    CpuClock.DialogRefresh=false;
    CpuClock.RowSpan=[3,3];
    CpuClock.ColSpan=[2,2];
    CpuClock.Visible=hView.mController.isClockVisible();
    CpuClock=hView.addControllerCallBack(CpuClock,'setClockSpeed','%value');

    CpuClockUnitLabel.Name=hView.mLabels.Board.CpuClockUnit;
    CpuClockUnitLabel.Type='text';
    CpuClockUnitLabel.RowSpan=[3,3];
    CpuClockUnitLabel.ColSpan=[3,3];
    CpuClockUnitLabel.Visible=hView.mController.isClockVisible();

    BoardProperties.Name=hView.mLabels.Board.Properties;
    BoardProperties.Type='group';
    BoardProperties.Items={BoardNameLabel,BoardName,...
    ProcessorNameLabel,ProcessorName,...
    CpuClockLabel,CpuClock,CpuClockUnitLabel,...
    AddProcessor,DeleteProcessor};
    BoardProperties.LayoutGrid=[3,5];
    BoardProperties.ColStretch=[0,0,0,0,1];
    BoardProperties.RowSpan=[1,1];
    BoardProperties.ColSpan=[1,1];

    OperatingSystemLabel.Name=hView.mLabels.Board.OperatingSystem;
    OperatingSystemLabel.Type='text';
    OperatingSystemLabel.RowSpan=[1,1];
    OperatingSystemLabel.ColSpan=[1,2];
    OperatingSystemLabel.Buddy=[tagprefix,'OperatingSystem'];

    OperatingSystem.Type='combobox';
    OperatingSystem.Tag=[tagprefix,'OperatingSystem'];
    OperatingSystem.Entries=Data.getSupportedOSList();
    OperatingSystem.Value=Data.getCurOS();
    OperatingSystem.Enabled=hView.mController.isRTOSEnabled();
    OperatingSystem.ToolTip=hView.mToolTips.Board.OperatingSystem;
    OperatingSystem.DialogRefresh=true;
    OperatingSystem.RowSpan=[1,1];
    OperatingSystem.ColSpan=[3,4];
    OperatingSystem=hView.addControllerCallBack(OperatingSystem,'setOperatingSystem','%value');


    SourceFilesList.Type='editarea';
    SourceFilesList.Tag=[tagprefix,'BoardSourceFiles'];
    SourceFilesList.Value=Data.getBoardSourceFiles();
    SourceFilesList.ToolTip=hView.mToolTips.Board.SourceFiles;
    SourceFilesList.DialogRefresh=false;
    SourceFilesList=hView.addControllerCallBack(SourceFilesList,'setBoardSourceFiles','%value');

    IncludePathsList.Type='editarea';
    IncludePathsList.Tag=[tagprefix,'BoardIncludePaths'];
    IncludePathsList.Value=Data.getIncludePaths();
    IncludePathsList.ToolTip=hView.mToolTips.Board.IncludePaths;
    IncludePathsList.DialogRefresh=false;
    IncludePathsList=hView.addControllerCallBack(IncludePathsList,'setIncludePaths','%value');

    LibrariesAllList.Type='editarea';
    LibrariesAllList.Tag=[tagprefix,'BoardLibraries'];
    LibrariesAllList.Value=Data.getAllLibraries();
    LibrariesAllList.ToolTip=hView.mToolTips.Board.LibrariesAll;
    LibrariesAllList.DialogRefresh=false;
    LibrariesAllList.Enabled=false;

    LibrariesLEList.Type='editarea';
    LibrariesLEList.Tag=[tagprefix,'BoardLibrariesLittleEndian'];
    LibrariesLEList.Value=Data.getLibrariesLittleEndian();
    LibrariesLEList.DialogRefresh=false;
    LibrariesLEList.Enabled=Data.isChipSupportLittleEndian();
    LibrariesLEList.ToolTip=hView.mToolTips.Board.LibrariesLE;
    LibrariesLEList=hView.addControllerCallBack(LibrariesLEList,'setLibrariesLittleEndian','%value',LibrariesAllList.Tag);

    LibrariesBEList.Type='editarea';
    LibrariesBEList.Tag=[tagprefix,'BoardLibrariesBigEndian'];
    LibrariesBEList.Value=Data.getLibrariesBigEndian();
    LibrariesBEList.DialogRefresh=false;
    LibrariesBEList.Enabled=Data.isChipSupportBigEndian();
    LibrariesBEList.ToolTip=hView.mToolTips.Board.LibrariesBE;
    LibrariesBEList=hView.addControllerCallBack(LibrariesBEList,'setLibrariesBigEndian','%value',LibrariesAllList.Tag);

    InitFunction.Type='editarea';
    InitFunction.Tag=[tagprefix,'BoardInitFunction'];
    InitFunction.Value=Data.getInitFunction();
    InitFunction.DialogRefresh=false;
    InitFunction.ToolTip=hView.mToolTips.Board.InitFunction;
    InitFunction=hView.addControllerCallBack(InitFunction,'setInitFunction','%value');

    TerminateFunction.Type='editarea';
    TerminateFunction.Tag=[tagprefix,'BoardTerminateFunction'];
    TerminateFunction.Value=Data.getTerminateFunction();
    TerminateFunction.DialogRefresh=false;
    TerminateFunction.ToolTip=hView.mToolTips.Board.TerminateFunction;
    TerminateFunction=hView.addControllerCallBack(TerminateFunction,'setTerminateFunction','%value');

    BoardCustomCodeStack.Type='widgetstack';
    BoardCustomCodeStack.Tag=[tagprefix,'BoardCustomCodeStack'];
    BoardCustomCodeStack.ActiveWidget=0;
    BoardCustomCodeStack.Items={SourceFilesList,IncludePathsList,...
    LibrariesAllList,LibrariesLEList,LibrariesBEList,...
    InitFunction,TerminateFunction};
    BoardCustomCodeStack.RowSpan=[2,6];
    BoardCustomCodeStack.ColSpan=[4,6];


    BoardCustomCode.Name=hView.mLabels.Board.CustomCode;
    BoardCustomCode.Type='tree';
    BoardCustomCode.TreeItems={...
    hView.mLabels.BoardSupport.SourceFiles,...
    hView.mLabels.BoardSupport.IncludePaths,...
    hView.mLabels.BoardSupport.Libraries,...
    {hView.mLabels.BoardSupport.Libraries_Little,...
    hView.mLabels.BoardSupport.Libraries_Big},...
    hView.mLabels.BoardSupport.InitializeFunctions,...
    hView.mLabels.BoardSupport.TerminateFunctions};
    BoardCustomCode.TreeItemIds={0,1,2,{3,4},5,6};
    BoardCustomCode.Tag=[tagprefix,'BoardCustomCodeTree'];
    BoardCustomCode.TargetWidget=[tagprefix,'BoardCustomCodeStack'];
    BoardCustomCode.Value=BoardCustomCode.TreeItems{1};
    BoardCustomCode.RowSpan=[2,6];
    BoardCustomCode.ColSpan=[1,3];
    BoardCustomCode.Graphical=true;
    BoardCustomCode.MinimumSize=[128,128];

    CodeGenProperties.Name=hView.mLabels.Board.CodeGenProperties;
    CodeGenProperties.Type='group';
    CodeGenProperties.Items={OperatingSystemLabel,OperatingSystem,...
    BoardCustomCode,BoardCustomCodeStack...
    };
    CodeGenProperties.LayoutGrid=[2,6];
    CodeGenProperties.ColStretch=[0,0,0,0,0,1];
    CodeGenProperties.RowSpan=[2,2];
    CodeGenProperties.ColSpan=[1,1];

    if(hView.mController.isIdeOptionEnabled())
        IDERefresh.Name=hView.mLabels.Board.IDERefresh;
        IDERefresh.Type='pushbutton';
        IDERefresh.Tag=[tagprefix,'IDERefresh'];
        IDERefresh.RowSpan=[1,1];
        IDERefresh.ColSpan=[5,5];
        IDERefresh.DialogRefresh=true;
        IDERefresh.ToolTip=hView.mToolTips.Board.IDERefresh;
        IDERefresh=hView.addControllerCallBack(IDERefresh,'ideRefresh');

        curOption=Data.getIDEOptions();
        if(~isempty(curOption{1})&&~isempty(curOption{2}))
            IDECurSetting.Name=sprintf('%s, %s',curOption{1},curOption{2});
        else
            IDECurSetting.Name='';
        end
        IDECurSetting.Type='text';
        IDECurSetting.Tag=[tagprefix,'IDECurrentSetting'];
        IDECurSetting.ToolTip=hView.mToolTips.Board.IDECurSetting;
        IDECurSetting.RowSpan=[1,1];
        IDECurSetting.ColSpan=[1,4];

        OptionLabel=struct('Name',{'',''});
        Option=cell(2,1);

        for i=1:2
            OptionLabel(i).Name=hView.mController.getIdeOptionName(i);
            OptionLabel(i).Type='text';
            OptionLabel(i).RowSpan=[1+i,1+i];
            OptionLabel(i).ColSpan=[1,2];
            OptionLabel(i).Buddy=sprintf([tagprefix,'IDEOption%d'],i);
            OptionLabel(i).Visible=hView.mController.isIdeOptionVisible(i);

            OptionTemp.Tag=sprintf([tagprefix,'IDEOption%d'],i);
            OptionTemp.RowSpan=[1+i,1+i];
            OptionTemp.Type=hView.mController.getIdeOptionType(i);
            OptionTemp.Entries=hView.mController.getIdeOptionList(i);
            if(strcmpi(OptionTemp.Type,'combobox'))
                OptionTemp.ColSpan=[3,5];
            else
                OptionTemp.ColSpan=[3,6];
            end
            OptionTemp.Value=hView.mController.getIdeCurOption(i);
            OptionTemp.Visible=hView.mController.isIdeOptionVisible(i);
            OptionTemp=hView.addControllerCallBack(OptionTemp,'setIDEOption','%value',i);
            Option{i}=OptionTemp;
        end
        IDEProperties.Name=hView.mLabels.Board.IDEProperties;
        IDEProperties.Type='group';
        IDEProperties.Items={IDERefresh,IDECurSetting,...
        OptionLabel(1),Option{1},...
        OptionLabel(2),Option{2}...
        };
        IDEProperties.LayoutGrid=[3,6];
        IDEProperties.ColStretch=[0,0,0,1,0,0];
        IDEProperties.RowSpan=[3,3];
        IDEProperties.ColSpan=[1,1];
    end


    spacer.Type='panel';
    spacer.RowSpan=[3,3];
    spacer.ColSpan=[1,2];

    BoardSchemaItems.Type='panel';
    BoardSchemaItems.Tag=[tagprefix,'panel'];
    BoardSchemaItems.Items={BoardProperties,CodeGenProperties,spacer};
    if(hView.mController.isIdeOptionEnabled())
        spacer.RowSpan=[4,4];
        BoardSchemaItems.LayoutGrid=[4,9];
        BoardSchemaItems.Items{end+1}=IDEProperties;
        BoardSchemaItems.Items{end+1}=spacer;
        BoardSchemaItems.RowStretch=[0,0,1,1];
    else
        BoardSchemaItems.LayoutGrid=[3,9];
        BoardSchemaItems.RowStretch=[0,0,1];
    end

    dlgstruct.Name=hView.mLabels.Board.Name;
    dlgstruct.Items={BoardSchemaItems};
