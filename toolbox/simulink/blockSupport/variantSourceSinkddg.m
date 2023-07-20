function dlgStruct=variantSourceSinkddg(source,h)





    disableWholeDialog=(source.isHierarchyReadonly||...
    source.isHierarchySimulating||...
    source.isHierarchyBuilding);

    if~disableWholeDialog

        if strcmp(h.LinkStatus,'resolved')&&strcmp(h.Mask,'on')
            [topMaskObj,bCanCreateNewMask]=Simulink.Mask.get(h.Handle);
            if~isempty(topMaskObj)&&(bCanCreateNewMask||~isempty(topMaskObj.BaseMask))

                disableWholeDialog=false;

            end
        end
    end





    if isa(h,'Simulink.VariantSink')
        descTxt.Name=DAStudio.message('Simulink:dialog:VariantSinkDescription');
        descGrp.Name='Variant Sink';
    elseif isa(h,'Simulink.VariantSource')
        descTxt.Name=DAStudio.message('Simulink:dialog:VariantSourceDescription');
        descGrp.Name='Variant Source';
    end
    descTxt.Type='text';
    descTxt.WordWrap=true;


    descGrp.Type='group';
    descGrp.Items={descTxt};
    descGrp.RowSpan=[1,1];
    descGrp.ColSpan=[1,1];





    opts=i_getDialogMessageStrings();


    [variantsPanelTable,variantsPanelBottomOveride,variantsPanelBottomExceptOveride]=i_GetVariantsPanel(source,h,opts);


    variantsPanelTable.Enabled=true;
    variantsPanelBottomOveride.Enabled=true;
    variantsPanelBottomExceptOveride.Enabled=true;

    paramGrp.Type='panel';
    paramGrp.LayoutGrid=[3,1];
    paramGrp.Items={variantsPanelTable,variantsPanelBottomOveride,variantsPanelBottomExceptOveride};
    paramGrp.RowSpan=[2,2];
    paramGrp.ColSpan=[1,1];
    paramGrp.Source=h;





    if isa(h,'Simulink.VariantSink')
        dlgStruct.DialogTag='VariantSink';
    else
        dlgStruct.DialogTag='VariantSource';
    end

    blockIsInLib=strcmpi(get_param(bdroot(h.Path),'BlockDiagramType'),'library');
    blockIsInSSRef=strcmpi(get_param(bdroot(h.Path),'BlockDiagramType'),'subsystem');
    addOpenInVariantManagerPanel=~blockIsInLib&&~blockIsInSSRef;
    if addOpenInVariantManagerPanel


        openInVariantManagerPanel=i_GetOpenInVariantManagerPanel(source,h);
        openInVariantManagerPanel.RowSpan=[3,3];
        openInVariantManagerPanel.ColSpan=[1,1];

        dlgStruct.Items={descGrp,paramGrp,openInVariantManagerPanel};
        dlgStruct.LayoutGrid=[3,1];
        dlgStruct.RowStretch=[0,1,0];
    else
        dlgStruct.Items={descGrp,paramGrp};
        dlgStruct.LayoutGrid=[2,1];
        dlgStruct.RowStretch=[0,1];
    end


    dlgStruct.HelpMethod='slhelp';
    dlgStruct.HelpArgs={h.Handle,'parameter'};


    dlgStruct.PreApplyCallback='variantSourceSinkddg_cb';
    dlgStruct.PreApplyArgs={'doPreApply','%dialog'};
    dlgStruct.CloseCallback='variantSourceSinkddg_cb';
    dlgStruct.CloseArgs={'doClose','%dialog'};


    dlgStruct.CloseMethod='closeCallback';
    dlgStruct.CloseMethodArgs={'%dialog'};
    dlgStruct.CloseMethodArgsDT={'handle'};


    dlgStruct.DisableDialog=disableWholeDialog;

end
function comboBoxWidget=i_CreateComboBox(index,columnData,vcMode,opts)



    EditableComboData={};
    EditableComboData{end+1}=columnData;
    defaultKeyword=Simulink.variant.keywords.getDefaultVariantKeyword();
    if~strcmp(columnData,defaultKeyword)&&vcMode.IsExpressionMode
        EditableComboData{end+1}=defaultKeyword;
    end

    if vcMode.IsSimCodegenMode
        if~strcmp(columnData,opts.SimKeywordStr)
            EditableComboData{end+1}=opts.SimKeywordStr;
        end
        if~strcmp(columnData,opts.CodegenKeywordStr)
            EditableComboData{end+1}=opts.CodegenKeywordStr;
        end
    end
    EditableComboName=sprintf('%s%d','combobox',index);
    EditableComboTagName=sprintf('%s%d','vs_table_combobox_',index);
    EditableComboWidgetId=sprintf('%s%d','vs_table_combobox_widget_',index);
    EditableCombo.Name=EditableComboName;
    EditableCombo.Type='combobox';
    EditableCombo.Tag=EditableComboTagName;
    EditableCombo.WidgetId=EditableComboWidgetId;
    EditableCombo.Editable=true;
    EditableCombo.Entries=EditableComboData;
    comboBoxWidget=EditableCombo;
end



function tdata=i_getTableDataWithComboBox(tabledata,vcMode,opts)

    tdata=tabledata;
    rows=size(tabledata,1);
    for i=1:rows
        rowData=tabledata{i,2};


        editableComboBox=i_CreateComboBox(i,rowData,vcMode,opts);

        tdata{i,2}=editableComboBox;
    end
end


function[allowZeroState,allowZeroValue]=i_getEnabledStateAndValueForAllowZeroCondition(h,dData,vcMode)
    tabledata=dData.TableData;


    if strcmp(dData.AZVC,'on')
        allowZeroValue=true;
        allowZeroState=true;
    else
        allowZeroValue=false;
        allowZeroState=true;
    end



    if vcMode.IsLabelMode||vcMode.IsSimCodegenMode
        allowZeroState=false;
        return;
    end


    if h.isHierarchyReadonly||...
        h.isHierarchySimulating||...
        h.isLinked
        return;
    end

    rows=size(tabledata,1);



    for row=1:rows
        columnData=tabledata{row,2};
        if Simulink.variant.keywords.isValidVariantKeywordForExpressionMode(columnData)
            allowZeroState=false;
            break;
        else
            iMdl=h.Path;
            iMdl=bdroot(iMdl);
            variant=columnData;
            isValidVarName=isvarname(variant);
            if isValidVarName
                isVarObj=existsInGlobalScope(iMdl,variant);
                if isVarObj
                    isVarObj=evalinGlobalScope(iMdl,['isa(',variant,', ''Simulink.Variant'');']);
                end
                if isVarObj
                    condition=evalinGlobalScope(iMdl,[variant,'.Condition']);
                    if condition=="(default)"
                        allowZeroState=false;
                        break;
                    end
                end
            end
        end
    end

end



function[variantsPanelTableGrp,variantsPanelbotPanelOverride,variantsPanelbotPanelExceptOverride]=i_GetVariantsPanel(source,h,opts)

    ls=h.StaticLinkStatus;
    readOnly=strcmp(ls,'resolved')||strcmp(ls,'implicit');


    myData.TableItemChanged=0;


    if isempty(source.UserData)

        tableData=variantSourceSinkddg_cb('getVariantsData',h.Handle);
        myData.TableData=tableData;

        myData.OverrideVariant=h.LabelModeActiveChoice;

        myData.VCType=h.VariantControlMode;

        myData.AZVC=h.AllowZeroVariantControls;

        myData.VariantActivationTime=h.VariantActivationTime;

        myData.OFC=strcmp(h.OutputFunctionCall,'on');
    else

        myData=source.UserData;
        tableData=myData.TableData;
    end

    isInSimCodegenMode=slfeature('VariantKeywordsSimCodegen')>0...
    &&(strcmp(get_param(h.handle,'VariantControlMode'),'sim codegen switching')||strcmp(myData.VCType,opts.SimCodegenModeStr));


    if isempty(tableData)
        myData.Entries={};
    else

        myData.Entries=tableData(:,2);
    end
    rows=size(tableData,1);


    if(rows>0)
        varObject=strtrim(tableData{1,2});
        editEnabled=i_getEnableEditButton(varObject,h.VariantActivationTime);
    else
        editEnabled=false;
    end

    if isInSimCodegenMode
        editEnabled=false;
    end


    source.UserData=myData;

    blockH=h.Handle;
    PortHand=get_param(blockH,'PortHandles');

    numPorts=length(PortHand.Outport);
    if numPorts==1
        numPorts=length(PortHand.Inport);
    end


    enableAddButton=~(isInSimCodegenMode&&numPorts>=2);


    enableDeleteButton=~(numPorts==1||(isInSimCodegenMode&&numPorts<=2));





    VCTypeEntries={opts.ExpressionModeStr,opts.LabelModeStr};
    if slfeature('VariantKeywordsSimCodegen')>0
        VCTypeEntries{end+1}=opts.SimCodegenModeStr;
    end
    myData.VCTypeEntries=VCTypeEntries;


    vcTypeIdx=find(strcmp(myData.VCTypeEntries,myData.VCType));
    if isempty(vcTypeIdx)
        vcTypeIdx=0;
    else
        vcTypeIdx=vcTypeIdx-1;
    end








    isImplicit=false;
    isResolved=false;


    pVCType.Name=DAStudio.message('Simulink:VariantBlockPrompts:VCType');
    pVCType.Type='combobox';
    pVCType.Tag='VariantControlModeCombo';
    pVCType.RowSpan=[1,1];
    pVCType.ColSpan=[1,1];
    entries={message('Simulink:VariantBlockPrompts:Expressions_CB').getString(),...
    message('Simulink:VariantBlockPrompts:Labels_CB').getString()};
    if slfeature('VariantKeywordsSimCodegen')>0
        entries{end+1}=message('Simulink:VariantBlockPrompts:SimCodegenSwitching_CB').getString();
    end
    pVCType.Entries=entries;
    pVCType.Value=vcTypeIdx;
    pVCType.Enabled=Simulink.isParameterEnabled(blockH,'LabelModeActiveChoice');
    pVCType.ToolTip=DAStudio.message('Simulink:Variants:VCTypeTooltip');
    pVCType.MatlabMethod='variantSourceSinkddg_cb';
    pVCType.MatlabArgs={'doVCType','%dialog'};







    linkStatusForBlock=get_param(source.getBlock.handle,'StaticLinkStatus');
    if strcmp(linkStatusForBlock,'resolved')
        pVCType.Enabled=false;
        isResolved=true;
    elseif strcmp(linkStatusForBlock,'implicit')
        pVCType.Enabled=true;
        isImplicit=true;
    end





    vcMode.IsExpressionMode=strcmp(myData.VCType,opts.ExpressionModeStr);
    vcMode.IsLabelMode=~vcMode.IsExpressionMode&&strcmp(myData.VCType,opts.LabelModeStr);
    vcMode.IsSimCodegenMode=~vcMode.IsExpressionMode&&~vcMode.IsLabelMode&&strcmp(myData.VCType,opts.SimCodegenModeStr);






    vatUDStr='update diagram';
    vatUDAACStr='update diagram analyze all choices';
    vatCCStr='code compile';

    VATypeEntries={vatUDStr,vatUDAACStr};
    if vcMode.IsExpressionMode
        VATypeEntries(end+1)={vatCCStr};
        if slfeature('StartupVariants')>0
            VATypeEntries{end+1}='startup';
        end
        if slfeature('InheritVAT')>0
            VATypeEntries{end+1}='inherit from Simulink.VariantControl';
        end
    end
    myData.VATypeEntries=VATypeEntries;


    vaTypeIdx=find(strcmp(myData.VATypeEntries,myData.VariantActivationTime));
    if isempty(vaTypeIdx)
        if vcMode.IsSimCodegenMode



            vaTypeIdx=1;
        else
            vaTypeIdx=0;
        end
    else
        vaTypeIdx=vaTypeIdx-1;
    end


    pVAType.Name=DAStudio.message('Simulink:VariantBlockPrompts:VATime');
    pVAType.Type='combobox';
    pVAType.Tag='VariantActivationTimeCombo';
    pVAType.RowSpan=[2,2];
    pVAType.ColSpan=[1,1];
    entries={message('Simulink:VariantBlockPrompts:VAT_UpdateDiagram').getString(),...
    message('Simulink:VariantBlockPrompts:VAT_UpdateDiagramAAC').getString()};
    if vcMode.IsExpressionMode
        entries{end+1}=message('Simulink:VariantBlockPrompts:VAT_CodeCompileTime').getString();
        if slfeature('StartupVariants')>0
            entries{end+1}=message('Simulink:VariantBlockPrompts:VAT_Startup').getString();
        end
        if slfeature('InheritVAT')>0
            entries{end+1}=message('Simulink:VariantBlockPrompts:VAT_Inherit').getString();
        end
    end
    pVAType.Entries=entries;
    pVAType.Value=vaTypeIdx;
    pVAType.Visible=~vcMode.IsLabelMode;
    pVAType.Enabled=isImplicit||(~vcMode.IsLabelMode&&...
    Simulink.isParameterEnabled(h.Handle,'VariantActivationTime'));

    pVAType.ToolTip=DAStudio.message('Simulink:Variants:VATypeTooltip');
    pVAType.MatlabMethod='variantSourceSinkddg_cb';
    pVAType.MatlabArgs={'doSetVariantActivationTime','%dialog'};


    vcMode_val=myData.VCType;
    VAT_val=myData.VariantActivationTime;
    VC_VAT_Desc.Name=Simulink.variant.ddgutils.getVariantModeDescription(vcMode_val,VAT_val);
    VC_VAT_Desc.Type='text';
    VC_VAT_Desc.WordWrap=true;
    VC_VAT_Desc.Tag='VC_VATDescription';
    VC_VAT_Desc.PreferredSize=[500,30];


    VC_VAT_DescSpacer.Name=' ';
    VC_VAT_DescSpacer.Type='text';
    VC_VAT_DescSpacer.RowSpan=[2,2];
    VC_VAT_DescSpacer.ColSpan=[1,1];

    pVC_VAT_DescPanel.Type='panel';
    pVC_VAT_DescPanel.LayoutGrid=[2,1];
    pVC_VAT_DescPanel.Items={VC_VAT_Desc,VC_VAT_DescSpacer};
    pVC_VAT_DescPanel.RowSpan=[1,1];
    pVC_VAT_DescPanel.ColSpan=[2,2];
    pVC_VAT_DescPanel.RowStretch=[0,1];

    VC_VAT_Spacer.Name=' ';
    VC_VAT_Spacer.Type='text';
    VC_VAT_Spacer.RowSpan=[3,3];
    VC_VAT_Spacer.ColSpan=[1,1];




    tableGrp1.Type='group';
    tableGrp1.LayoutGrid=[1,2];
    tableGrp1.ColSpan=[1,2];
    tableGrp1.RowSpan=[1,1];
    tableGrp1.ColStretch=[1,1];

    pVC_VAT_Panel.Type='panel';
    pVC_VAT_Panel.LayoutGrid=[3,1];
    pVC_VAT_Panel.Items={pVCType,pVAType,VC_VAT_Spacer};
    pVC_VAT_Panel.RowSpan=[1,1];
    pVC_VAT_Panel.ColSpan=[1,1];
    pVC_VAT_Panel.RowStretch=[0,0,1];

    tableGrp1.Items={pVC_VAT_Panel,pVC_VAT_DescPanel};


    pAddPort.Name='';
    pAddPort.Type='pushbutton';
    pAddPort.RowSpan=[3,3];
    pAddPort.ColSpan=[1,1];
    pAddPort.Enabled=~readOnly&&enableAddButton;
    pAddPort.FilePath=getBlockSupportResource('add_port.png');
    pAddPort.ToolTip=DAStudio.message('Simulink:dialog:InlineVariantAddPortToolTip');
    pAddPort.Tag='AddPortButton';
    pAddPort.MatlabMethod='variantSourceSinkddg_cb';
    pAddPort.MatlabArgs={'doAddPort','%dialog'};


    pDeletePort.Name='';
    pDeletePort.Type='pushbutton';
    pDeletePort.RowSpan=[4,4];
    pDeletePort.ColSpan=[1,1];
    pDeletePort.Enabled=~readOnly&&enableDeleteButton;
    pDeletePort.FilePath=getBlockSupportResource('delete_port.png');
    pDeletePort.ToolTip=DAStudio.message('Simulink:dialog:InlineVariantDeletePortToolTip');
    pDeletePort.Tag='DeletePortButton';
    pDeletePort.MatlabMethod='variantSourceSinkddg_cb';
    pDeletePort.MatlabArgs={'doDeletePort','%dialog'};



    pEdit.Name='';
    pEdit.Type='pushbutton';
    pEdit.RowSpan=[5,5];
    pEdit.ColSpan=[1,1];

    pEdit.Enabled=editEnabled&&~vcMode.IsLabelMode&&~vcMode.IsSimCodegenMode;
    pEdit.FilePath=getBlockSupportResource('EditVariantObject.png');
    pEdit.ToolTip=DAStudio.message('Simulink:dialog:SubsystemEditVariantObjectTip');
    pEdit.Tag='EditButton';
    pEdit.MatlabMethod='variantSourceSinkddg_cb';
    pEdit.MatlabArgs={'doEdit','%dialog'};



    spacer1.Name='';
    spacer1.Type='text';
    spacer1.RowSpan=[6,6];
    spacer1.ColSpan=[1,1];

    panel1.Type='panel';
    panel1.Items={pAddPort,pDeletePort,pEdit,spacer1};
    panel1.LayoutGrid=[4,1];
    panel1.RowStretch=[0,0,0,1];
    panel1.RowSpan=[2,2];
    panel1.ColSpan=[1,1];


    pTable.Name='';
    pTable.Type='table';
    modeSpecificColHeaders={};
    if vcMode.IsLabelMode||vcMode.IsSimCodegenMode
        pTable.Size=[rows,2];
        pTable.Data=i_getTableDataWithComboBox(tableData(:,1:2),vcMode,opts);
        pTable.ColumnCharacterWidth=[5,25];
        pTable.ColumnStretchable=[0,1];
        pTable.ReadOnlyColumns=0;
        if vcMode.IsLabelMode
            modeSpecificColHeaders{end+1}=DAStudio.message('Simulink:Variants:LabelMode_VariantControlColumnName');
        elseif vcMode.IsSimCodegenMode
            modeSpecificColHeaders{end+1}=DAStudio.message('Simulink:Variants:SimCodegenMode_VariantControlColumnName');
        end
    elseif vcMode.IsExpressionMode
        modeSpecificColHeaders{end+1}=DAStudio.message('Simulink:Variants:ExpressionMode_VariantControlColumnName');
        modeSpecificColHeaders{end+1}=DAStudio.message('Simulink:dialog:SubsystemVarTableCol2');
        pTable.Size=[rows,3];
        pTable.Data=i_getTableDataWithComboBox(tableData(:,1:3),vcMode,opts);
        pTable.ColumnCharacterWidth=[5,25,25];
        pTable.ReadOnlyColumns=[0,2];
        pTable.ColumnStretchable=[0,1,1];
    end
    pTable.ColHeader=[
    DAStudio.message('Simulink:dialog:InlineVariantTableCol1'),...
modeSpecificColHeaders
    ];
    pTable.Grid=1;
    pTable.HeaderVisibility=[0,1];
    pTable.RowSpan=[2,2];
    pTable.ColSpan=[2,2];
    pTable.Enabled=~isResolved;
    pTable.Editable=true;
    pTable.SelectionBehavior='Row';
    pTable.MinimumSize=[600,150];
    pTable.Tag='VariantsTable';
    pTable.ValueChangedCallback=@i_TableValueChanged;
    pTable.CurrentItemChangedCallback=@i_CurrentItemChangedCallback;
    pTable.SelectionChangedCallback=@i_SelectionChangedCallback;

    tableGrp.Name=DAStudio.message('Simulink:dialog:InlineVariantTableItems');
    tableGrp.Type='group';
    tableGrp.LayoutGrid=[1,2];
    tableGrp.ColStretch=[0,1];
    tableGrp.ColSpan=[1,1];
    tableGrp.RowSpan=[2,1];
    tableGrp.Items={panel1,pTable};
    tableGrp.Enabled=~isResolved;


    entriesWithPortConditions={};

    entries=tableData(:,2);


    myData.Entries=entries;

    for i=1:length(entries)
        entriesWithPortConditions{i}=sprintf('%s',strtrim(entries{i}));%#ok<AGROW>
    end


    idx=find(strcmp(myData.Entries,myData.OverrideVariant));
    if isempty(idx)
        idx=0;
    else
        idx=idx(1);
        idx=idx-1;
    end

    pOverride.Name=DAStudio.message('Simulink:Variants:LabelComboBox');
    pOverride.Type='combobox';
    pOverride.Tag='OverrideVariantCombo';
    pOverride.Entries=entriesWithPortConditions;
    pOverride.Value=idx;
    pOverride.Visible=vcMode.IsLabelMode;
    pOverride.Enabled=true;
    pOverride.ToolTip=DAStudio.message('Simulink:Variants:LabelComboBoxToolTip');
    pOverride.MatlabMethod='variantSourceSinkddg_cb';
    pOverride.MatlabArgs={'doOverride','%dialog'};



    pCodeGrp.Type='group';
    pCodeGrp.Tag='LabelGroup';
    pCodeGrp.LayoutGrid=[1,10];
    pCodeGrp.Items={pOverride};
    pCodeGrp.ColSpan=[1,1];
    pCodeGrp.RowSpan=[3,3];
    pCodeGrp.Visible=(vcTypeIdx==1);




    [pAllowZeroStateEnable,pAllowZeroValue]=i_getEnabledStateAndValueForAllowZeroCondition(h,myData,vcMode);
    pAllowZeroConditionCheckBox.Name=DAStudio.message('Simulink:dialog:InlineVariantAllowZeroCondition');
    pAllowZeroConditionCheckBox.Type='checkbox';
    pAllowZeroConditionCheckBox.Tag='InlineVariantBlockAllowZeroConditionCheckbox';
    pAllowZeroConditionCheckBox.ToolTip=DAStudio.message('Simulink:dialog:AZVCTip');
    pAllowZeroConditionCheckBox.Enabled=isImplicit||(pAllowZeroStateEnable&&Simulink.isParameterEnabled(source.getBlock.handle,'AllowZeroVariantControls'));
    pAllowZeroConditionCheckBox.Visible=vcMode.IsExpressionMode;
    pAllowZeroConditionCheckBox.Value=pAllowZeroValue;
    pAllowZeroConditionCheckBox.MatlabMethod='variantSourceSinkddg_cb';
    pAllowZeroConditionCheckBox.MatlabArgs={'doAZVCCheckbox','%dialog'};


    [OFCVisible,OFCValue]=Simulink.variant.ddgutils.getOutputFunctionCallStatus(h,myData);
    pOutputFunctionCall.Name=message('Simulink:blkprm_prompts:InportOutputFcnCall').getString();
    pOutputFunctionCall.Type='checkbox';
    pOutputFunctionCall.Tag='VariantOutputFunctionCallCheckbox';
    pOutputFunctionCall.Enabled=isImplicit||Simulink.isParameterEnabled(source.getBlock.handle,'OutputFunctionCall');
    pOutputFunctionCall.Visible=OFCVisible;
    pOutputFunctionCall.Value=OFCValue;
    pOutputFunctionCall.ToolTip=message('Simulink:dialog:VarOutputFunctionCallTip').getString();
    pOutputFunctionCall.MatlabMethod='variantSourceSinkddg_cb';
    pOutputFunctionCall.MatlabArgs={'doOutputFunctionCallCheckbox','%dialog'};



    pBlockIconOptionCheckbox.Name=DAStudio.message('Simulink:dialog:InlineVariantBlockIconOption');
    pBlockIconOptionCheckbox.Type='checkbox';
    pBlockIconOptionCheckbox.Tag='InlineVariantBlockIconCheckbox';
    pBlockIconOptionCheckbox.Value=strcmp(h.ShowConditionOnBlock,'on');
    pBlockIconOptionCheckbox.Enabled=isImplicit||Simulink.isParameterEnabled(source.getBlock.handle,'ShowConditionOnBlock');
    pBlockIconOptionCheckbox.MatlabMethod='syncAllOpenDialogs';
    pBlockIconOptionCheckbox.MatlabArgs={source,'%dialog','%tag','%value',''};



    pGPC.Name=DAStudio.message('Simulink:dialog:GenPreprocessorConditionals');
    pGPC.Type='checkbox';
    pGPC.Tag='GeneratePreprocessorCheckbox';
    pGPC.Value=strcmp(h.GeneratePreProcessorConditionals,'on');
    pGPC.Visible=false;
    pGPC.Enabled=false;
    pGPC.ToolTip=DAStudio.message('Simulink:dialog:GenPreprocessorConditionalsTip');
    pGPC.MatlabMethod='syncAllOpenDialogs';
    pGPC.MatlabArgs={source,'%dialog','%tag','%value',''};

    varOptionsGroupExceptOverride.Name='Options except override';
    varOptionsGroupExceptOverride.Type='panel';
    varOptionsGroupExceptOverride.LayoutGrid=[1,1];
    varOptionsGroupExceptOverride.Items={pAllowZeroConditionCheckBox,pOutputFunctionCall,pBlockIconOptionCheckbox,pGPC};
    varOptionsGroupExceptOverride.ColSpan=[1,1];
    varOptionsGroupExceptOverride.RowSpan=[1,1];

    varOptionsGroupOverride.Name='Override checkbox and combobox';
    varOptionsGroupOverride.Type='panel';
    varOptionsGroupOverride.LayoutGrid=[1,1];
    varOptionsGroupOverride.Items={pCodeGrp};
    varOptionsGroupOverride.ColSpan=[1,1];
    varOptionsGroupOverride.RowSpan=[1,1];
    varOptionsGroupOverride.Enabled=isImplicit||Simulink.isParameterEnabled(source.getBlock.handle,'LabelModeActiveChoice');


    variantsPanelTableGrp.Name='Table Group';
    variantsPanelTableGrp.Type='panel';
    variantsPanelTableGrp.LayoutGrid=[1,1];
    variantsPanelTableGrp.Items={tableGrp1,tableGrp};

    variantsPanelbotPanelOverride.Name='Table bottom panel override option';
    variantsPanelbotPanelOverride.Type='panel';
    variantsPanelbotPanelOverride.LayoutGrid=[1,1];
    variantsPanelbotPanelOverride.Items={varOptionsGroupOverride};

    variantsPanelbotPanelExceptOverride.Name='Table bottom panel except override';
    variantsPanelbotPanelExceptOverride.Type='panel';
    variantsPanelbotPanelExceptOverride.LayoutGrid=[1,1];
    variantsPanelbotPanelExceptOverride.Items={varOptionsGroupExceptOverride};


    source.UserData=myData;
end


function openInVariantManagerPanel=i_GetOpenInVariantManagerPanel(~,h)

    openInVariantManagerLink.Name=DAStudio.message('Simulink:dialog:OpenInVariantManager');
    openInVariantManagerLink.Type='hyperlink';
    openInVariantManagerLink.Tag='OpenInVariantManager';
    openInVariantManagerLink.MatlabMethod='Simulink.variant.utils.launchVariantManager';
    [rootModelName,blockPath]=Simulink.variant.utils.getBlockPathFromStudio(h.getFullName);
    expandSelectedRow=true;
    openInVariantManagerLink.MatlabArgs={'CreateAndNavigate',rootModelName,blockPath,expandSelectedRow};
    openInVariantManagerLink.RowSpan=[1,1];
    openInVariantManagerLink.ColSpan=[1,1];

    spacer.Name='';
    spacer.Type='text';
    spacer.RowSpan=[1,1];
    spacer.ColSpan=[2,2];

    openInVariantManagerPanel.Name='';
    openInVariantManagerPanel.Type='panel';
    openInVariantManagerPanel.LayoutGrid=[1,2];
    openInVariantManagerPanel.ColStretch=[0,1];
    openInVariantManagerPanel.Items={openInVariantManagerLink,spacer};
end


function i_TableValueChanged(dialogH,row,~,newVal)



    source=dialogH.getSource;
    myData=source.UserData;
    data=myData.TableData;

    block=source.getBlock;

    if(ishandle(block))
        temp=data{row+1,2};
        if(~strcmp(newVal,temp))
            myData.TableItemChanged=1;
        end
    end


    newVal=strtrim(newVal);
    data{row+1,2}=newVal;


    if Simulink.variant.keywords.isValidVariantKeyword(newVal)
        isVariantObject=false;
    else
        isVariantObject=slprivate('isVariantControlVariantObject',bdroot,newVal);
    end

    if isempty(newVal)||newVal(1)=='%'
        condValue=DAStudio.message('Simulink:Variants:Ignored');
    else
        condValue=DAStudio.message('Simulink:dialog:VariantConditionNotApplicable');
    end
    if isVariantObject
        try
            condValue=evalinGlobalScope(bdroot,[newVal,'.Condition']);
        catch
            condValue=DAStudio.message('Simulink:dialog:NoVariantObject');
        end
    end
    data{row+1,3}=condValue;


    myData.TableData=data;
    source.UserData=myData;


    dialogH.refresh;
end


function i_CurrentItemChangedCallback(dialogH,row,~)


    source=dialogH.getSource;
    myData=source.UserData;
    data=myData.TableData;


    varObject=strtrim(data{row+1,2});



    sel=dialogH.getWidgetValue('VariantControlModeCombo');
    entries=myData.VCTypeEntries;
    selVar=entries{sel+1};
    dialogH.setEnabled('EditButton',strcmp(selVar,'expression'));



    if~strcmp(selVar,'expression')
        return;
    end



    variantActivationTime=myData.VATypeEntries{dialogH.getWidgetValue('VariantActivationTimeCombo')+1};
    dialogH.setEnabled('EditButton',i_getEnableEditButton(varObject,variantActivationTime));
end


function i_SelectionChangedCallback(dialogH,tag)


    source=dialogH.getSource;
    myData=source.UserData;
    data=myData.TableData;


    currentSelectedRow=dialogH.getSelectedTableRow(tag);

    if currentSelectedRow~=-1
        varObject=strtrim(data{currentSelectedRow+1,2});
    else
        varObject='';
    end



    sel=dialogH.getWidgetValue('VariantControlModeCombo');
    entries=myData.VCTypeEntries;
    selVar=entries{sel+1};
    dialogH.setEnabled('EditButton',strcmp(selVar,'expression'));



    if~strcmp(selVar,'expression')
        return;
    end



    variantActivationTime=myData.VATypeEntries{dialogH.getWidgetValue('VariantActivationTimeCombo')+1};
    dialogH.setEnabled('EditButton',i_getEnableEditButton(varObject,variantActivationTime));
end

function opts=i_getDialogMessageStrings()



    opts.ExpressionModeStr='expression';
    opts.LabelModeStr='label';
    opts.SimCodegenModeStr='sim codegen switching';
    opts.SimKeywordStr=Simulink.variant.keywords.getSimVariantKeyword();
    opts.CodegenKeywordStr=Simulink.variant.keywords.getCodegenVariantKeyword();

end

function enable=i_getEnableEditButton(variantObject,variantActivationTime)



    isInInheritVAT=strcmp(variantActivationTime,'inherit from Simulink.VariantControl');
    if isInInheritVAT
        enable=false;
        return;
    end


    if isempty(variantObject)
        enable=false;
        return;
    end
    varObject=strip(variantObject,'left','%');
    enable=isvarname(varObject)&&~strcmp(varObject,'true')...
    &&~strcmp(varObject,'false');
end


