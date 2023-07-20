function dlgStruct=dataStoreMemddg(source,h)












    dsDataTypeItems.scalingModes=Simulink.DataTypePrmWidget.getScalingModeList('BPt_SB_Best');
    dsDataTypeItems.signModes=Simulink.DataTypePrmWidget.getSignModeList('SignUnsign');
    dsDataTypeItems.inheritRules=Simulink.DataTypePrmWidget.getInheritList('Auto');
    dsDataTypeItems.builtinTypes=Simulink.DataTypePrmWidget.getBuiltinList('NumHalfBool');

    dsDataTypeItems.supportsEnumType=true;
    dsDataTypeItems.supportsBusType=true;
    dsDataTypeItems.supportsImageDataType=true;
    dsDataTypeItems.supportsStringType=true;


    mlock;
    persistent sigObjCache;

    if isempty(sigObjCache)
        sigObjCache=Simulink.SigpropDDGCache;
    end

    [~,isLocked]=source.isLibraryBlock(h.Handle);
    if~isLocked
        if isempty(get_param(h.Handle,'CachedDataStoreName'))

            set_param(h.Handle,'CachedDataStoreName',get_param(h.Handle,'DataStoreName'));
            set_param(h.Handle,'CachedDSReadWriteBlocks',get_param(h.Handle,'DSReadWriteBlocks'));
        end
    end


    isDataStoreRef=slfeature('ScopedDSM')>0&&strcmp(get_param(h.Handle,'DataStoreReference'),'on');

    rowIdx=1;


    if slfeature('ScopedDSM')>0
        descTxt.Name=DAStudio.message('Simulink:dialog:SL_DSCPT_DSTORREF');
    else
        descTxt.Name=h.BlockDescription;
    end
    descTxt.Type='text';
    descTxt.WordWrap=true;

    descGrp.Name=h.BlockType;
    descGrp.Type='group';
    descGrp.Items={descTxt};
    descGrp.RowSpan=[rowIdx,rowIdx];
    descGrp.ColSpan=[1,1];


    rowIdx=rowIdx+1;
    dsName=create_widget(source,h,'DataStoreName',...
    rowIdx,0,2);

    dsName.Mode=1;
    dsName.DialogRefresh=true;
    dsName.ColSpan=[1,1];

    renameAll.Name=DAStudio.message('Simulink:studio:RenameAll');
    renameAll.Type='pushbutton';
    usesSignal=usesSignalObject(source);
    if usesSignal
        tooltipMsgID='Simulink:studio:DataStoreResolvesToSignal';
    else
        tooltipMsgID='Simulink:studio:UpdateAllBlocks';
    end
    renameAll.ToolTip=DAStudio.message(tooltipMsgID);
    renameAll.RowSpan=[rowIdx,rowIdx];
    renameAll.ColSpan=[2,2];
    renameAll.Tag='renameAll';
    renameAll.MatlabMethod='SLStudio.RenameDataStoreDialog.launch';
    renameAll.MatlabArgs={source};
    renameAll.Visible=(bitand(slfeature('RenameDataStoreMemory'),1)>0);
    renameAll.Enabled=(~source.isHierarchySimulating&&...
    ~usesSignal&&(~isequal(get_param(h.Handle,'CachedDataStoreName'),...
    get_param(h.Handle,'DataStoreName'))||...
    ~isempty(h.DSReadWriteBlocks)));

    rowIdx=rowIdx+1;

    if slfeature('ScopedDSM')>0
        dsRef=create_widget(source,h,'DataStoreReference',rowIdx,0,2);
        dsRef.Visible=true;
        dsRef.Enabled=true;
        dsRef.DialogRefresh=true;




        rowIdx=rowIdx+1;
    end

    dsRWBlks.Type='textbrowser';
    dsRWBlks.Text=dataStoreRWddg_cb(h.Handle,'getRWBlksHTML');
    dsRWBlks.RowSpan=[rowIdx,rowIdx];
    dsRWBlks.ColSpan=[1,2];
    dsRWBlks.Tag='dsRWBlks';
    dsRWBlks.Enabled=~source.isHierarchySimulating;

    mainTab.Name=DAStudio.message('Simulink:dialog:Main');
    mainTab.LayoutGrid=[rowIdx,2];
    if slfeature('ScopedDSM')>0
        mainTab.Items={dsName,renameAll,dsRef,dsRWBlks};
    else
        mainTab.Items={dsName,renameAll,dsRWBlks};
    end
    mainTab.RowStretch=[zeros(1,rowIdx-1),1];
    mainTab.ColStretch=[1,0];


    rowIdx=1;




    dsInitVal.Name=DAStudio.message('Simulink:blkprm_prompts:DstoreMemInitvalue');
    dsInitVal.Type='edit';
    dsInitVal.RowSpan=[rowIdx,rowIdx];
    dsInitVal.ColSpan=[1,3];
    dsInitVal.ObjectProperty='InitialValue';
    dsInitVal.Tag=dsInitVal.ObjectProperty;


    dsInitVal.Enabled=true;
    dsInitVal.Visible=true;
    dsInitVal.MatlabMethod='slDDGUtil';
    dsInitVal.MatlabArgs={source,'sync','%dialog','edit','%tag','%value'};
    rowIdx=rowIdx+1;

    dsOutMin.Name=DAStudio.message('Simulink:blkprm_prompts:DesignMin');
    dsOutMin.Type='edit';
    dsOutMin.RowSpan=[rowIdx,rowIdx];
    dsOutMin.ColSpan=[1,1];
    dsOutMin.ObjectProperty='OutMin';
    dsOutMin.Tag=dsOutMin.ObjectProperty;
    dsOutMin.Enabled=~source.isHierarchySimulating;
    dsOutMin.Visible=true;

    dsOutMin.MatlabMethod='slDDGUtil';
    dsOutMin.MatlabArgs={source,'sync','%dialog','edit','%tag','%value'};

    dsOutMax.Name=DAStudio.message('Simulink:blkprm_prompts:DesignMax');
    dsOutMax.Type='edit';
    dsOutMax.RowSpan=[rowIdx,rowIdx];
    dsOutMax.ColSpan=[2,2];
    dsOutMax.ObjectProperty='OutMax';
    dsOutMax.Tag=dsOutMax.ObjectProperty;
    dsOutMax.Enabled=~source.isHierarchySimulating;
    dsOutMax.Visible=true;

    dsOutMax.MatlabMethod='slDDGUtil';
    dsOutMax.MatlabArgs={source,'sync','%dialog','edit','%tag','%value'};

    rowIdx=rowIdx+1;


    lockOutScale=start_lockScaleProperty(source,h,'LockScale');


    dsDataTypeItems.scalingMinTag={dsOutMin.Tag};
    dsDataTypeItems.scalingMaxTag={dsOutMax.Tag};
    dsDataTypeItems.scalingValueTags={dsInitVal.Tag};


    dsDataTypeGroup=Simulink.DataTypePrmWidget.getDataTypeWidget(source,...
    'OutDataTypeStr',...
    DAStudio.message('Simulink:dialog:DataDataTypePrompt'),'OutDataTypeStr',...
    h.OutDataTypeStr,dsDataTypeItems,false);
    dsDataTypeGroup.RowSpan=[rowIdx,rowIdx];
    dsDataTypeGroup.ColSpan=[1,2];
    dsDataTypeGroup.Enabled=~source.isHierarchySimulating;

    rowIdx=rowIdx+1;

    lockOutScale.RowSpan=[rowIdx,rowIdx];
    lockOutScale.ColSpan=[1,2];

    rowIdx=rowIdx+1;
    if isDataStoreRef
        dsDims.Name=DAStudio.message('Simulink:blkprm_prompts:DstoreRefDimensions');
    else
        dsDims.Name=DAStudio.message('Simulink:blkprm_prompts:DstoreMemDimensions');
    end
    dsDims.Type='edit';
    dsDims.Value='-1';
    dsDims.RowSpan=[rowIdx,rowIdx];
    dsDims.ColSpan=[1,2];
    dsDims.ObjectProperty='Dimensions';
    dsDims.Tag=dsDims.ObjectProperty;
    dsDims.Enabled=~source.isHierarchySimulating;

    dsDims.MatlabMethod='slDDGUtil';
    dsDims.MatlabArgs={source,'sync','%dialog','combobox','%tag','%value'};

    rowIdx=rowIdx+1;
    ds1D.Name=DAStudio.message('Simulink:blkprm_prompts:AllSrcsVector1D');
    ds1D.Type='checkbox';
    ds1D.RowSpan=[rowIdx,rowIdx];
    ds1D.ColSpan=[1,3];
    ds1D.ObjectProperty='VectorParams1D';
    ds1D.Tag=ds1D.ObjectProperty;
    ds1D.Enabled=~source.isHierarchySimulating;

    ds1D.MatlabMethod='slDDGUtil';
    ds1D.MatlabArgs={source,'sync','%dialog','checkbox','%tag','%value'};

    rowIdx=rowIdx+1;
    dsSigType.Name=DAStudio.message('Simulink:blkprm_prompts:InportSignalType');
    dsSigType.Type='combobox';
    dsSigType.Entries=h.getPropAllowedValues('SignalType',true)';
    dsSigType.RowSpan=[rowIdx,rowIdx];
    dsSigType.ColSpan=[1,2];
    dsSigType.ObjectProperty='SignalType';
    dsSigType.Tag=dsSigType.ObjectProperty;
    dsSigType.Enabled=~source.isHierarchySimulating;

    dsSigType.MatlabMethod='slDDGUtil';
    dsSigType.MatlabArgs={source,'sync','%dialog','combobox','%tag','%value'};

    rowIdx=rowIdx+1;


    dsShared=create_widget(source,h,'ShareAcrossModelInstances',rowIdx,0,2);
    dsShared.Visible=~isDataStoreRef;
    dsShared.Enabled=~isDataStoreRef&&~source.isHierarchySimulating;
    dsShared.DialogRefresh=true;
    rowIdx=rowIdx+1;


    mustResolve=strcmp(h.StateMustResolveToSignalObject,'on');
    stateSC=h.StateStorageClass;
    if mustResolve&&~strcmp(stateSC,'Auto')
        h.StateStorageClass='Auto';
    end


    options.StateNamePrm='DataStoreName';
    options.StorageClassPrm='RTWStateStorageClass';
    options.TypeQualifierPrm='RTWStateStorageTypeQualifier';
    options.NeedSpacer=false;
    options.IgnoreNameWidget=true;
    dsCodegenGroup=populateCodeGenWidgets(source,h,sigObjCache,options);


    dsMustResolve=dsCodegenGroup.Items{1};
    dsMustResolve.RowSpan=[rowIdx,rowIdx];
    dsMustResolve.ColSpan=[1,2];
    assert(strcmp(dsMustResolve.Tag,'StateMustResolveToSignalObject'));
    dsCodegenGroup.Items{1}.Tag='Hidden_StateMustResolveToSignalObject';
    dsCodegenGroup.Items{1}.Visible=false;

    rowIdx=rowIdx+1;



    spacer.Name='';
    spacer.Type='text';
    spacer.RowSpan=[rowIdx,rowIdx];
    spacer.ColSpan=[1,2];

    dataTab.Name=DAStudio.message('Simulink:dialog:SignalAttributes');

    items={dsInitVal,dsOutMin,dsOutMax,dsDataTypeGroup,lockOutScale,dsDims,ds1D,dsSigType,...
    dsMustResolve,dsShared,spacer};

    dataTab.Items=items;
    dataTab.LayoutGrid=[rowIdx,2];
    dataTab.RowStretch=[zeros(1,(rowIdx-1)),1];


    rowIdx=1;

    rbwMsg.Name=DAStudio.message('Simulink:blkprm_prompts:DstoreMemReadBeforeWriteDiagnostic');
    rbwMsg.Type='combobox';
    rbwMsg.Entries=h.getPropAllowedValues('ReadBeforeWriteMsg',true)';
    rbwMsg.RowSpan=[rowIdx,rowIdx];
    rbwMsg.ColSpan=[1,1];
    rbwMsg.ObjectProperty='ReadBeforeWriteMsg';
    rbwMsg.Tag=rbwMsg.ObjectProperty;
    rbwMsg.Enabled=~source.isHierarchySimulating;

    rbwMsg.MatlabMethod='slDDGUtil';
    rbwMsg.MatlabArgs={source,'sync','%dialog','combobox','%tag','%value'};

    rowIdx=rowIdx+1;
    warMsg.Name=DAStudio.message('Simulink:blkprm_prompts:DstoreMemWriteAfterReadDiagnostic');
    warMsg.Type='combobox';
    warMsg.Entries=h.getPropAllowedValues('WriteAfterReadMsg',true)';
    warMsg.RowSpan=[rowIdx,rowIdx];
    warMsg.ColSpan=[1,1];
    warMsg.ObjectProperty='WriteAfterReadMsg';
    warMsg.Tag=warMsg.ObjectProperty;
    warMsg.Enabled=~source.isHierarchySimulating;

    warMsg.MatlabMethod='slDDGUtil';
    warMsg.MatlabArgs={source,'sync','%dialog','combobox','%tag','%value'};

    rowIdx=rowIdx+1;
    wawMsg.Name=DAStudio.message('Simulink:blkprm_prompts:DstoreMemWriteAfterWriteDiagnostic');
    wawMsg.Type='combobox';
    wawMsg.Entries=h.getPropAllowedValues('WriteAfterWriteMsg',true)';
    wawMsg.RowSpan=[rowIdx,rowIdx];
    wawMsg.ColSpan=[1,1];
    wawMsg.ObjectProperty='WriteAfterWriteMsg';
    wawMsg.Tag=wawMsg.ObjectProperty;
    wawMsg.Enabled=~source.isHierarchySimulating;

    wawMsg.MatlabMethod='slDDGUtil';
    wawMsg.MatlabArgs={source,'sync','%dialog','combobox','%tag','%value'};

    rowIdx=rowIdx+1;
    spacer2.Name='';
    spacer2.Type='text';
    spacer2.RowSpan=[rowIdx,rowIdx];
    spacer2.ColSpan=[1,1];

    diagnosticTab.Tag='DiagTab';
    diagnosticTab.Name=DAStudio.message('Simulink:blkprm_prompts:DstoreMemDiagnostics');
    diagnosticTab.Items={rbwMsg,warMsg,wawMsg,spacer2};
    diagnosticTab.LayoutGrid=[rowIdx,1];
    diagnosticTab.RowStretch=[0,0,0,1];
    diagnosticTab.Enabled=true;
    diagnosticTab.Visible=true;




    bIsLogging=strcmp(h.DataLogging,'on');




    chkLogSigData.Type='checkbox';
    chkLogSigData.Name=DAStudio.message('Simulink:dialog:SigpropChkLogDSDataName');
    chkLogSigData.ObjectProperty='DataLogging';
    chkLogSigData.Tag=chkLogSigData.ObjectProperty;
    chkLogSigData.ColSpan=[1,1];
    chkLogSigData.Enabled=~source.isHierarchySimulating;

    chkLogSigData.DialogRefresh=1;
    chkLogSigData.MatlabMethod='slDDGUtil';
    chkLogSigData.MatlabArgs={source,'sync','%dialog','checkbox','%tag','%value'};

    spacer1.Tag='spacer1';
    spacer1.Type='panel';
    spacer1.ColSpan=[2,2];

    pnl1.Tag='pnl1';
    pnl1.Type='panel';
    pnl1.LayoutGrid=[1,2];
    pnl1.Items={chkLogSigData,spacer1};
    pnl1.ColStretch=[0,1];
    pnl1.RowSpan=[1,1];




    cmbLog.Type='combobox';
    cmbLog.ObjectProperty='DataLoggingNameMode';
    cmbLog.Tag=cmbLog.ObjectProperty;
    cmbLog.Values=[0,1];
    cmbLog.Entries={DAStudio.message('Simulink:dialog:SigpropCmbLogEntryUseDSName'),...
    DAStudio.message('Simulink:dialog:SigpropCmbLogEntryCustom')};
    cmbLog.ColSpan=[1,1];
    cmbLog.Enabled=bIsLogging&&~source.isHierarchySimulating;

    cmbLog.DialogRefresh=1;
    cmbLog.MatlabMethod='slDDGUtil';
    cmbLog.MatlabArgs={source,'sync','%dialog','combobox','%tag','%value'};

    txtName.Type='edit';
    txtName.ObjectProperty='DataLoggingName';
    txtName.Tag=txtName.ObjectProperty;
    txtName.ColSpan=[2,2];
    txtName.Enabled=bIsLogging&&~source.isHierarchySimulating&&...
    ~(isequal(h.DataLoggingNameMode,'SignalName'));

    txtName.MatlabMethod='slDDGUtil';
    txtName.MatlabArgs={source,'sync','%dialog','edit','%tag','%value'};

    grpLog.Tag='grpLog';
    grpLog.Type='group';
    grpLog.Name=DAStudio.message('Simulink:dialog:SigpropGrpLogName');
    grpLog.LayoutGrid=[1,2];
    grpLog.Items={cmbLog,txtName};
    grpLog.RowSpan=[2,2];




    chkDataPoints.Type='checkbox';
    chkDataPoints.RowSpan=[1,1];
    chkDataPoints.ColSpan=[1,1];
    chkDataPoints.ObjectProperty='DataLoggingLimitDataPoints';
    chkDataPoints.Tag=chkDataPoints.ObjectProperty;
    chkDataPoints.Enabled=bIsLogging&&~source.isHierarchySimulating;

    chkDataPoints.DialogRefresh=1;
    chkDataPoints.MatlabMethod='slDDGUtil';
    chkDataPoints.MatlabArgs={source,'sync','%dialog','checkbox','%tag','%value'};

    bLimitPts=strcmp(h.DataLoggingLimitDataPoints,'on');

    lblDataPoints.Tag='lblDataPoints';
    lblDataPoints.Type='text';
    lblDataPoints.Name=[DAStudio.message('Simulink:dialog:SigpropLblDataPointsName'),' '];
    lblDataPoints.RowSpan=[1,1];
    lblDataPoints.ColSpan=[2,2];
    lblDataPoints.Enabled=bIsLogging&&~source.isHierarchySimulating;

    txtDataPoints.Type='edit';
    txtDataPoints.ObjectProperty='DataLoggingMaxPoints';
    txtDataPoints.Tag=txtDataPoints.ObjectProperty;
    txtDataPoints.RowSpan=[1,1];
    txtDataPoints.ColSpan=[3,3];
    txtDataPoints.Enabled=bIsLogging&&~source.isHierarchySimulating&&bLimitPts;

    txtDataPoints.MatlabMethod='slDDGUtil';
    txtDataPoints.MatlabArgs={source,'sync','%dialog','edit','%tag','%value'};

    chkDecimation.Type='checkbox';
    chkDecimation.RowSpan=[2,2];
    chkDecimation.ColSpan=[1,1];
    chkDecimation.ObjectProperty='DataLoggingDecimateData';
    chkDecimation.Tag=chkDecimation.ObjectProperty;
    chkDecimation.Enabled=bIsLogging&&~source.isHierarchySimulating;

    chkDecimation.DialogRefresh=1;
    chkDecimation.MatlabMethod='slDDGUtil';
    chkDecimation.MatlabArgs={source,'sync','%dialog','checkbox','%tag','%value'};

    bDecData=strcmp(h.DataLoggingDecimateData,'on');

    lblDecimation.Tag='lblDecimation';
    lblDecimation.Type='text';
    lblDecimation.Name=[DAStudio.message('Simulink:dialog:SigpropLblDecimationName'),' '];
    lblDecimation.RowSpan=[2,2];
    lblDecimation.ColSpan=[2,2];
    lblDecimation.Enabled=bIsLogging&&~source.isHierarchySimulating;

    txtDecimation.Type='edit';
    txtDecimation.ObjectProperty='DataLoggingDecimation';
    txtDecimation.Tag=txtDecimation.ObjectProperty;
    txtDecimation.RowSpan=[2,2];
    txtDecimation.ColSpan=[3,3];
    txtDecimation.Enabled=bIsLogging&&~source.isHierarchySimulating&&bDecData;

    txtDecimation.MatlabMethod='slDDGUtil';
    txtDecimation.MatlabArgs={source,'sync','%dialog','edit','%tag','%value'};

    grpData.Tag='grpData';
    grpData.Type='group';
    grpData.Name=DAStudio.message('Simulink:dialog:SigpropGrpDataName');
    grpData.LayoutGrid=[2,3];
    grpData.Items={chkDataPoints,lblDataPoints,txtDataPoints,...
    chkDecimation,lblDecimation,txtDecimation};
    grpData.RowSpan=[3,3];

    groupspacer.Type='panel';
    groupspacer.RowSpan=[4,4];

    logTab.Tag='tab1';
    logTab.Name=DAStudio.message('Simulink:dialog:SigpropGrpLogging');
    logTab.Items={pnl1,grpLog,grpData,groupspacer};
    logTab.LayoutGrid=[4,1];
    logTab.RowStretch=[0,0,0,1];
    logTab.Enabled=true;
    logTab.Visible=true;




    paramGrp.Name='Parameters';
    paramGrp.Type='tab';
    paramGrp.Tabs={mainTab,dataTab,diagnosticTab,logTab};
    paramGrp.RowSpan=[2,2];
    paramGrp.ColSpan=[1,1];
    paramGrp.Source=h;





    dlgStruct.DialogTitle=DAStudio.message('Simulink:blkprm_prompts:BlockParameterDlg',...
    strrep(h.Name,newline,' '));
    dlgStruct.DialogTag='DataStoreMemory';
    dlgStruct.Items={descGrp,paramGrp};
    dlgStruct.LayoutGrid=[2,1];
    dlgStruct.RowStretch=[0,1];
    dlgStruct.CloseCallback='dataStoreRWddg_cb';
    dlgStruct.CloseArgs={h.Handle,'unhilite'};
    dlgStruct.HelpMethod='slhelp';
    dlgStruct.HelpArgs={h.Handle,'parameter'};

    dlgStruct.PreApplyCallback='cg_widgets_ddg_cb';
    dlgStruct.PreApplyArgs={h.Handle,'preapply_cb',sigObjCache,'%dialog'};
    dlgStruct.PostApplyCallback='cg_widgets_ddg_cb';
    dlgStruct.PostApplyArgs={h.Handle,'postapply_cb'};
    dlgStruct.CloseCallback='cg_widgets_ddg_cb';
    dlgStruct.CloseArgs={h.Handle,'close_cb','%closeaction',sigObjCache,'%dialog'};


    dlgStruct.PostRevertCallback='cg_widgets_ddg_cb';
    dlgStruct.PostRevertArgs={h.Handle,'postrevert_cb',sigObjCache};


    dlgStruct.CloseMethod='closeCallback';
    dlgStruct.CloseMethodArgs={'%dialog'};
    dlgStruct.CloseMethodArgsDT={'handle'};

    [~,isLocked]=source.isLibraryBlock(h);
    if isLocked
        dlgStruct.DisableDialog=1;
    else
        dlgStruct.DisableDialog=0;
    end

end

function property=start_lockScaleProperty(source,~,propName)



    property.ObjectProperty=propName;
    property.Tag=property.ObjectProperty;


    property.Name=DAStudio.message('Simulink:blkprm_prompts:LockScale');

    property.Type='checkbox';
    property.Enabled=~source.isHierarchySimulating;
    property.MatlabMethod='handleCheckEvent';
    property.MatlabArgs={source,'%value',find(strcmp(source.paramsMap,propName))-1,'%dialog'};


end


function result=usesSignalObject(source)


    hMdl=bdroot(get_param(source,'Handle'));
    signalResolutionControl=get_param(hMdl,'SignalResolutionControl');

    if strcmp(signalResolutionControl,'None')
        result=false;
        return;
    end

    mustResolve=get_param(source,'StateMustResolveToSignalObject');
    if isequal(mustResolve,'on')
        result=true;
    elseif strncmp(signalResolutionControl,'TryResolve',10)

        dsName=get_param(source,'DataStoreName');
        blk=get_param(source,'Object');
        [value,isResolved]=slResolve(dsName,blk.getFullName);
        result=isResolved&&isa(value,'Simulink.Signal');
    else

        result=false;
    end

end






