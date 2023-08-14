function dlgStruct=dtf_ddg(source,h)









    mlock;
    persistent sigObjCache;

    if isempty(sigObjCache)
        sigObjCache=Simulink.SigpropDDGCache;
    end


    descTxt.Name=h.BlockDescription;
    descTxt.Type='text';
    descTxt.WordWrap=true;

    if strcmpi(h.BlockType,'DiscreteFilter')
        descGrp.Name=DAStudio.message('Simulink:blocks:IIRFilterBlockType');
    else
        descGrp.Name=DAStudio.message('Simulink:blocks:DTFBlockType');
    end
    descGrp.Type='group';
    descGrp.Items={descTxt};
    descGrp.RowSpan=[1,1];
    descGrp.ColSpan=[1,1];

    paramGrp.Name=DAStudio.message('Simulink:dialog:Parameters');
    paramGrp.Type='tab';
    state_tab=get_state_attributes_tab(source,h,sigObjCache);
    if strcmpi(h.BlockType,'DiscreteFilter')&&~strcmp(h.FilterStructure,'Direct form II')
        state_tab.Enabled=false;
        state_tab.Visible=false;
    end

    paramGrp.Tabs={get_main_tab(source,h),...
    get_data_type_tab(source,h),...
    state_tab};
    paramGrp.RowSpan=[2,2];
    paramGrp.ColSpan=[1,1];
    paramGrp.Source=h;




    dlgStruct.DialogTitle=getString(message('Simulink:dialog:BlockParameters',strrep(h.Name,newline,' ')));
    if strcmpi(h.BlockType,'DiscreteFilter')
        dlgStruct.DialogTag='DiscreteFilter';
    else
        dlgStruct.DialogTag='DiscreteTransferFcn';
    end
    dlgStruct.Items={descGrp,paramGrp};
    dlgStruct.LayoutGrid=[2,1];
    dlgStruct.RowStretch=[0,1];
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


function thisTab=get_main_tab(source,h)

    numFromDlg=strcmp(h.NumeratorSource,'Dialog');
    denFromDlg=strcmp(h.DenominatorSource,'Dialog');
    icFromDlg=strcmp(h.InitialStatesSource,'Dialog');

    filtStructRowIdx=2;
    titleRowIdx=3;
    numRowIdx=4;
    denRowIdx=5;
    icRowIdx=6;
    numICRowIdx=6;
    denICRowIdx=7;


    spacer1.Name='';
    spacer1.Type='text';
    spacer1.RowSpan=[1,1];
    spacer1.ColSpan=[1,1];
    if strcmpi(h.BlockType,'DiscreteFilter')
        FiltStruct=create_widget(source,h,'FilterStructure',filtStructRowIdx,2,2);
        FiltStruct.RowSpan=[filtStructRowIdx,filtStructRowIdx];
        FiltStruct.ColSpan=[1,2];
    end











    c1=1;
    c2=1;
    c3=1;


    dataCurCol=1;

    sP.Name='';
    sP.Type='text';
    sP.RowSpan=[titleRowIdx,titleRowIdx];
    sP.ColSpan=[dataCurCol,dataCurCol+c1-1];

    numPrompt.Name=DAStudio.message('SimulinkBlocks:simulink_extras:Numerator_MP');
    numPrompt.Type='text';
    numPrompt.RowSpan=[numRowIdx,numRowIdx];
    numPrompt.ColSpan=[dataCurCol,dataCurCol+c1-1];

    denPrompt.Name=DAStudio.message('SimulinkBlocks:simulink_extras:Denominator_MP');
    denPrompt.Type='text';
    denPrompt.RowSpan=[denRowIdx,denRowIdx];
    denPrompt.ColSpan=[dataCurCol,dataCurCol+c1-1];

    icPrompt.Name=DAStudio.message('Simulink:blkprm_prompts:InitialStates');
    icPrompt.Type='text';
    icPrompt.RowSpan=[icRowIdx,icRowIdx];
    icPrompt.ColSpan=[dataCurCol,dataCurCol+c1-1];

    numICPrompt.Name=DAStudio.message('Simulink:blkprm_prompts:InitialNumeratorStates');
    numICPrompt.Type='text';
    numICPrompt.RowSpan=[numICRowIdx,numICRowIdx];
    numICPrompt.ColSpan=[dataCurCol,dataCurCol+c1-1];

    denICPrompt.Name=DAStudio.message('Simulink:blkprm_prompts:InitialDenominatorStates');
    denICPrompt.Type='text';
    denICPrompt.RowSpan=[denICRowIdx,denICRowIdx];
    denICPrompt.ColSpan=[dataCurCol,dataCurCol+c1-1];


    dataCurCol=dataCurCol+c1;

    srcPrompt.Name=DAStudio.message('Simulink:dialog:Source');
    srcPrompt.Type='text';
    srcPrompt.RowSpan=[titleRowIdx,titleRowIdx];
    srcPrompt.ColSpan=[dataCurCol,dataCurCol+c2-1];


    numSource=create_widget(source,h,'NumeratorSource',numRowIdx,2,2);
    numSource.Name='';
    numSource.RowSpan=[numRowIdx,numRowIdx];
    numSource.ColSpan=[dataCurCol,dataCurCol+c2-1];
    numSource.DialogRefresh=true;


    denSource=create_widget(source,h,'DenominatorSource',numRowIdx,2,2);
    denSource.Name='';
    denSource.RowSpan=[denRowIdx,denRowIdx];
    denSource.ColSpan=[dataCurCol,dataCurCol+c2-1];
    denSource.DialogRefresh=true;


    icSource=create_widget(source,h,'InitialStatesSource',icRowIdx,2,2);
    icSource.Name='';
    icSource.RowSpan=[icRowIdx,icRowIdx];
    icSource.ColSpan=[dataCurCol,dataCurCol+c2-1];
    icSource.DialogRefresh=true;


    dataCurCol=dataCurCol+c2;

    valuePrompt.Name=DAStudio.message('Simulink:dialog:Value');
    valuePrompt.Type='text';
    valuePrompt.RowSpan=[titleRowIdx,titleRowIdx];
    valuePrompt.ColSpan=[dataCurCol,dataCurCol+c3-1];

    numValue=create_widget(source,h,'Numerator',numRowIdx,2,2);
    numValue.Name='';
    numValue.RowSpan=[numRowIdx,numRowIdx];
    numValue.ColSpan=[dataCurCol,dataCurCol+c3-1];
    if numFromDlg
        numValue.Enabled=true;
        numValue.Visible=true;
    else
        numValue.Enabled=false;
        numValue.Visible=false;
    end
    numValueBox.Name='';
    numValueBox.Type='edit';
    numValueBox.RowSpan=[numRowIdx,numRowIdx];
    numValueBox.ColSpan=[dataCurCol,dataCurCol+c3-1];
    numValueBox.Enabled=false;
    if numFromDlg
        numValueBox.Visible=false;
    else
        numValueBox.Visible=true;
    end


    denValue=create_widget(source,h,'Denominator',denRowIdx,2,2);
    denValue.Name='';
    denValue.RowSpan=[denRowIdx,denRowIdx];
    denValue.ColSpan=[dataCurCol,dataCurCol+c3-1];
    if denFromDlg
        denValue.Enabled=true;
        denValue.Visible=true;
    else
        denValue.Enabled=false;
        denValue.Visible=false;
    end
    denValueBox.Name='';
    denValueBox.Type='edit';
    denValueBox.RowSpan=[denRowIdx,denRowIdx];
    denValueBox.ColSpan=[dataCurCol,dataCurCol+c3-1];
    denValueBox.Enabled=false;
    if denFromDlg
        denValueBox.Visible=false;
    else
        denValueBox.Visible=true;
    end


    icValue=create_widget(source,h,'InitialStates',icRowIdx,2,2);
    icValue.Name='';
    icValue.RowSpan=[icRowIdx,icRowIdx];
    icValue.ColSpan=[dataCurCol,dataCurCol+c3-1];
    if icFromDlg
        icValue.Enabled=true;
        icValue.Visible=true;
    else
        icValue.Enabled=false;
        icValue.Visible=false;
    end
    icValueBox.Name='';
    icValueBox.Type='edit';
    icValueBox.RowSpan=[icRowIdx,icRowIdx];
    icValueBox.ColSpan=[dataCurCol,dataCurCol+c3-1];
    icValueBox.Enabled=false;
    if icFromDlg
        icValueBox.Visible=false;
    else
        icValueBox.Visible=true;
    end

    denICValue=create_widget(source,h,'InitialDenominatorStates',denICRowIdx,2,2);
    denICValue.Name='';
    denICValue.RowSpan=[denICRowIdx,denICRowIdx];
    denICValue.ColSpan=[dataCurCol,dataCurCol+c3-1];
    denICValue.Enabled=true;
    denICValue.Visible=true;

    denICValueBox.Name='';
    denICValueBox.Type='edit';
    denICValueBox.RowSpan=[denICRowIdx,denICRowIdx];
    denICValueBox.ColSpan=[dataCurCol,dataCurCol+c3-1];
    denICValueBox.Enabled=false;
    denICValueBox.Visible=false;
    dataCurCol=dataCurCol+c3;
    dataMaxCol=dataCurCol-1;



    algCurCol=dataMaxCol;
    rowIdx=icRowIdx+1;


    ResetPort=create_widget(source,h,'ExternalReset',rowIdx,2,2);
    ResetPort.RowSpan=[rowIdx,rowIdx];
    ResetPort.ColSpan=[1,algCurCol-1];
    rowIdx=rowIdx+1;

    InputProc=create_widget(source,h,'InputProcessing',rowIdx,2,2);
    InputProc.RowSpan=[rowIdx,rowIdx];
    InputProc.ColSpan=[1,algCurCol-1];
    rowIdx=rowIdx+1;

    a0EqualsOne=create_widget(source,h,'a0EqualsOne',rowIdx,2,2);
    a0EqualsOne.RowSpan=[rowIdx,rowIdx];
    a0EqualsOne.ColSpan=[1,algCurCol];
    rowIdx=rowIdx+1;
    algMaxCol=algCurCol;



    dataGroup.Name=DAStudio.message('Simulink:dialog:SigpropGrpDataName');
    dataGroup.Type='group';
    dataGroup.ColSpan=[1,dataMaxCol];
    dataGroup.ColStretch=[ones(1,c1),ones(1,c2),5*ones(1,c3)];

    if strcmp(h.FilterStructure,'Direct form II')||...
        strcmp(h.FilterStructure,'Direct form II transposed')
        dataGroup.RowSpan=[titleRowIdx,icRowIdx];
        dataGroup.LayoutGrid=[...
        dataGroup.RowSpan(2)-dataGroup.RowSpan(1)+1...
        ,dataGroup.ColSpan(2)-dataGroup.ColSpan(1)+1];
        dataGroup.Items={sP...
        ,numPrompt...
        ,denPrompt...
        ,icPrompt...
        ,srcPrompt...
        ,valuePrompt...
        ,numSource...
        ,denSource...
        ,icSource...
        ,numValue...
        ,numValueBox...
        ,denValue...
        ,denValueBox...
        ,icValue...
        ,icValueBox};
    else
        dataGroup.RowSpan=[titleRowIdx,denICRowIdx];
        dataGroup.LayoutGrid=[...
        dataGroup.RowSpan(2)-dataGroup.RowSpan(1)+1...
        ,dataGroup.ColSpan(2)-dataGroup.ColSpan(1)+1];
        dataGroup.Items={sP...
        ,numPrompt...
        ,denPrompt...
        ,numICPrompt...
        ,denICPrompt...
        ,srcPrompt...
        ,valuePrompt...
        ,numSource...
        ,denSource...
        ,numValue...
        ,numValueBox...
        ,denValue...
        ,denValueBox...
        ,icValue...
        ,icValueBox...
        ,denICValue...
        ,denICValueBox};
    end


    algGroup.Type='group';
    algGroup.RowSpan=[InputProc.RowSpan(1),a0EqualsOne.RowSpan(2)];
    algGroup.ColSpan=[1,algMaxCol];
    algGroup.LayoutGrid=[...
    algGroup.RowSpan(2)-algGroup.RowSpan(1)+1...
    ,algGroup.ColSpan(2)-algGroup.ColSpan(1)+1];
    algGroup.ColStretch=ones(1,algMaxCol);

    algGroup.Items={InputProc...
    ,ResetPort...
    ,a0EqualsOne};



    ts=Simulink.SampleTimeWidget.getCustomDdgWidget(...
    source,h,'SampleTime','',rowIdx,2,2,true);
    ts.RowSpan=[rowIdx,rowIdx];
    ts.ColSpan=[1,algCurCol-1];
    rowIdx=rowIdx+1;

    spacer.Name='';
    spacer.Type='text';
    spacer.RowSpan=[rowIdx,rowIdx];
    spacer.ColSpan=[1,dataMaxCol];
    if strcmpi(h.BlockType,'DiscreteFilter')
        thisTab.Items={spacer1,...
FiltStruct...
        ,dataGroup...
        ,algGroup...
        ,ts...
        ,spacer};
    else
        thisTab.Items={dataGroup...
        ,algGroup...
        ,ts...
        ,spacer};
    end

    thisTab.Name=DAStudio.message('Simulink:dialog:ModelTabOneName');
    thisTab.LayoutGrid=[rowIdx,dataMaxCol];
    thisTab.ColStretch=ones(1,dataMaxCol);
    thisTab.RowStretch=[zeros(1,(rowIdx-1)),1];

end


function dataTab=get_data_type_tab(source,h)



    layoutRow=0;



    dtaPrmColIdx=1;
    dtaUDTColIdx=2;
    dtaBtnColIdx=3;
    desMinColIdx=4;
    desMaxColIdx=5;
    layoutCols=desMaxColIdx;


    layoutRow=layoutRow+1;
    discStr=DAStudio.message('Simulink:dialog:FloatingPointTrumpRule');
    discText.Type='text';
    discText.Tag='discText';
    discText.Name=discStr;
    discText.Mode=false;
    discText.WordWrap=1;
    discText.RowSpan=[layoutRow,layoutRow];
    discText.ColSpan=[1,layoutCols];


    layoutRow=layoutRow+1;
    dtColText.Type='text';
    dtColText.Tag='dtColText';
    dtColText.Name=DAStudio.message('Simulink:dialog:DataTypeColumnLabel');
    dtColText.Mode=false;
    dtColText.RowSpan=[layoutRow,layoutRow];
    dtColText.ColSpan=[dtaUDTColIdx,dtaUDTColIdx];

    dtaColText.Type='text';
    dtaColText.Tag='dtaColText';
    dtaColText.Name=DAStudio.message('Simulink:dialog:AssistantColumnLabel');
    dtaColText.Mode=false;
    dtaColText.RowSpan=[layoutRow,layoutRow];
    dtaColText.ColSpan=[dtaBtnColIdx,dtaBtnColIdx];

    minColText.Type='text';
    minColText.Tag='minColText';
    minColText.Name=DAStudio.message('Simulink:dialog:MinimumColumnLabel');
    minColText.Mode=false;
    minColText.RowSpan=[layoutRow,layoutRow];
    minColText.ColSpan=[desMinColIdx,desMinColIdx];

    maxColText.Type='text';
    maxColText.Tag='maxColText';
    maxColText.Name=DAStudio.message('Simulink:dialog:MaximumColumnLabel');
    maxColText.Mode=false;
    maxColText.RowSpan=[layoutRow,layoutRow];
    maxColText.ColSpan=[desMaxColIdx,desMaxColIdx];



    commonItems.scalingModes=Simulink.DataTypePrmWidget.getScalingModeList('BPt');
    commonItems.signModes=Simulink.DataTypePrmWidget.getSignModeList('SignOnly');
    commonItems.builtinTypes=Simulink.DataTypePrmWidget.getBuiltinList('SignedInt');
    commonItems.scalingValueTags={};
    commonItems.scalingMinTag={};
    commonItems.scalingMaxTag={};
    commonItems.lockScalingTag='LockScale';


    dataTypeItems=commonItems;
    dataTypeItems.inheritRules=Simulink.DataTypePrmWidget.getInheritList('In');
    dataTypeParamName='StateDataTypeStr';
    stateUdtSpec.hDlgSource=source;
    stateUdtSpec.dtName=dataTypeParamName;
    stateUdtSpec.dtPrompt=DAStudio.message('Simulink:dialog:StatePrompt');
    stateUdtSpec.dtTag=dataTypeParamName;
    stateUdtSpec.dtVal=h.StateDataTypeStr;
    stateUdtSpec.dtaItems=dataTypeItems;
    stateUdtSpec.customAsstName=false;


    if strcmpi(h.BlockType,'DiscreteFilter')
        dataTypeItems=commonItems;
        dataTypeItems.inheritRules=Simulink.DataTypePrmWidget.getInheritList('In');
        dataTypeParamName='MultiplicandDataTypeStr';
        multUdtSpec.hDlgSource=source;
        multUdtSpec.dtName=dataTypeParamName;
        multUdtSpec.dtPrompt=DAStudio.message('Simulink:dialog:MultiplicandPrompt');
        multUdtSpec.dtTag=dataTypeParamName;
        multUdtSpec.dtVal=h.MultiplicandDataTypeStr;
        multUdtSpec.dtaItems=dataTypeItems;
        multUdtSpec.customAsstName=false;
    end


    dataTypeItems=commonItems;
    dataTypeItems.inheritRules=Simulink.DataTypePrmWidget.getInheritList('IR');
    dataTypeItems.scalingModes=Simulink.DataTypePrmWidget.getScalingModeList('BPt_Best');
    dataTypeItems.scalingValueTags={'Numerator'};
    dataTypeItems.scalingMinTag={'NumCoefMin'};
    dataTypeItems.scalingMaxTag={'NumCoefMax'};
    dataTypeParamName='NumCoefDataTypeStr';
    numCoefUdtSpec.hDlgSource=source;
    numCoefUdtSpec.dtName=dataTypeParamName;
    numCoefUdtSpec.dtPrompt=DAStudio.message('Simulink:dialog:NumCoefPrompt');
    numCoefUdtSpec.dtTag=dataTypeParamName;
    numCoefUdtSpec.dtVal=h.NumCoefDataTypeStr;
    numCoefUdtSpec.dtaItems=dataTypeItems;
    numCoefUdtSpec.customAsstName=false;


    dataTypeItems=commonItems;
    dataTypeItems.inheritRules=Simulink.DataTypePrmWidget.getInheritList('IR_In');
    dataTypeParamName='NumProductDataTypeStr';
    numProdUdtSpec.hDlgSource=source;
    numProdUdtSpec.dtName=dataTypeParamName;
    numProdUdtSpec.dtPrompt=DAStudio.message('Simulink:dialog:NumProdPrompt');
    numProdUdtSpec.dtTag=dataTypeParamName;
    numProdUdtSpec.dtVal=h.NumProductDataTypeStr;
    numProdUdtSpec.dtaItems=dataTypeItems;
    numProdUdtSpec.customAsstName=false;


    numAccumDataTypeItems=commonItems;
    numAccumDataTypeItems.inheritRules=Simulink.DataTypePrmWidget.getInheritList('IR_In_Prod');
    dataTypeParamName='NumAccumDataTypeStr';
    numAccumUdtSpec.hDlgSource=source;
    numAccumUdtSpec.dtName=dataTypeParamName;
    numAccumUdtSpec.dtPrompt=DAStudio.message('Simulink:dialog:NumAccumPrompt');
    numAccumUdtSpec.dtTag=dataTypeParamName;
    numAccumUdtSpec.dtVal=h.NumAccumDataTypeStr;
    numAccumUdtSpec.dtaItems=numAccumDataTypeItems;
    numAccumUdtSpec.customAsstName=false;


    dataTypeItems=commonItems;
    dataTypeItems.inheritRules=Simulink.DataTypePrmWidget.getInheritList('IR');
    dataTypeItems.scalingModes=Simulink.DataTypePrmWidget.getScalingModeList('BPt_Best');
    dataTypeItems.scalingValueTags={'Denominator'};
    dataTypeItems.scalingMinTag={'DenCoefMin'};
    dataTypeItems.scalingMaxTag={'DenCoefMax'};
    dataTypeParamName='DenCoefDataTypeStr';
    denCoefUdtSpec.hDlgSource=source;
    denCoefUdtSpec.dtName=dataTypeParamName;
    denCoefUdtSpec.dtPrompt=DAStudio.message('Simulink:dialog:DenCoefPrompt');
    denCoefUdtSpec.dtTag=dataTypeParamName;
    denCoefUdtSpec.dtVal=h.DenCoefDataTypeStr;
    denCoefUdtSpec.dtaItems=dataTypeItems;
    denCoefUdtSpec.customAsstName=false;


    dataTypeItems=commonItems;
    dataTypeItems.inheritRules=Simulink.DataTypePrmWidget.getInheritList('IR_In');
    dataTypeParamName='DenProductDataTypeStr';
    denProdUdtSpec.hDlgSource=source;
    denProdUdtSpec.dtName=dataTypeParamName;
    denProdUdtSpec.dtPrompt=DAStudio.message('Simulink:dialog:DenProdPrompt');
    denProdUdtSpec.dtTag=dataTypeParamName;
    denProdUdtSpec.dtVal=h.DenProductDataTypeStr;
    denProdUdtSpec.dtaItems=dataTypeItems;
    denProdUdtSpec.customAsstName=false;


    dataTypeItems=commonItems;
    dataTypeItems.inheritRules=Simulink.DataTypePrmWidget.getInheritList('IR_In_Prod');
    dataTypeParamName='DenAccumDataTypeStr';
    denAccumUdtSpec.hDlgSource=source;
    denAccumUdtSpec.dtName=dataTypeParamName;
    denAccumUdtSpec.dtPrompt=DAStudio.message('Simulink:dialog:DenAccumPrompt');
    denAccumUdtSpec.dtTag=dataTypeParamName;
    denAccumUdtSpec.dtVal=h.DenAccumDataTypeStr;
    denAccumUdtSpec.dtaItems=dataTypeItems;
    denAccumUdtSpec.customAsstName=false;


    dataTypeItems=commonItems;
    dataTypeItems.inheritRules=Simulink.DataTypePrmWidget.getInheritList('In_IR');
    dataTypeItems.scalingModes=Simulink.DataTypePrmWidget.getScalingModeList('BPt_Best');
    dataTypeItems.scalingMinTag={'OutMin'};
    dataTypeItems.scalingMaxTag={'OutMax'};
    dataTypeParamName='OutDataTypeStr';
    outUdtSpec.hDlgSource=source;
    outUdtSpec.dtName=dataTypeParamName;
    outUdtSpec.dtPrompt=DAStudio.message('Simulink:dialog:OutputPrompt');
    outUdtSpec.dtTag=dataTypeParamName;
    outUdtSpec.dtVal=h.OutDataTypeStr;
    outUdtSpec.dtaItems=dataTypeItems;
    outUdtSpec.customAsstName=false;


    if strcmpi(h.BlockType,'DiscreteFilter')
        udtSpecs={stateUdtSpec...
        ,numCoefUdtSpec,numProdUdtSpec,numAccumUdtSpec...
        ,denCoefUdtSpec,denProdUdtSpec,denAccumUdtSpec...
        ,multUdtSpec...
        ,outUdtSpec};
    else
        udtSpecs={stateUdtSpec...
        ,numCoefUdtSpec,numProdUdtSpec,numAccumUdtSpec...
        ,denCoefUdtSpec,denProdUdtSpec,denAccumUdtSpec...
        ,outUdtSpec};
    end
    [promptWidgets,comboxWidgets,shwBtnWidgets,hdeBtnWidgets,dtaGUIWidgets]=...
    Simulink.DataTypePrmWidget.getSPCDataTypeWidgets(source,udtSpecs,-1,[]);

    uDTypeRowIdx=layoutRow+1;
    dtaGUIRowIdx=uDTypeRowIdx+1;
    desMinWidgets=cell(1,length(udtSpecs));
    desMaxWidgets=cell(1,length(udtSpecs));

    for idx=1:length(udtSpecs)

        isEnabled=~source.isHierarchySimulating;

        promptWidgets{idx}.RowSpan=[uDTypeRowIdx,uDTypeRowIdx];
        promptWidgets{idx}.ColSpan=[dtaPrmColIdx,dtaPrmColIdx];
        comboxWidgets{idx}.RowSpan=[uDTypeRowIdx,uDTypeRowIdx];
        comboxWidgets{idx}.ColSpan=[dtaUDTColIdx,dtaUDTColIdx];
        comboxWidgets{idx}.Enabled=isEnabled;
        shwBtnWidgets{idx}.RowSpan=[uDTypeRowIdx,uDTypeRowIdx];
        shwBtnWidgets{idx}.ColSpan=[dtaBtnColIdx,dtaBtnColIdx];
        shwBtnWidgets{idx}.MaximumSize=get_size('BtnMax');
        shwBtnWidgets{idx}.Enabled=isEnabled;
        hdeBtnWidgets{idx}.RowSpan=[uDTypeRowIdx,uDTypeRowIdx];
        hdeBtnWidgets{idx}.ColSpan=[dtaBtnColIdx,dtaBtnColIdx];
        hdeBtnWidgets{idx}.MaximumSize=get_size('BtnMax');
        hdeBtnWidgets{idx}.Enabled=isEnabled;


        hasDesMinMax=~isempty(udtSpecs{idx}.dtaItems.scalingMinTag);

        if hasDesMinMax
            [~,desMinWidgets{idx}]=create_widget(source,h,...
            udtSpecs{idx}.dtaItems.scalingMinTag{1},uDTypeRowIdx,...
            desMinColIdx,desMinColIdx);
            desMinWidgets{idx}.RowSpan=[uDTypeRowIdx,uDTypeRowIdx];
            desMinWidgets{idx}.ColSpan=[desMinColIdx,desMinColIdx];
            desMinWidgets{idx}.MaximumSize=get_size('DesMMMax');

            [~,desMaxWidgets{idx}]=create_widget(source,h,...
            udtSpecs{idx}.dtaItems.scalingMaxTag{1},uDTypeRowIdx,...
            desMaxColIdx,desMaxColIdx);
            desMaxWidgets{idx}.RowSpan=[uDTypeRowIdx,uDTypeRowIdx];
            desMaxWidgets{idx}.ColSpan=[desMaxColIdx,desMaxColIdx];
            desMaxWidgets{idx}.MaximumSize=get_size('DesMMMax');
        end


        dtaGUIWidgets{idx}.RowSpan=[dtaGUIRowIdx,dtaGUIRowIdx];
        dtaGUIWidgets{idx}.ColSpan=[dtaUDTColIdx,layoutCols];
        dtaGUIWidgets{idx}.Enabled=isEnabled;

        uDTypeRowIdx=uDTypeRowIdx+2;
        dtaGUIRowIdx=uDTypeRowIdx+1;

    end

    [IC,NUM,DEN,MULT]=deal(1,2,5,8);
    numFromDlg=strcmp(h.NumeratorSource,'Dialog');
    denFromDlg=strcmp(h.DenominatorSource,'Dialog');

    if strcmp(h.FilterStructure,'Direct form I')
        showStateUdt=false;
    else
        if strcmp(h.FilterStructure,'Direct form II')||...
            strcmp(h.FilterStructure,'Direct form II transposed')
            showStateUdt=strcmp(h.InitialStatesSource,'Dialog');
        else

            showStateUdt=true;
        end
    end
    if showStateUdt
        promptWidgets{IC}.Visible=true;promptWidgets{IC}.Enabled=true;
        comboxWidgets{IC}.Visible=true;comboxWidgets{IC}.Enabled=isEnabled;
        shwBtnWidgets{IC}.Enabled=isEnabled;
        hdeBtnWidgets{IC}.Visible=~shwBtnWidgets{IC}.Visible;
        hdeBtnWidgets{IC}.Enabled=isEnabled;
    else
        promptWidgets{IC}.Visible=false;promptWidgets{IC}.Enabled=false;
        comboxWidgets{IC}.Visible=false;comboxWidgets{IC}.Enabled=false;
        shwBtnWidgets{IC}.Visible=false;shwBtnWidgets{IC}.Enabled=false;
        hdeBtnWidgets{IC}.Visible=false;hdeBtnWidgets{IC}.Enabled=false;
        dtaGUIWidgets{IC}.Visible=false;dtaGUIWidgets{IC}.Enabled=false;
    end
    if numFromDlg
        promptWidgets{NUM}.Visible=true;promptWidgets{NUM}.Enabled=true;
        comboxWidgets{NUM}.Visible=true;comboxWidgets{NUM}.Enabled=isEnabled;
        shwBtnWidgets{NUM}.Enabled=isEnabled;
        hdeBtnWidgets{NUM}.Visible=~shwBtnWidgets{NUM}.Visible;
        hdeBtnWidgets{NUM}.Enabled=isEnabled;
        desMinWidgets{NUM}.Visible=true;desMinWidgets{NUM}.Enabled=isEnabled;
        desMaxWidgets{NUM}.Visible=true;desMaxWidgets{NUM}.Enabled=isEnabled;
    else
        promptWidgets{NUM}.Visible=false;promptWidgets{NUM}.Enabled=false;
        comboxWidgets{NUM}.Visible=false;comboxWidgets{NUM}.Enabled=false;
        shwBtnWidgets{NUM}.Visible=false;shwBtnWidgets{NUM}.Enabled=false;
        hdeBtnWidgets{NUM}.Visible=false;hdeBtnWidgets{NUM}.Enabled=false;
        desMinWidgets{NUM}.Visible=false;desMinWidgets{NUM}.Enabled=false;
        desMaxWidgets{NUM}.Visible=false;desMaxWidgets{NUM}.Enabled=false;
        dtaGUIWidgets{NUM}.Visible=false;dtaGUIWidgets{NUM}.Enabled=false;
    end
    if denFromDlg
        promptWidgets{DEN}.Visible=true;promptWidgets{DEN}.Enabled=true;
        comboxWidgets{DEN}.Visible=true;comboxWidgets{DEN}.Enabled=isEnabled;
        shwBtnWidgets{DEN}.Enabled=isEnabled;
        hdeBtnWidgets{DEN}.Visible=~shwBtnWidgets{DEN}.Visible;
        hdeBtnWidgets{DEN}.Enabled=isEnabled;
        desMinWidgets{DEN}.Visible=true;desMinWidgets{DEN}.Enabled=isEnabled;
        desMaxWidgets{DEN}.Visible=true;desMaxWidgets{DEN}.Enabled=isEnabled;
    else
        promptWidgets{DEN}.Visible=false;promptWidgets{DEN}.Enabled=false;
        comboxWidgets{DEN}.Visible=false;comboxWidgets{DEN}.Enabled=false;
        shwBtnWidgets{DEN}.Visible=false;shwBtnWidgets{DEN}.Enabled=false;
        hdeBtnWidgets{DEN}.Visible=false;hdeBtnWidgets{DEN}.Enabled=false;
        desMinWidgets{DEN}.Visible=false;desMinWidgets{DEN}.Enabled=false;
        desMaxWidgets{DEN}.Visible=false;desMaxWidgets{DEN}.Enabled=false;
        dtaGUIWidgets{DEN}.Visible=false;dtaGUIWidgets{DEN}.Enabled=false;
    end
    if strcmpi(h.BlockType,'DiscreteFilter')
        if strcmp(h.FilterStructure,'Direct form I transposed')
            promptWidgets{MULT}.Visible=true;promptWidgets{MULT}.Enabled=true;
            comboxWidgets{MULT}.Visible=true;comboxWidgets{MULT}.Enabled=isEnabled;
            shwBtnWidgets{MULT}.Enabled=isEnabled;
            hdeBtnWidgets{MULT}.Visible=~shwBtnWidgets{MULT}.Visible;
            hdeBtnWidgets{MULT}.Enabled=isEnabled;
        else
            promptWidgets{MULT}.Visible=false;promptWidgets{MULT}.Enabled=false;
            comboxWidgets{MULT}.Visible=false;comboxWidgets{MULT}.Enabled=false;
            shwBtnWidgets{MULT}.Visible=false;shwBtnWidgets{MULT}.Enabled=false;
            hdeBtnWidgets{MULT}.Visible=false;hdeBtnWidgets{MULT}.Enabled=false;
            dtaGUIWidgets{MULT}.Visible=false;dtaGUIWidgets{MULT}.Enabled=false;
        end
    end

    layoutRow=dtaGUIRowIdx-2;
    layoutRow=layoutRow+1;
    lockOutScaleValue=create_widget(source,h,'LockScale',layoutRow,1,1);
    lockOutScaleValue.Visible=1;

    layoutRow=layoutRow+1;
    [roundPrompt,roundValue]=create_widget(source,h,'RndMeth',layoutRow,1,1);

    layoutRow=layoutRow+1;
    SaturateOnIntegerOverflowValue=create_widget(source,h,...
    'SaturateOnIntegerOverflow',layoutRow,1,1);

    dataTab.Name=DAStudio.message('Simulink:dialog:DataTypesTab');
    dataTab.Items={discText,dtColText,dtaColText,minColText,maxColText};
    for idx=1:length(udtSpecs)
        dataTab.Items=[dataTab.Items,promptWidgets{idx},comboxWidgets{idx}...
        ,shwBtnWidgets{idx},hdeBtnWidgets{idx},dtaGUIWidgets{idx}];
        hasDesMinMax=isfield(udtSpecs{idx}.dtaItems,'scalingMinTag');
        if hasDesMinMax
            dataTab.Items=[dataTab.Items,desMinWidgets{idx},desMaxWidgets{idx}];
        end
    end
    dataTab.Items=[dataTab.Items,lockOutScaleValue...
    ,roundPrompt,roundValue,SaturateOnIntegerOverflowValue];

    layoutRow=layoutRow+2;
    dataTab.LayoutGrid=[layoutRow,layoutCols];
    dataTab.RowStretch=[zeros(1,dataTab.LayoutGrid(1)-2),1,0];
    dataTab.ColStretch=ones(1,dataTab.LayoutGrid(2));

end


function thisTab=get_state_attributes_tab(source,h,sigObjCache)



    options.StateNamePrm='StateName';
    options.StorageClassPrm='RTWStateStorageClass';
    options.TypeQualifierPrm='RTWStateStorageTypeQualifier';
    options.NeedSpacer=true;
    options.IgnoreNameWidget=false;
    thisTab=populateCodeGenWidgets(source,h,sigObjCache,options);
    thisTab.Items=sldialogs('align_names',thisTab.Items);
    thisTab.Name=DAStudio.message('Simulink:dialog:StateAttributes');
end


function size=get_size(what)
    switch what
    case 'BtnMax'
        size=[(get_inch*5/12),2^24-1];
    case 'DesMMMax'
        size=[get_inch,2^24-1];
    otherwise
        size=[0,0];
    end
end


function dpi=get_inch
    dpi=get(0,'ScreenPixelsPerInch');
end



