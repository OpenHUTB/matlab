


function dlg=getSlimDialogSchema(obj,~)
    blockHandle=get(obj.blockObj,'handle');
    isRunning=true;
    if strcmp(get_param(bdroot,'SimulationStatus'),'stopped')
        isRunning=false;
    end

    dlg.DialogTitle='';
    dlg.DialogMode='Slim';
    dlg.DialogRefresh=false;
    dlg.StandaloneButtonSet={''};
    dlg.EmbeddedButtonSet={''};

    dlg.CloseMethod='closeDialogCB';
    dlg.CloseMethodArgs={'%dialog','%closeaction'};
    dlg.CloseMethodArgsDT={'handle','string'};







    PortNumberTxt.Type='text';
    PortNumberTxt.Name=...
    DAStudio.message('record_playback:dialogs:NumInputPorts');
    PortNumberTxt.WordWrap=true;
    PortNumberTxt.Enabled=true;
    PortNumberTxt.RowSpan=[1,1];
    PortNumberTxt.ColSpan=[1,3];


    PortNumberValue.Type='edit';
    PortNumberValue.Tag='NumPorts';
    PortNumberValue.Value=get_param(blockHandle,'NumPorts');
    PortNumberValue.Enabled=true;
    PortNumberValue.RowSpan=[1,1];
    PortNumberValue.ColSpan=[4,5];
    PortNumberValue.MatlabMethod='utils.recordDialogUtils.setNumPorts';
    PortNumberValue.MatlabArgs={'%dialog','%tag','%value'};

    fastObj=Simulink.internal.FastRestart;
    if fastObj.isInitialized(bdroot)
        PortNumberTxt.Enabled=false;
        PortNumberValue.Enabled=false;
    end

    MainPanel.Tag='MainPanel';
    MainPanel.Type='togglepanel';
    MainPanel.Expand=true;
    MainPanel.Name=DAStudio.message('record_playback:dialogs:MainPanel');
    MainPanel.Items={PortNumberTxt,PortNumberValue};
    MainPanel.LayoutGrid=[1,5];
    MainPanel.RowStretch=[0];
    MainPanel.RowSpan=[1,1];
    MainPanel.ColSpan=[1,5];






    chkRecordToWorkspace.Tag='RecordToWorkspace';
    chkRecordToWorkspace.Type='checkbox';
    chkRecordToWorkspace.Name=DAStudio.message('record_playback:dialogs:RecordToWorkspace');
    chkRecordToWorkspace.Value=convertToBool(get_param(blockHandle,'RecordToWorkspace'));
    chkRecordToWorkspace.RowSpan=[1,1];
    chkRecordToWorkspace.ColSpan=[1,3];
    chkRecordToWorkspace.MatlabMethod='utils.recordDialogUtils.setRecordToWorkspace';
    chkRecordToWorkspace.MatlabArgs={'%dialog','%tag','%value'};
    chkRecordToWorkspace.Enabled=~isRunning;


    ToWorkspaceTxt.Type='text';
    ToWorkspaceTxt.Name=DAStudio.message('record_playback:dialogs:VariableName');
    ToWorkspaceTxt.Enabled=convertToBool(get_param(blockHandle,'RecordToWorkspace'));
    ToWorkspaceTxt.WordWrap=true;
    ToWorkspaceTxt.RowSpan=[2,2];
    ToWorkspaceTxt.ColSpan=[1,3];


    ToWorkspaceValue.Tag='VariableName';
    ToWorkspaceValue.Type='edit';
    ToWorkspaceValue.Enabled=convertToBool(get_param(blockHandle,'RecordToWorkspace'))&&~isRunning;
    ToWorkspaceValue.Value=get_param(blockHandle,'VariableName');
    ToWorkspaceValue.RowSpan=[2,2];
    ToWorkspaceValue.ColSpan=[4,5];
    ToWorkspaceValue.MatlabMethod='utils.recordDialogUtils.setToWorkspaceVariable';
    ToWorkspaceValue.MatlabArgs={'%dialog','%tag','%value'};

    grpRecordWorkspace.Tag='grpRecordWorkspace';
    grpRecordWorkspace.Type='group';
    grpRecordWorkspace.Name=DAStudio.message('record_playback:dialogs:RecordToWorkspace');
    grpRecordWorkspace.LayoutGrid=[3,5];
    grpRecordWorkspace.Items={chkRecordToWorkspace,ToWorkspaceTxt,ToWorkspaceValue};
    grpRecordWorkspace.RowSpan=[1,1];
    grpRecordWorkspace.ColSpan=[1,5];





    chkRecordToFile.Tag='RecordToFile';
    chkRecordToFile.Type='checkbox';
    chkRecordToFile.Name=DAStudio.message('record_playback:dialogs:RecordToFile');
    chkRecordToFile.Value=convertToBool(get_param(blockHandle,'RecordToFile'));
    chkRecordToFile.RowSpan=[1,1];
    chkRecordToFile.ColSpan=[1,3];
    chkRecordToFile.MatlabMethod='utils.recordDialogUtils.setRecordToFile';
    chkRecordToFile.MatlabArgs={'%dialog','%tag','%value'};
    chkRecordToFile.Enabled=~isRunning;


    ToFileTxt.Type='text';
    ToFileTxt.Name=DAStudio.message('record_playback:dialogs:FileName');
    ToFileTxt.Enabled=convertToBool(get_param(blockHandle,'RecordToFile'));
    ToFileTxt.WordWrap=true;
    ToFileTxt.RowSpan=[2,2];
    ToFileTxt.ColSpan=[1,3];


    ToFileValue.Type='edit';
    ToFileValue.Tag='Filename';
    ToFileValue.Enabled=convertToBool(get_param(blockHandle,'RecordToFile'))&&~isRunning;
    ToFileValue.Value=utils.recordDialogUtils.getFileParts(blockHandle).name;
    ToFileValue.ToolTip=utils.recordDialogUtils.getFileParts(blockHandle).fileLocation;
    ToFileValue.RowSpan=[2,2];
    ToFileValue.ColSpan=[4,5];
    ToFileValue.MatlabMethod='utils.recordDialogUtils.setToFileName';
    ToFileValue.MatlabArgs={'%dialog',obj,'%tag','%value'};



    ToFileTypeTxt.Type='text';
    ToFileTypeTxt.Name=DAStudio.message('record_playback:dialogs:FileType');
    ToFileTypeTxt.Enabled=convertToBool(get_param(blockHandle,'RecordToFile'));
    ToFileTypeTxt.WordWrap=true;
    ToFileTypeTxt.RowSpan=[3,3];
    ToFileTypeTxt.ColSpan=[1,3];


    FileTypeComboBox.Type='combobox';
    FileTypeComboBox.Tag='FileTypeComboBox';
    FileTypeComboBox.Enabled=convertToBool(get_param(blockHandle,'RecordToFile'))&&~isRunning;
    FileTypeComboBox.Entries={...
    DAStudio.message('record_playback:dialogs:mldatxType'),...
    DAStudio.message('record_playback:dialogs:matType'),...
    DAStudio.message('record_playback:dialogs:xlsxType')
    };


    currExt=utils.recordDialogUtils.getFileParts(blockHandle).ext;
    switch currExt
    case '.mat'
        FileTypeComboBox.Value=DAStudio.message('record_playback:dialogs:matType');
    case '.mldatx'
        FileTypeComboBox.Value=DAStudio.message('record_playback:dialogs:mldatxType');
    case '.xlsx'
        FileTypeComboBox.Value=DAStudio.message('record_playback:dialogs:xlsxType');
    end

    FileTypeComboBox.MatlabMethod='utils.recordDialogUtils.setFileType';
    FileTypeComboBox.MatlabArgs={'%dialog',obj};
    FileTypeComboBox.RowSpan=[3,3];
    FileTypeComboBox.ColSpan=[4,5];



    ToFileLocationLabel.Type='text';
    ToFileLocationLabel.Name=DAStudio.message('record_playback:dialogs:FileLocation');
    ToFileLocationLabel.Enabled=convertToBool(get_param(blockHandle,'RecordToFile'));
    ToFileLocationLabel.WordWrap=true;
    ToFileLocationLabel.RowSpan=[4,4];
    ToFileLocationLabel.ColSpan=[1,3];

    ToFileLocationButton.Name=DAStudio.message('record_playback:dialogs:BrowseButton');
    ToFileLocationButton.Tag='ToFileLocationButton';
    ToFileLocationButton.Type='pushbutton';
    ToFileLocationButton.Enabled=convertToBool(get_param(blockHandle,'RecordToFile'))&&~isRunning;
    ToFileLocationButton.RowSpan=[4,4];
    ToFileLocationButton.ColSpan=[4,5];
    ToFileLocationButton.MatlabMethod='utils.recordDialogUtils.setFilePath';
    ToFileLocationButton.MatlabArgs={'%dialog',obj};

    recordToFileEnabled=strcmp(get_param(blockHandle,'RecordToFile'),'on');
    isExcelFileType=strcmp(utils.recordDialogUtils.getFileParts(blockHandle).ext,'.xlsx');
    recordSettingsEnabled=recordToFileEnabled&&isExcelFileType;
    recordSettings=get_param(blockHandle,'FileSettings');
    excelSettings=recordSettings.excelSettings;

    ToFileTimeLabel.Type='text';
    ToFileTimeLabel.Name=[DAStudio.message('record_playback:toolstrip:TimeHeader'),':'];
    ToFileTimeLabel.Enabled=recordSettingsEnabled;
    ToFileTimeLabel.WordWrap=true;
    ToFileTimeLabel.RowSpan=[1,1];
    ToFileTimeLabel.ColSpan=[1,3];

    TimeSelection.Tag='TimeSelectionCombobox';
    TimeSelection.Type='combobox';
    TimeSelection.Entries={...
    DAStudio.message('record_playback:toolstrip:SharedTimeColumns'),...
    DAStudio.message('record_playback:toolstrip:IndividualTimeColumns')
    };


    switch excelSettings.time
    case Streamout.ExcelTime.INDIVIDUALCOLUMNS
        TimeSelection.Value=DAStudio.message('record_playback:toolstrip:IndividualTimeColumns');
    case Streamout.ExcelTime.SHAREDCOLUMNS
        TimeSelection.Value=DAStudio.message('record_playback:toolstrip:SharedTimeColumns');
    end
    TimeSelection.Enabled=recordSettingsEnabled&&~isRunning;
    TimeSelection.RowSpan=[1,1];
    TimeSelection.ColSpan=[4,5];
    TimeSelection.MatlabMethod='utils.recordDialogUtils.setRecordTimeSelection';
    TimeSelection.MatlabArgs={'%dialog',obj};

    ToFileAttributesLabel.Type='text';
    ToFileAttributesLabel.Name=[DAStudio.message('record_playback:toolstrip:AttributesHeader'),':'];
    ToFileAttributesLabel.Enabled=recordSettingsEnabled;
    ToFileAttributesLabel.WordWrap=true;
    ToFileAttributesLabel.RowSpan=[2,2];
    ToFileAttributesLabel.ColSpan=[1,3];

    chkDataType.Tag='CheckDataType';
    chkDataType.Type='checkbox';
    chkDataType.Name=DAStudio.message('record_playback:toolstrip:DataTypeCheck');
    chkDataType.Value=excelSettings.dataType;
    chkDataType.Enabled=recordSettingsEnabled&&~isRunning;
    chkDataType.RowSpan=[2,2];
    chkDataType.ColSpan=[4,5];
    chkDataType.MatlabMethod='utils.recordDialogUtils.setDataTypeAttribute';
    chkDataType.MatlabArgs={'%dialog',obj};

    chkUnits.Tag='CheckUnits';
    chkUnits.Type='checkbox';
    chkUnits.Name=DAStudio.message('record_playback:toolstrip:UnitsCheck');
    chkUnits.Value=excelSettings.units;
    chkUnits.Enabled=recordSettingsEnabled&&~isRunning;
    chkUnits.RowSpan=[3,3];
    chkUnits.ColSpan=[4,5];
    chkUnits.MatlabMethod='utils.recordDialogUtils.setUnitsAttribute';
    chkUnits.MatlabArgs={'%dialog',obj};

    chkPortIdx.Tag='CheckPortIdx';
    chkPortIdx.Type='checkbox';
    chkPortIdx.Name=DAStudio.message('record_playback:toolstrip:PortIndexCheck');
    chkPortIdx.Value=excelSettings.portIndex;
    chkPortIdx.Enabled=recordSettingsEnabled&&~isRunning;
    chkPortIdx.RowSpan=[4,4];
    chkPortIdx.ColSpan=[4,5];
    chkPortIdx.MatlabMethod='utils.recordDialogUtils.setPortIdxAttribute';
    chkPortIdx.MatlabArgs={'%dialog',obj};

    chkBlockPath.Tag='CheckBlockPath';
    chkBlockPath.Type='checkbox';
    chkBlockPath.Name=DAStudio.message('record_playback:toolstrip:BlockPathCheck');
    chkBlockPath.Value=excelSettings.blockPath;
    chkBlockPath.Enabled=recordSettingsEnabled&&~isRunning;
    chkBlockPath.RowSpan=[5,5];
    chkBlockPath.ColSpan=[4,5];
    chkBlockPath.MatlabMethod='utils.recordDialogUtils.setBlockPathAttribute';
    chkBlockPath.MatlabArgs={'%dialog',obj};

    chkInterpolation.Tag='CheckInterpolation';
    chkInterpolation.Type='checkbox';
    chkInterpolation.Name=DAStudio.message('record_playback:toolstrip:InterpolationCheck');
    chkInterpolation.Value=excelSettings.interpolation;
    chkInterpolation.Enabled=recordSettingsEnabled&&~isRunning;
    chkInterpolation.RowSpan=[6,6];
    chkInterpolation.ColSpan=[4,5];
    chkInterpolation.MatlabMethod='utils.recordDialogUtils.setInterpolationAttribute';
    chkInterpolation.MatlabArgs={'%dialog',obj};

    RecordSettingsPanel.Tag='RecordSettings';
    RecordSettingsPanel.Type='togglepanel';
    RecordSettingsPanel.Expand=false;
    RecordSettingsPanel.Enabled=recordSettingsEnabled;
    RecordSettingsPanel.Name=DAStudio.message('record_playback:toolstrip:ToFileSettingsLabel');
    RecordSettingsPanel.Items={ToFileTimeLabel,TimeSelection,ToFileAttributesLabel,chkDataType,...
    chkUnits,chkPortIdx,chkBlockPath,chkInterpolation};
    RecordSettingsPanel.LayoutGrid=[2,5];
    RecordSettingsPanel.RowStretch=[0,1];
    RecordSettingsPanel.RowSpan=[5,5];
    RecordSettingsPanel.ColSpan=[1,5];


    grpRecordToFile.Tag='grpRecordToFile';
    grpRecordToFile.Type='group';
    grpRecordToFile.Name=DAStudio.message('record_playback:dialogs:RecordToFile');
    grpRecordToFile.LayoutGrid=[6,5];
    grpRecordToFile.Items={chkRecordToFile,ToFileTxt,ToFileValue,ToFileTypeTxt,FileTypeComboBox,ToFileLocationLabel,ToFileLocationButton,...
    RecordSettingsPanel};
    grpRecordToFile.RowSpan=[2,2];
    grpRecordToFile.ColSpan=[1,5];

    RecordingPanel.Tag='RecordingPanel';
    RecordingPanel.Type='togglepanel';
    RecordingPanel.Expand=true;
    RecordingPanel.Name=DAStudio.message('record_playback:dialogs:RecordPanel');
    RecordingPanel.Items={grpRecordWorkspace,grpRecordToFile};
    RecordingPanel.LayoutGrid=[2,5];
    RecordingPanel.RowStretch=[0,1];
    RecordingPanel.RowSpan=[2,2];
    RecordingPanel.ColSpan=[1,5];

    dlg.Items={MainPanel,...
    RecordingPanel};
    dlg.LayoutGrid=[3,5];
    dlg.RowStretch=[0,0,1];
    dlg.ColStretch=[1,0,0,0,0];
end


function ret=convertToBool(x)
    if(isa(x,'logical'))
        ret=x;
    else
        ret=strcmp(x,'on');
    end
end