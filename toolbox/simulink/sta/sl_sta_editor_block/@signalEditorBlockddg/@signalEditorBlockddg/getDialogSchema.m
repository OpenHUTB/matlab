function dlgStruct=getDialogSchema(source,str)%#ok<INUSD>




























    source.paramsMap=source.getDialogParams;

    blk=source.getBlock;
    parentName=strsplit(blk.parent,'/');
    modelNm=parentName{1};
    blockPath=getFullName(blk);
    isLocked=(strcmp(get_param(bdroot(blk.handle),'BlockDiagramType'),'library')...
    &&strcmp(get_param(bdroot(blk.handle),'Lock'),'on'));

    map=Simulink.signaleditorblock.ListenerMap.getInstance;
    UIDataModel=map.getListenerMap(num2str(getSimulinkBlockHandle(blockPath),32));
    if isempty(UIDataModel)
        BlockDataModel=get_param([blockPath,'/Model Info'],'UserData');
        UIDataModel=copy(BlockDataModel);
        UIDataModel.isUpdated=false;
        map.addListener(num2str(getSimulinkBlockHandle(blockPath),32),UIDataModel);
    end

    if any(strcmp(get_param(modelNm,'SimulationStatus'),{'stopped','compiled'}))
        isSimStoppedOrCompiled=true;
    else
        isSimStoppedOrCompiled=false;
    end

    isSimStoppedOrCompiled=isSimStoppedOrCompiled&&~isLocked;
    isFastRestart=strcmp(get_param(modelNm,'FastRestart'),'on')&&...
    strcmp(get_param(modelNm,'SimulationStatus'),'compiled');
    isDefaultState=Simulink.signaleditorblock.FileUtil.isDefaultState(blockPath);
    function enabledState=getEnabledStateOfWidget(isFastRestartTunable,isEnabledInDefaultState)



        if isFastRestart

            enabledState=isFastRestartTunable;
        elseif isDefaultState


            enabledState=isEnabledInDefaultState;
        else
            enabledState=true;
        end


        enabledState=enabledState&&isSimStoppedOrCompiled;
    end


    fileNameText.Name=getString(message('sl_sta_editor_block:mask:FileName'));
    fileNameText.Type='edit';
    fileNameText.RowSpan=[1,1];
    fileNameText.ColSpan=[1,9];
    fileNameText.Tag='FileName';
    fileNameText.ObjectProperty=fileNameText.Tag;
    fileNameText.MatlabMethod='slDialogUtil';
    fileNameText.MatlabArgs={source,'sync','%dialog','edit','%tag'};
    isFastRestartTunable=false;isEnabledInDefaultState=true;
    fileNameText.Enabled=getEnabledStateOfWidget(isFastRestartTunable,isEnabledInDefaultState);


    fileBrowseButton.Type='pushbutton';
    fileBrowseButton.FilePath=fullfile(matlabroot,'toolbox','simulink','sta',...
    'sl_sta_editor_block','images','Open_16.png');
    fileBrowseButton.RowSpan=[1,1];
    fileBrowseButton.ColSpan=[10,10];
    fileBrowseButton.MatlabMethod='Simulink.signaleditorblock.cb_browse';
    fileBrowseButton.MatlabArgs={'%dialog'};
    fileBrowseButton.Tag='BrowseFile';
    fileBrowseButton.ToolTip=getString(message('sl_sta_editor_block:mask:Browse_ToolTip'));
    isFastRestartTunable=false;isEnabledInDefaultState=true;
    fileBrowseButton.Enabled=getEnabledStateOfWidget(isFastRestartTunable,isEnabledInDefaultState);



    activeGrpCombo.Name=getString(message('sl_sta_editor_block:mask:ActiveScenario'));
    activeGrpCombo.Type='combobox';
    activeGrpCombo.RowSpan=[2,2];
    activeGrpCombo.ColSpan=[1,10];
    grp_entries=UIDataModel.getScenarioList;
    CurrentActiveScenario=get_param(blockPath,'ActiveScenario');
    if~ismember(CurrentActiveScenario,grp_entries)&&~isempty(grp_entries)
        CurrentActiveScenario=grp_entries{1};
    end
    activeGrpCombo.Entries=grp_entries;
    activeGrpCombo.Editable=true;
    activeGrpCombo.Tag='ActiveScenario';
    activeGrpCombo.Value=CurrentActiveScenario;
    activeGrpCombo.DialogRefresh=1;
    activeGrpCombo.MatlabMethod='Simulink.signaleditorblock.cb_clickScenario';
    activeGrpCombo.MatlabArgs={'%dialog'};

    isFastRestartTunable=true;isEnabledInDefaultState=false;
    activeGrpCombo.Enabled=getEnabledStateOfWidget(isFastRestartTunable,isEnabledInDefaultState);




    blockDesc.Name=getString(message('sl_sta_editor_block:mask:BlockDescription'));
    blockDesc.Type='text';
    blockDesc.WordWrap=true;
    blockDesc.WidgetId='description';
    blockDesc.Tag='description';


    descScenario.Name='Signal Editor';
    descScenario.Type='group';
    descScenario.RowSpan=[1,1];
    descScenario.ColSpan=[1,1];
    descScenario.Items={blockDesc};


    Scenariocont.Name=getString(message('sl_sta_editor_block:mask:Scenario'));
    Scenariocont.Type='group';
    Scenariocont.LayoutGrid=[4,10];
    Scenariocont.RowSpan=[2,2];
    Scenariocont.ColSpan=[1,1];
    Scenariocont.Items={fileNameText,fileBrowseButton,activeGrpCombo};
    Scenariocont.Tag='scenarioContainer';
    Scenariocont.Source=blk;



    launchEditorInfo.Name=getString(message('sl_sta_editor_block:mask:LaunchEditor_Info'));
    launchEditorInfo.Type='text';
    launchEditorInfo.WordWrap=true;
    launchEditorInfo.RowSpan=[1,1];
    launchEditorInfo.ColSpan=[1,9];
    launchEditorInfo.WidgetId='launchEditorInfo';
    launchEditorInfo.Tag='launchEditorInfo';
    isFastRestartTunable=true;isEnabledInDefaultState=true;
    launchEditorInfo.Enabled=getEnabledStateOfWidget(isFastRestartTunable,isEnabledInDefaultState);

    editGrpsButton.Type='pushbutton';
    editGrpsButton.FilePath=fullfile(matlabroot,'toolbox','simulink','sta',...
    'sl_sta_editor_block','images','SignalAuthoring_16.png');
    editGrpsButton.RowSpan=[1,1];
    editGrpsButton.ColSpan=[10,10];
    editGrpsButton.MatlabMethod='Simulink.signaleditorblock.cb_editScenarios';
    editGrpsButton.MatlabArgs={'%dialog'};
    editGrpsButton.Tag='EditScenarioButton';
    editGrpsButton.ToolTip=getString(message('sl_sta_editor_block:mask:LaunchEditor_ToolTip'));

    isFastRestartTunable=true;isEnabledInDefaultState=true;
    editGrpsButton.Enabled=getEnabledStateOfWidget(isFastRestartTunable,isEnabledInDefaultState);


    signalname.Name=strcat(getString(message('sl_sta_editor_block:mask:Signals')),':');
    signalname.Type='combobox';
    signalname.Editable=true;
    signalname.RowSpan=[1,1];
    signalname.ColSpan=[1,10];
    sig_entries=UIDataModel.getSignalsForScenario(CurrentActiveScenario);
    CurrentActiveSignal=get_param(blockPath,'ActiveSignal');
    if~ismember(CurrentActiveSignal,sig_entries)&&~isempty(sig_entries)
        CurrentActiveSignal=sig_entries{1};
    end
    signalname.Entries=sig_entries;
    signalname.Value=CurrentActiveSignal;
    signalname.Tag='ActiveSignal';

    signalname.DialogRefresh=1;
    signalname.MatlabMethod='Simulink.signaleditorblock.cb_selectSignal';
    signalname.MatlabArgs={'%dialog'};


    isFastRestartTunable=true;isEnabledInDefaultState=false;
    signalname.Enabled=getEnabledStateOfWidget(isFastRestartTunable,isEnabledInDefaultState);


    activeSignalProperties=UIDataModel.getSignalProperties(CurrentActiveSignal);

    isBus.Name=getString(message('sl_sta_editor_block:mask:OutputBus'));
    isBus.Type='checkbox';
    isBus.Tag='IsBus';
    isBus.ObjectProperty=isBus.Tag;
    isBus.Value=activeSignalProperties.IsBus;
    isBus.RowSpan=[1,1];
    isBus.ColSpan=[1,10];
    isBus.MatlabMethod='Simulink.signaleditorblock.cb_IsBus';
    isBus.MatlabArgs={'%dialog'};
    isFastRestartTunable=false;isEnabledInDefaultState=false;
    isBus.Enabled=getEnabledStateOfWidget(isFastRestartTunable,isEnabledInDefaultState);


    dsDataTypeItems.allowsExpression=false;
    dsDataTypeItems.supportsBusType=true;
    datatypewidget=Simulink.DataTypePrmWidget.getDataTypeWidget(source,...
    'OutputBusObjectStr',...
    getString(message('sl_sta_editor_block:mask:SelectBusObject')),...
    'OutputBusObjectStr',...
    activeSignalProperties.BusObject,...
    dsDataTypeItems,...
    false);
    datatypewidget.RowSpan=[2,2];
    datatypewidget.ColSpan=[1,10];
    datatypewidget.Visible=strcmp(activeSignalProperties.IsBus,'on');
    datatypewidget.Items{2}.MatlabMethod='Simulink.signaleditorblock.cb_DataTypeChanged';
    isFastRestartTunable=false;isEnabledInDefaultState=false;
    datatypewidget.Enabled=getEnabledStateOfWidget(isFastRestartTunable,isEnabledInDefaultState);

    datatypewidgetPanel.Type='panel';
    datatypewidgetPanel.RowSpan=[2,2];
    datatypewidgetPanel.ColSpan=[1,10];
    datatypewidgetPanel.LayoutGrid=[2,10];
    datatypewidgetPanel.Items={isBus,datatypewidget};
    isFastRestartTunable=false;isEnabledInDefaultState=false;
    datatypewidgetPanel.Enabled=getEnabledStateOfWidget(isFastRestartTunable,isEnabledInDefaultState);


    unitPrompt=DAStudio.message('Simulink:blkprm_prompts:OutputUnit_EditField');
    unitTag='Unit';
    unitWidget=Simulink.UnitPrmWidget.getUnitWidget(source,unitPrompt,unitTag,'inherit',0);
    unitWidget.RowSpan=[3,3];
    unitWidget.ColSpan=[1,10];
    if strcmp(get_param(bdroot(blockPath),'BlockDiagramType'),'library')
        editBoxIndex=2;
    else
        editBoxIndex=3;
    end
    unitWidget.Items{editBoxIndex}=rmfield(unitWidget.Items{editBoxIndex},'ObjectMethod');
    unitWidget.Items{editBoxIndex}=rmfield(unitWidget.Items{editBoxIndex},'MethodArgs');
    unitWidget.Items{editBoxIndex}=rmfield(unitWidget.Items{editBoxIndex},'ArgDataTypes');
    unitWidget.Items{editBoxIndex}.ObjectProperty=unitTag;
    unitWidget.Items{editBoxIndex}.Value=activeSignalProperties.Unit;
    unitWidget.Items{editBoxIndex}.MatlabMethod='Simulink.signaleditorblock.cb_signalPropertiesChanged';
    unitWidget.Items{editBoxIndex}.MatlabArgs={'%dialog'};
    isFastRestartTunable=false;isEnabledInDefaultState=false;
    unitWidget.Enabled=getEnabledStateOfWidget(isFastRestartTunable,isEnabledInDefaultState);


    sampletime.Name=getString(message('Simulink:dialog:SignalSampleTimePrompt'));
    sampletime.Type='edit';
    sampletime.RowSpan=[4,4];
    sampletime.ColSpan=[1,10];
    sampletime.Tag='SampleTime';
    sampletime.ObjectProperty=sampletime.Tag;
    sampletime.Value=activeSignalProperties.SampleTime;
    sampletime.MatlabMethod='Simulink.signaleditorblock.cb_signalPropertiesChanged';
    sampletime.MatlabArgs={'%dialog'};
    isFastRestartTunable=false;isEnabledInDefaultState=false;
    sampletime.Enabled=getEnabledStateOfWidget(isFastRestartTunable,isEnabledInDefaultState);


    interpolate.Name=getString(message('Simulink:blkprm_prompts:InpFrmWksInterpolate'));
    interpolate.Type='checkbox';
    interpolate.RowSpan=[5,5];
    interpolate.ColSpan=[1,10];
    interpolate.Tag='Interpolate';
    interpolate.ObjectProperty=interpolate.Tag;
    interpolate.Value=activeSignalProperties.Interpolate;
    interpolate.MatlabMethod='Simulink.signaleditorblock.cb_signalPropertiesChanged';
    interpolate.MatlabArgs={'%dialog'};
    isFastRestartTunable=false;isEnabledInDefaultState=false;
    interpolate.Enabled=getEnabledStateOfWidget(isFastRestartTunable,isEnabledInDefaultState);


    zerocrossing.Name=getString(message('Simulink:blkprm_prompts:AllBlksEnableZC'));
    zerocrossing.Type='checkbox';
    zerocrossing.RowSpan=[6,6];
    zerocrossing.ColSpan=[1,10];
    zerocrossing.Tag='ZeroCross';
    zerocrossing.ObjectProperty=zerocrossing.Tag;
    zerocrossing.Value=activeSignalProperties.ZeroCross;
    zerocrossing.MatlabMethod='Simulink.signaleditorblock.cb_signalPropertiesChanged';
    zerocrossing.MatlabArgs={'%dialog'};
    isFastRestartTunable=false;isEnabledInDefaultState=false;
    zerocrossing.Enabled=getEnabledStateOfWidget(isFastRestartTunable,isEnabledInDefaultState);


    extrapolation.Name=getString(message('Simulink:blkprm_prompts:FromWksOutAfterFinalVal'));
    extrapolation.Type='combobox';
    extrapolation.RowSpan=[7,7];
    extrapolation.ColSpan=[1,10];
    entries={...
    getString(message('Simulink:dialog:Extrapolation_CB')),...
    getString(message('Simulink:dialog:Setting_to_zero_CB')),...
    getString(message('Simulink:dialog:Holding_final_value_CB'))
    };
    extrapolation.Entries=entries;
    extrapolation.Editable=false;
    extrapolation.Tag='OutputAfterFinalValue';
    extrapolation.ObjectProperty=extrapolation.Tag;
    extrapolation.Value=activeSignalProperties.OutputAfterFinalValue;
    extrapolation.MatlabMethod='Simulink.signaleditorblock.cb_signalPropertiesChanged';
    extrapolation.MatlabArgs={'%dialog'};
    isFastRestartTunable=false;isEnabledInDefaultState=false;
    extrapolation.Enabled=getEnabledStateOfWidget(isFastRestartTunable,isEnabledInDefaultState);


    signalproperties.Name=getString(message('sl_sta_editor_block:mask:Parameters'));
    signalproperties.Type='group';
    signalproperties.LayoutGrid=[7,10];
    signalproperties.RowSpan=[2,2];
    signalproperties.ColSpan=[1,10];
    signalproperties.Items={signalname,datatypewidgetPanel,unitWidget,sampletime,interpolate,zerocrossing,extrapolation};
    signalproperties.Tag='SignalPropertiesGroup';
    signalproperties.Source=blk;


    signalcont.Name=getString(message('sl_sta_editor_block:mask:SignalProperties'));
    signalcont.Type='group';
    signalcont.LayoutGrid=[2,10];
    signalcont.RowSpan=[3,3];
    signalcont.ColSpan=[1,1];
    signalcont.Items={launchEditorInfo,editGrpsButton,signalproperties};
    signalcont.Tag='SignalProperties';

    spacer.Name='';
    spacer.Type='panel';
    spacer.RowSpan=[4,4];
    spacer.ColSpan=[1,1];


    dlgStruct.DialogTitle=message('Simulink:dialog:BlockParameters',...
    getString(message('sl_sta_editor_block:mask:SignalEditor'))).getString;
    dlgStruct.LayoutGrid=[4,1];
    dlgStruct.RowStretch=[0,0,0,1];
    dlgStruct.Items={descScenario,Scenariocont,signalcont,spacer};
    dlgStruct.ExplicitShow=1;
    dlgStruct.PreApplyCallback='Simulink.signaleditorblock.cb_apply';
    dlgStruct.PreApplyArgs={'%dialog'};

    dlgStruct.StandaloneButtonSet={'OK','Apply','Cancel','Help'};
    dlgStruct.HelpMethod='helpview';
    dlgStruct.HelpArgs={fullfile(docroot,'simulink','helptargets.map'),'signal_editor_block'};
    dlgStruct.DialogTag='SignalEditorDialog';
    dlgStruct.CloseCallback='Simulink.signaleditorblock.cb_close';
    dlgStruct.CloseArgs={'%dialog'};


    if isLocked
        dlgStruct.DisableDialog=1;
    else
        dlgStruct.DisableDialog=0;
    end
end

