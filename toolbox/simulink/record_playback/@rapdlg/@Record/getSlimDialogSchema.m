


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
    PortNumberTxt.Enabled=true;
    PortNumberTxt.RowSpan=[1,1];
    PortNumberTxt.ColSpan=[1,1];


    PortNumberValue.Type='edit';
    PortNumberValue.Tag='NumPorts';
    PortNumberValue.Value=get_param(blockHandle,'NumPorts');
    PortNumberValue.Enabled=true;
    PortNumberValue.RowSpan=[1,1];
    PortNumberValue.ColSpan=[2,2];
    PortNumberValue.MatlabMethod='utils.recordDialogUtils.setNumPorts';
    PortNumberValue.MatlabArgs={'%dialog','%tag','%value'};
    PortNumberValue.MinimumSize=[170,0];
    PortNumberValue.MaximumSize=[170,30];
    PortNumberValue.Alignment=6;

    fastObj=Simulink.internal.FastRestart;
    if fastObj.isInitialized(bdroot)
        PortNumberTxt.Enabled=false;
        PortNumberValue.Enabled=false;
    end

    grpPortNumber.Tag='grpPortNumber';
    grpPortNumber.Type='group';
    grpPortNumber.LayoutGrid=[1,2];
    grpPortNumber.Items={PortNumberTxt,PortNumberValue};


    PortSelectionTxt.Type='text';
    PortSelectionTxt.Name=DAStudio.message('record_playback:dialogs:PortNumber');
    PortSelectionTxt.Enabled=true;
    PortSelectionTxt.RowSpan=[1,1];
    PortSelectionTxt.ColSpan=[1,1];


    PortSelectionComboBox.Type='combobox';
    PortSelectionComboBox.Tag='SelectedPort';
    PortSelectionComboBox.Enabled=true;
    NumberofPort=get_param(blockHandle,'NumPorts');
    portEntries={};
    for port=1:NumberofPort
        portEntries{end+1}=num2str(port);
    end

    PortSelectionComboBox.Entries=portEntries;
    selectedPort=get_param(blockHandle,'SelectedPort');
    PortSelectionComboBox.Value=selectedPort;
    PortSelectionComboBox.MatlabMethod='utils.recordDialogUtils.setPortSelection';
    PortSelectionComboBox.MatlabArgs={'%dialog','%tag'};
    PortSelectionComboBox.RowSpan=[1,1];
    PortSelectionComboBox.ColSpan=[2,2];
    PortSelectionComboBox.MaximumSize=[170,30];
    PortSelectionComboBox.MinimumSize=[170,0];
    PortSelectionComboBox.Alignment=6;



    PortInputProcessTxt.Type='text';
    PortInputProcessTxt.Name=DAStudio.message('record_playback:dialogs:PortInputProcessLabel');
    PortInputProcessTxt.Enabled=true;
    PortInputProcessTxt.RowSpan=[2,2];
    PortInputProcessTxt.ColSpan=[1,1];


    PortInputProcessComboBox.Type='combobox';
    PortInputProcessComboBox.Tag='PortInputProcessComboBox';
    PortInputProcessComboBox.Enabled=true;
    PortInputProcessComboBox.Entries={...
    DAStudio.message('record_playback:dialogs:PortFrameBased'),...
    DAStudio.message('record_playback:dialogs:PortSampleBased')
    };


    currFrameSetting=get_param(blockHandle,'FrameSettings');
    if currFrameSetting(str2double(selectedPort))
        PortInputProcessComboBox.Value=DAStudio.message('record_playback:dialogs:PortFrameBased');
    else
        PortInputProcessComboBox.Value=DAStudio.message('record_playback:dialogs:PortSampleBased');
    end

    PortInputProcessComboBox.MatlabMethod='utils.recordDialogUtils.setPortInputProcess';
    PortInputProcessComboBox.MatlabArgs={'%dialog',obj};
    PortInputProcessComboBox.RowSpan=[2,2];
    PortInputProcessComboBox.ColSpan=[2,2];
    PortInputProcessComboBox.MaximumSize=[170,30];
    PortInputProcessComboBox.Alignment=6;

    grpPortSettings.Tag='grpPortSettings';
    grpPortSettings.Type='group';
    grpPortSettings.Name=DAStudio.message('record_playback:dialogs:PortSettingGroup');
    grpPortSettings.LayoutGrid=[2,2];
    grpPortSettings.Items={PortSelectionTxt,PortSelectionComboBox,PortInputProcessTxt,PortInputProcessComboBox};

    MainPanel.Tag='MainPanel';
    MainPanel.Type='togglepanel';
    MainPanel.Expand=true;
    MainPanel.Name=DAStudio.message('record_playback:dialogs:MainPanel');
    MainPanel.Items={grpPortNumber,grpPortSettings};
    MainPanel.LayoutGrid=[2,1];






    chkRecordToWorkspace.Tag='RecordToWorkspace';
    chkRecordToWorkspace.Type='checkbox';
    chkRecordToWorkspace.Name=DAStudio.message('record_playback:dialogs:RecordToWorkspace');
    chkRecordToWorkspace.Value=convertToBool(get_param(blockHandle,'RecordToWorkspace'));
    chkRecordToWorkspace.RowSpan=[1,1];
    chkRecordToWorkspace.ColSpan=[1,1];
    chkRecordToWorkspace.MatlabMethod='utils.recordDialogUtils.setRecordToWorkspace';
    chkRecordToWorkspace.MatlabArgs={'%dialog','%tag','%value'};
    chkRecordToWorkspace.Enabled=~isRunning;


    ToWorkspaceTxt.Type='text';
    ToWorkspaceTxt.Name=DAStudio.message('record_playback:dialogs:VariableName');
    ToWorkspaceTxt.Enabled=convertToBool(get_param(blockHandle,'RecordToWorkspace'));
    ToWorkspaceTxt.RowSpan=[2,2];
    ToWorkspaceTxt.ColSpan=[1,1];
    ToWorkspaceTxt.MinimumSize=[130,0];


    ToWorkspaceValue.Type='edit';
    ToWorkspaceValue.Tag='VariableName';
    ToWorkspaceValue.Enabled=convertToBool(get_param(blockHandle,'RecordToWorkspace'))&&~isRunning;
    ToWorkspaceValue.Value=get_param(blockHandle,'VariableName');
    ToWorkspaceValue.ToolTip=utils.recordDialogUtils.getFileParts(blockHandle).fileLocation;
    ToWorkspaceValue.RowSpan=[2,2];
    ToWorkspaceValue.ColSpan=[2,2];
    ToWorkspaceValue.MaximumSize=[170,30];
    ToWorkspaceValue.MinimumSize=[170,0];
    ToWorkspaceValue.Alignment=6;
    ToWorkspaceValue.MatlabMethod='utils.recordDialogUtils.setToWorkspaceVariable';
    ToWorkspaceValue.MatlabArgs={'%dialog','%tag','%value'};

    grpRecordWorkspace.Tag='grpRecordWorkspace';
    grpRecordWorkspace.Type='group';
    grpRecordWorkspace.Name=DAStudio.message('record_playback:dialogs:RecordToWorkspace');
    grpRecordWorkspace.LayoutGrid=[2,2];
    grpRecordWorkspace.Items={chkRecordToWorkspace,ToWorkspaceTxt,ToWorkspaceValue};
    grpRecordWorkspace.RowSpan=[1,1];
    grpRecordWorkspace.ColSpan=[1,1];





    chkRecordToFile.Tag='RecordToFile';
    chkRecordToFile.Type='checkbox';
    chkRecordToFile.Name=DAStudio.message('record_playback:dialogs:RecordToFile');
    chkRecordToFile.Value=convertToBool(get_param(blockHandle,'RecordToFile'));
    chkRecordToFile.RowSpan=[1,1];
    chkRecordToFile.ColSpan=[1,1];
    chkRecordToFile.MatlabMethod='utils.recordDialogUtils.setRecordToFile';
    chkRecordToFile.MatlabArgs={'%dialog','%tag','%value'};
    chkRecordToFile.Enabled=~isRunning;


    ToFileTxt.Type='text';
    ToFileTxt.Name=DAStudio.message('record_playback:dialogs:FileName');
    ToFileTxt.Enabled=convertToBool(get_param(blockHandle,'RecordToFile'));
    ToFileTxt.RowSpan=[2,2];
    ToFileTxt.ColSpan=[1,1];


    ToFileValue.Type='edit';
    ToFileValue.Tag='Filename';
    ToFileValue.Enabled=convertToBool(get_param(blockHandle,'RecordToFile'))&&~isRunning;
    ToFileValue.Value=utils.recordDialogUtils.getFileParts(blockHandle).name;
    ToFileValue.ToolTip=utils.recordDialogUtils.getFileParts(blockHandle).fileLocation;
    ToFileValue.RowSpan=[2,2];
    ToFileValue.ColSpan=[2,2];
    ToFileValue.MaximumSize=[170,30];
    ToFileValue.MinimumSize=[170,0];
    ToFileValue.Alignment=6;
    ToFileValue.MatlabMethod='utils.recordDialogUtils.setToFileName';
    ToFileValue.MatlabArgs={'%dialog',obj,'%tag','%value'};



    ToFileTypeTxt.Type='text';
    ToFileTypeTxt.Name=DAStudio.message('record_playback:dialogs:FileType');
    ToFileTypeTxt.Enabled=convertToBool(get_param(blockHandle,'RecordToFile'));
    ToFileTypeTxt.RowSpan=[3,3];
    ToFileTypeTxt.ColSpan=[1,1];


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
    FileTypeComboBox.ColSpan=[2,2];
    FileTypeComboBox.MaximumSize=[170,30];
    FileTypeComboBox.MinimumSize=[170,0];
    FileTypeComboBox.Alignment=6;


    ToFileLocationLabel.Type='text';
    ToFileLocationLabel.Name=DAStudio.message('record_playback:dialogs:FileLocation');
    ToFileLocationLabel.Enabled=convertToBool(get_param(blockHandle,'RecordToFile'));
    ToFileLocationLabel.RowSpan=[4,4];
    ToFileLocationLabel.ColSpan=[1,1];

    ToFileLocationButton.Type='pushbutton';
    ToFileLocationButton.Tag='ToFileLocationButton';
    ToFileLocationButton.Enabled=convertToBool(get_param(blockHandle,'RecordToFile'))&&~isRunning;
    ToFileLocationButton.Name=DAStudio.message('record_playback:dialogs:BrowseButton');
    ToFileLocationButton.ToolTip=utils.recordDialogUtils.getFileParts(blockHandle).fileLocation;
    ToFileLocationButton.RowSpan=[4,4];
    ToFileLocationButton.ColSpan=[2,2];
    ToFileLocationButton.MaximumSize=[170,30];
    ToFileLocationButton.MinimumSize=[170,0];
    ToFileLocationButton.Alignment=6;
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
    ToFileTimeLabel.RowSpan=[1,1];
    ToFileTimeLabel.ColSpan=[1,1];

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
    TimeSelection.ColSpan=[2,2];
    TimeSelection.MaximumSize=[170,30];
    TimeSelection.MinimumSize=[170,0];
    TimeSelection.Alignment=6;
    TimeSelection.Alignment=1;
    TimeSelection.MatlabMethod='utils.recordDialogUtils.setRecordTimeSelection';
    TimeSelection.MatlabArgs={'%dialog',obj};

    ToFileAttributesLabel.Type='text';
    ToFileAttributesLabel.Name=[DAStudio.message('record_playback:toolstrip:AttributesHeader'),':'];
    ToFileAttributesLabel.Enabled=recordSettingsEnabled;
    ToFileAttributesLabel.RowSpan=[2,2];
    ToFileAttributesLabel.ColSpan=[1,1];

    chkDataType.Tag='CheckDataType';
    chkDataType.Type='checkbox';
    chkDataType.Name=DAStudio.message('record_playback:toolstrip:DataTypeCheck');
    chkDataType.Value=excelSettings.dataType;
    chkDataType.Enabled=recordSettingsEnabled&&~isRunning;
    chkDataType.RowSpan=[2,2];
    chkDataType.ColSpan=[2,2];
    chkDataType.MatlabMethod='utils.recordDialogUtils.setDataTypeAttribute';
    chkDataType.MatlabArgs={'%dialog',obj};

    chkUnits.Tag='CheckUnits';
    chkUnits.Type='checkbox';
    chkUnits.Name=DAStudio.message('record_playback:toolstrip:UnitsCheck');
    chkUnits.Value=excelSettings.units;
    chkUnits.Enabled=recordSettingsEnabled&&~isRunning;
    chkUnits.RowSpan=[3,3];
    chkUnits.ColSpan=[2,2];
    chkUnits.MatlabMethod='utils.recordDialogUtils.setUnitsAttribute';
    chkUnits.MatlabArgs={'%dialog',obj};

    chkPortIdx.Tag='CheckPortIdx';
    chkPortIdx.Type='checkbox';
    chkPortIdx.Name=DAStudio.message('record_playback:toolstrip:PortIndexCheck');
    chkPortIdx.Value=excelSettings.portIndex;
    chkPortIdx.Enabled=recordSettingsEnabled&&~isRunning;
    chkPortIdx.RowSpan=[4,4];
    chkPortIdx.ColSpan=[2,2];
    chkPortIdx.MatlabMethod='utils.recordDialogUtils.setPortIdxAttribute';
    chkPortIdx.MatlabArgs={'%dialog',obj};

    chkBlockPath.Tag='CheckBlockPath';
    chkBlockPath.Type='checkbox';
    chkBlockPath.Name=DAStudio.message('record_playback:toolstrip:BlockPathCheck');
    chkBlockPath.Value=excelSettings.blockPath;
    chkBlockPath.Enabled=recordSettingsEnabled&&~isRunning;
    chkBlockPath.RowSpan=[5,5];
    chkBlockPath.ColSpan=[2,2];
    chkBlockPath.MatlabMethod='utils.recordDialogUtils.setBlockPathAttribute';
    chkBlockPath.MatlabArgs={'%dialog',obj};

    chkInterpolation.Tag='CheckInterpolation';
    chkInterpolation.Type='checkbox';
    chkInterpolation.Name=DAStudio.message('record_playback:toolstrip:InterpolationCheck');
    chkInterpolation.Value=excelSettings.interpolation;
    chkInterpolation.Enabled=recordSettingsEnabled&&~isRunning;
    chkInterpolation.RowSpan=[6,6];
    chkInterpolation.ColSpan=[2,2];
    chkInterpolation.MatlabMethod='utils.recordDialogUtils.setInterpolationAttribute';
    chkInterpolation.MatlabArgs={'%dialog',obj};

    RecordSettingsPanel.Tag='RecordSettings';
    RecordSettingsPanel.Type='togglepanel';
    RecordSettingsPanel.Expand=false;
    RecordSettingsPanel.Enabled=recordSettingsEnabled;
    RecordSettingsPanel.Name=DAStudio.message('record_playback:toolstrip:ToFileSettingsLabel');
    RecordSettingsPanel.Items={ToFileTimeLabel,TimeSelection,ToFileAttributesLabel,chkDataType,...
    chkUnits,chkPortIdx,chkBlockPath,chkInterpolation};
    RecordSettingsPanel.LayoutGrid=[2,2];
    RecordSettingsPanel.RowSpan=[5,5];
    RecordSettingsPanel.ColSpan=[1,2];


    grpRecordToFile.Tag='grpRecordToFile';
    grpRecordToFile.Type='group';
    grpRecordToFile.Name=DAStudio.message('record_playback:dialogs:RecordToFile');
    grpRecordToFile.LayoutGrid=[5,2];
    grpRecordToFile.Items={chkRecordToFile,ToFileTxt,ToFileValue,ToFileTypeTxt,FileTypeComboBox,ToFileLocationLabel,ToFileLocationButton,...
    RecordSettingsPanel};

    RecordingPanel.Tag='RecordingPanel';
    RecordingPanel.Type='togglepanel';
    RecordingPanel.Expand=true;
    RecordingPanel.Name=DAStudio.message('record_playback:dialogs:RecordPanel');
    RecordingPanel.Items={grpRecordWorkspace,grpRecordToFile};
    RecordingPanel.LayoutGrid=[2,1];
    RecordingPanel.RowSpan=[2,2];
    RecordingPanel.ColSpan=[1,1];

    dlg.Items={MainPanel,...
    RecordingPanel};
    dlg.LayoutGrid=[3,2];
    dlg.RowStretch=[0,0,1];
    dlg.ColStretch=[1,0];
end


function ret=convertToBool(x)
    if(isa(x,'logical'))
        ret=x;
    else
        ret=strcmp(x,'on');
    end
end