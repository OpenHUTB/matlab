function dlgStruct=getDialogSchema(source,str)%#ok<INUSD>































    source.paramsMap=source.getDialogParams;

    blk=source.getBlock;
    parentName=strsplit(blk.parent,'/');
    modelNm=parentName{1};
    maskValues=get_param(blk.handle,'MaskValues');

    if(~strcmp(get_param(modelNm,'SimulationStatus'),'stopped'))
        enabled=false;
    else
        enabled=true;
    end


    if(strcmp(source.dlgID,''))
        source.dlgID='WaveformGenerator';
        source.signals=regexp(get_param(blk.handle,'Signals'),'#','split')';
        source.selection=get_param(blk.handle,'SelectedSignal');
    end

    source.rows=length(source.signals);


    data=cell(source.rows,1);
    selections=cell(source.rows,1);

    for i=1:(source.rows)
        signal=source.signals(i);
        data{i,1}=char(signal);
        selections{i,1}=num2str(i);
    end


    signalSelect.Name=getString(message('sl_sta_ds:staDerivedSignal:DSSignalSelect'));
    signalSelect.Type='combobox';
    signalSelect.RowSpan=[1,1];
    signalSelect.ColSpan=[1,1];
    signalSelect.Entries=selections;
    signalSelect.WidgetId='signalSelect';
    signalSelect.Value=maskValues{7,1};


    signalSelect.Tag='SelectedSignal';
    signalSelect.MatlabMethod='derivedSignals.DSMaskSelectedSignalChanged';
    signalSelect.MatlabArgs={'%dialog'};
    signalSelect.Editable=1;
    signalSelect.DialogRefresh=1;


    addButton.Name=getString(message('sl_sta_ds:staDerivedSignal:DSNewExpression'));
    addButton.Type='pushbutton';
    addButton.RowSpan=[2,2];
    addButton.ColSpan=[3,3];
    addButton.MatlabMethod='derivedSignals.DSMaskButtonHandler';
    addButton.MatlabArgs={'%dialog','add'};
    addButton.Tag='addButton';
    addButton.Enabled=enabled;



    removeButton.Name=getString(message('sl_sta_ds:staDerivedSignal:DSRemoveSelected'));
    removeButton.Type='pushbutton';
    removeButton.RowSpan=[2,2];
    removeButton.ColSpan=[4,4];
    removeButton.MatlabMethod='derivedSignals.DSMaskButtonHandler';
    removeButton.MatlabArgs={'%dialog','remove'};
    removeButton.Tag='removeButton';
    removeButton.Enabled=enabled;


    tbl.Type='table';
    tbl.Size=[source.rows,1];
    tbl.Grid=1;
    tbl.Editable=1;
    tbl.HeaderVisibility=[1,1];
    tbl.ColHeader={getString(message('sl_sta_ds:staDerivedSignal:TableHeaderWaveformDefinition'))};
    tbl.ColumnID={'WaveformDefinition'};
    tbl.LastColumnStretchable=true;
    tbl.RowSpan=[3,3];
    tbl.ColSpan=[1,4];
    tbl.WidgetId='expressionTable';
    tbl.Tag='expressionTable';
    tbl.ValueChangedCallback=@(hdlg,row,col,value)derivedSignals.DSMaskValueChangedCallback(hdlg,row,col,value);
    tbl.Tunable=0;
    tbl.Enabled=enabled;

    tbl.Data=data;

    mainTab.Name=getString(message('Simulink:dialog:Main'));
    mainTab.Items={signalSelect,addButton,removeButton,tbl};
    mainTab.LayoutGrid=[3,4];
    mainTab.ColStretch=[0,1,0,0];
    mainTab.Tag='mainTab';




    outMin.Name=getString(message('sl_sta_ds:staDerivedSignal:DSOutputMin'));
    outMin.Tag='OutMin';
    outMin.Type='edit';
    outMin.Value=maskValues{1,1};


    outMin.ColSpan=[1,1];
    outMin.RowSpan=[1,1];
    outMin.ToolTip=DAStudio.message('Simulink:dialog:VariableContextMenu_Tooltip');
    outMin.Enabled=enabled;




    outMax.Name=getString(message('sl_sta_ds:staDerivedSignal:DSOutputMax'));
    outMax.Tag='OutMax';
    outMax.Type='edit';
    outMax.Value=maskValues{2,1};


    outMax.ColSpan=[2,2];
    outMax.RowSpan=[1,1];
    outMax.ToolTip=DAStudio.message('Simulink:dialog:VariableContextMenu_Tooltip');
    outMax.Enabled=enabled;




    dsDataTypeItems.scalingModes=Simulink.DataTypePrmWidget.getScalingModeList('BPt_SB');
    dsDataTypeItems.signModes=Simulink.DataTypePrmWidget.getSignModeList('SignUnsign');
    dsDataTypeItems.inheritRules={'Inherit: Inherit via back propagation'};
    dsDataTypeItems.builtinTypes=Simulink.DataTypePrmWidget.getBuiltinList('NumBool');
    dsDataTypeItems.allowsExpression=false;
    dsDataTypeItems.supportsEnumType=false;
    dsDataTypeItems.supportsBusType=false;

    dsDataTypeGroup=Simulink.DataTypePrmWidget.getDataTypeWidget(source,...
    'OutDataTypeStr',...
    getString(message('sl_sta_ds:staDerivedSignal:DSOutputDataType')),...
    'OutDataTypeStr',...
    maskValues{3,1},...
    dsDataTypeItems,...
    false);

    dsDataTypeGroup.RowSpan=[2,2];
    dsDataTypeGroup.ColSpan=[1,2];

    lockOutScale.Name=getString(message('sl_sta_ds:staDerivedSignal:DSOutputLock'));
    lockOutScale.Tag='LockScale';
    lockOutScale.Type='checkbox';
    lockOutScale.Value=strcmp(maskValues{4,1},'on');


    lockOutScale.DialogRefresh=1;
    lockOutScale.RowSpan=[3,3];
    lockOutScale.ColSpan=[1,2];




    round.Name=getString(message('sl_sta_ds:staDerivedSignal:DSIntRoundingMode'));
    round.Tag='RndMeth';
    round.Type='combobox';
    round.Value=maskValues{5,1};


    round.Entries={'Ceiling','Convergent','Floor','Nearest','Round','Simplest','Zero'};
    round.RowSpan=[4,4];
    round.ColSpan=[1,2];
    round.Editable=0;
    round.DialogRefresh=1;

    saturate.Name=getString(message('sl_sta_ds:staDerivedSignal:DSSaturateOnOverflow'));
    saturate.Tag='SaturateOnIntegerOverflow';
    saturate.Type='checkbox';
    saturate.Value=strcmp(maskValues{6,1},'on');


    saturate.RowSpan=[5,5];
    saturate.ColSpan=[1,2];

    sampleTime.Name=getString(message('sl_sta_ds:staDerivedSignal:SampleTime'));
    sampleTime.Tag='SampleTime';
    sampleTime.Type='edit';
    sampleTime.Value=maskValues{13,1};


    sampleTime.RowSpan=[6,6];
    sampleTime.ColSpan=[1,2];
    sampleTime.Enabled=enabled;

    spacer.Name='';
    spacer.Type='text';
    spacer.RowSpan=[7,7];
    spacer.ColSpan=[1,2];

    dataTab.Name=getString(message('Simulink:dialog:SignalAttributes'));
    dataTab.LayoutGrid=[7,2];
    dataTab.RowStretch=[0,0,0,0,0,0,1];
    dataTab.Enabled=enabled;
    dataTab.Items={outMin,outMax,dsDataTypeGroup,lockOutScale,round,saturate,sampleTime,spacer};
    dataTab.Tag='signalAtributesTab';


    blockDesc.Name=getString(message('sl_sta_ds:staDerivedSignal:DSGroupBlockDescription'));
    blockDesc.Type='text';
    blockDesc.WordWrap=true;
    blockDesc.WidgetId='description';
    blockDesc.Tag='description';


    descGroup.Name=getString(message('sl_sta_ds:staDerivedSignal:WaveformGenerator'));
    descGroup.Type='group';
    descGroup.RowSpan=[1,1];
    descGroup.ColSpan=[1,1];
    descGroup.Items={blockDesc};


    tabcont.Name='tabcont';
    tabcont.Type='tab';
    tabcont.RowSpan=[2,2];
    tabcont.ColSpan=[1,1];
    tabcont.Tabs={mainTab,dataTab};
    tabcont.Tag='tabCont';


    dlgStruct.DialogTitle=message('Simulink:dialog:BlockParameters',...
    getString(message('sl_sta_ds:staDerivedSignal:DSDerivedSignalsGroup'))).getString;
    dlgStruct.LayoutGrid=[2,1];
    dlgStruct.RowStretch=[0,1];
    dlgStruct.Items={descGroup,tabcont};

    dlgStruct.ExplicitShow=1;

    dlgStruct.PreApplyCallback='derivedSignals.DSMaskPreApplyCallback';
    dlgStruct.PreApplyArgs={'%dialog'};
    dlgStruct.PreRevertCallback='derivedSignals.DSMaskPreRevertCallback';
    dlgStruct.PreRevertArgs={'%dialog'};
    dlgStruct.StandaloneButtonSet={'OK','Apply','Cancel','Help'};
    dlgStruct.HelpMethod='helpview';
    dlgStruct.HelpArgs={fullfile(docroot,'simulink','helptargets.map'),'waveformgenerator'};
    dlgStruct.DialogTag=source.dlgID;

    dlgStruct.CloseCallback='derivedSignals.DSMaskCloseCallback';
    dlgStruct.CloseArgs={'%dialog'};


    isLocked=(strcmp(get_param(bdroot(blk.handle),'BlockDiagramType'),'library')...
    &&strcmp(get_param(bdroot(blk.handle),'Lock'),'on'));

    if isLocked
        dlgStruct.DisableDialog=1;
    else
        dlgStruct.DisableDialog=0;
    end
end

