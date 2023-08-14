function dlgStruct=subsysVariantsddg(source,h)




    disableWholeDialog=source.isHierarchyReadonly;

    if~disableWholeDialog

        if strcmp(h.LinkStatus,'resolved')&&strcmp(h.Mask,'on')
            [topMaskObj,bCanCreateNewMask]=Simulink.Mask.get(h.Handle);
            if~isempty(topMaskObj)&&(bCanCreateNewMask||~isempty(topMaskObj.BaseMask))

                disableWholeDialog=false;
            end
        end
    end

    if~disableWholeDialog
        [~,isLocked]=source.isLibraryBlock(h);
        disableWholeDialog=isLocked;
    end





    descTxt.Name=DAStudio.message('Simulink:dialog:SubsystemVariantDescription');
    descTxt.Type='text';
    descTxt.WordWrap=true;

    descGrp.Name='Variant Subsystem';
    descGrp.Type='group';
    descGrp.Items={descTxt};
    descGrp.RowSpan=[1,1];
    descGrp.ColSpan=[1,1];





    opts=i_getDialogMessageStrings();

    myData=prepareUserData(source,h);
    [MainTab]=i_GetMainTab(source,h,opts,myData);

    if slfeature('VariantAssemblySubsystem')>0
        [VariantAssemblyTab]=i_GetAssemblyTab(h,myData);
        paramGrp.Type='tab';
        paramGrp.LayoutGrid=[1,1];
        paramGrp.Tabs={MainTab,VariantAssemblyTab};
        paramGrp.RowSpan=[2,2];
        paramGrp.ColSpan=[1,1];
        paramGrp.Source=h;
        paramGrp.Tag='DialogTabs';
    else
        paramGrp=MainTab;
        paramGrp.Type='panel';
    end




    dlgStruct.DialogTag='Subsystem';
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


    dlgStruct.PreApplyCallback='subsysVariantsddg_cb';
    dlgStruct.PreApplyArgs={'doPreApply','%dialog'};
    dlgStruct.CloseCallback='subsysVariantsddg_cb';
    dlgStruct.CloseArgs={'doClose','%dialog'};


    dlgStruct.CloseMethod='closeCallback';
    dlgStruct.CloseMethodArgs={'%dialog'};
    dlgStruct.CloseMethodArgsDT={'handle'};

    dlgStruct.OpenCallback=@dialogOpenCallback;


    dlgStruct.DisableDialog=disableWholeDialog;
end

function dialogOpenCallback(dialog)

    if slfeature('VariantAssemblySubsystem')==0
        return;
    end

    source=dialog.getSource;
    block=source.getBlock;
    if isVariantAssemblySubsystem(block)
        choiceSelector=get_param(block.Handle,DAStudio.message('Simulink:VariantBlockPrompts:ChoiceSelectorParamName'));
        if strcmp(choiceSelector,'{}')||~isempty(source.UserData.WarningDisplayText)
            dialog.setActiveTab('DialogTabs',1);
        end
    end

end

function comboBoxWidget=i_CreateComboBox(index,columnData,vcMode,opts,isVAS)



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
    EditableComboTagName=sprintf('%s%d','vss_table_combobox_',index);
    EditableComboWidgetId=sprintf('%s%d','vss_table_combobox_widget_',index);
    EditableCombo.Name=EditableComboName;
    EditableCombo.Type='combobox';
    EditableCombo.Tag=EditableComboTagName;
    EditableCombo.WidgetId=EditableComboWidgetId;
    EditableCombo.Editable=true;
    EditableCombo.Entries=EditableComboData;
    EditableCombo.Enabled=~isVAS;
    comboBoxWidget=EditableCombo;
end



function tdata=i_getTableDataWithComboBox(tabledata,vcMode,opts,isVAS)

    tdata=tabledata;
    rows=size(tabledata,1);
    for i=1:rows
        rowData=tabledata{i,2};


        editableComboBox=i_CreateComboBox(i,rowData,vcMode,opts,isVAS);

        tdata{i,2}=editableComboBox;
    end
end


function[allowZeroState,allowZeroValue]=i_getEnabledStateAndValueForAZVC(h,dData,vcMode)


    tabledata=dData.MainTabVarTableData;



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






    if(rows==0)



        allowZeroState=false;
        allowZeroValue=false;
    elseif(rows==1)


        allowZeroState=true;
    else
        for row=1:rows
            columnData=tabledata{row,3};
            if Simulink.variant.keywords.isValidVariantKeywordForExpressionMode(columnData)
                allowZeroState=false;
            end
        end
    end





    for row=1:rows
        columnData=tabledata{row,3};
        if strcmp(columnData,'(default)')
            allowZeroValue=false;
            allowZeroState=false;
        end
    end
end


function[value]=i_VariantControlForChoiceBlksNotPromoted(h)





    value=true;






    isFastRestartOn=isequal(get_param(bdroot,'FastRestart'),'on');
    isModelStopped=isequal(get_param(bdroot,'SimulationStatus'),'stopped');

    if isFastRestartOn&&~isModelStopped
        value=false;
    end




    variantsInfo=get_param(h.Handle,'Variants');
    for i=1:numel(variantsInfo)
        [~,b]=Simulink.Mask.getPromotedInfo(variantsInfo(i).BlockName,'VariantControl',0);
        if~isempty(b)
            value=false;
            return;
        end
    end
end

function isVAS=isVariantAssemblySubsystem(block)
    if slfeature('VariantAssemblySubsystem')==0
        isVAS=false;
        return;
    end
    choiceSelector=get_param(block.getFullName,DAStudio.message('Simulink:VariantBlockPrompts:ChoiceSelectorParamName'));
    isVAS=~isempty(choiceSelector);
end

function panelExampleRow=getExampleRow(exampleText,exampleDescText,rowNum)
    textExample.Type='text';
    textExample.RowSpan=[1,1];
    textExample.ColSpan=[1,1];
    textExample.Name=exampleText;
    textExample.Bold=true;
    textExample.Alignment=1;

    textExampleDesc.Type='text';
    textExampleDesc.RowSpan=[1,1];
    textExampleDesc.ColSpan=[2,2];
    textExampleDesc.Name=['- ',exampleDescText];
    textExampleDesc.Alignment=1;

    panelExampleRow.Type='panel';
    panelExampleRow.LayoutGrid=[1,2];
    panelExampleRow.Items={textExample,textExampleDesc};
    panelExampleRow.RowSpan=[rowNum,rowNum];
    panelExampleRow.ColSpan=[1,1];
    panelExampleRow.ColStretch=[1,4];
end

function allExamplesPanelItems=getAllExamples(numExamples)
    allExamplesPanelItems=cell(1,numExamples);
    for idx=1:numExamples
        exampleTextId=['Simulink:VariantBlockPrompts:VASExample_',num2str(idx),'_Text'];
        exampleDescTextId=['Simulink:VariantBlockPrompts:VASExample_',num2str(idx),'_DescText'];
        allExamplesPanelItems{idx}=...
        getExampleRow(DAStudio.message(exampleTextId),DAStudio.message(exampleDescTextId),idx);
    end
end

function panel=createChoiceSelectionPanel(myData,blockHandle)

    assert(slfeature('VariantAssemblySubsystem')>0)

    choiceSelector=myData.ChoiceSelector;
    refTabVarTableData=myData.RefTabVarTableData;

    textVASReferenceTabDesc.Name=DAStudio.message('Simulink:VariantBlockPrompts:VASReferenceTabDesc');
    textVASReferenceTabDesc.Type='text';
    textVASReferenceTabDesc.WordWrap=true;
    textVASReferenceTabDesc.Enabled=true;
    textVASReferenceTabDesc.Tag='VASReferenceTabHelpText';
    textVASReferenceTabDesc.RowSpan=[1,1];
    textVASReferenceTabDesc.ColSpan=[1,1];

    togglepanelExamples.Type='togglepanel';
    togglepanelExamples.Name=DAStudio.message('Simulink:VariantBlockPrompts:VASExampleToggPanelName');
    togglepanelExamples.Items=getAllExamples(3);
    togglepanelExamples.LayoutGrid=[3,1];
    togglepanelExamples.RowSpan=[2,2];
    togglepanelExamples.ColSpan=[1,1];
    togglepanelExamples.Expand=false;

    panelVASRefTabDesc.Type='panel';
    panelVASRefTabDesc.LayoutGrid=[2,1];
    panelVASRefTabDesc.Items={textVASReferenceTabDesc,togglepanelExamples};

    editWidgetChoiceSelector.Name=DAStudio.message('Simulink:VariantBlockPrompts:VAS_ChoiceSelector');
    editWidgetChoiceSelector.Tag='ChoiceSelectorEdit';
    editWidgetChoiceSelector.Type='edit';
    editWidgetChoiceSelector.RowSpan=[1,1];
    editWidgetChoiceSelector.ColSpan=[1,1];
    editWidgetChoiceSelector.Value=choiceSelector;
    editWidgetChoiceSelector.ToolTip=DAStudio.message('Simulink:VariantBlockPrompts:VAS_ChoiceSelectorToolTip');

    pushbuttonWidgetValidateVarSelect.Name=DAStudio.message('Simulink:VariantBlockPrompts:VASRefTabValidateButton');
    pushbuttonWidgetValidateVarSelect.Tag='ValidateChoiceSelectorPushbutton';
    pushbuttonWidgetValidateVarSelect.Type='pushbutton';
    pushbuttonWidgetValidateVarSelect.RowSpan=[1,1];
    pushbuttonWidgetValidateVarSelect.ColSpan=[2,2];
    pushbuttonWidgetValidateVarSelect.MatlabMethod='subsysVariantsddg_cb';
    pushbuttonWidgetValidateVarSelect.MatlabArgs={'doValidateButton','%dialog'};
    pushbuttonWidgetValidateVarSelect.ToolTip=DAStudio.message('Simulink:VariantBlockPrompts:VASRefTabValAndRefBtnToolTip');

    groupChoiceSelector.Type='group';
    groupChoiceSelector.LayoutGrid=[1,2];
    groupChoiceSelector.Items={editWidgetChoiceSelector,pushbuttonWidgetValidateVarSelect};
    groupChoiceSelector.RowSpan=[2,2];
    groupChoiceSelector.ColSpan=[1,1];
    groupChoiceSelector.Enabled=Simulink.isParameterEnabled(blockHandle,DAStudio.message('Simulink:VariantBlockPrompts:ChoiceSelectorParamName'));

    imageWarningIcon.Type='image';
    imageWarningIcon.FilePath=getBlockSupportResource('warning_16.png');
    imageWarningIcon.RowSpan=[1,1];
    imageWarningIcon.ColSpan=[1,1];
    imageWarningIcon.Alignment=6;

    textWarnDisplayMessage.Type='text';
    textWarnDisplayMessage.Name=myData.WarningDisplayText;
    textWarnDisplayMessage.Tag='TextDisplayMessage';
    textWarnDisplayMessage.WordWrap=1;
    textWarnDisplayMessage.ForegroundColor=[0,0,0];
    textWarnDisplayMessage.Alignment=5;
    textWarnDisplayMessage.RowSpan=[1,1];
    textWarnDisplayMessage.ColSpan=[2,2];
    textWarnDisplayMessage.Bold=0;


    groupWarningDisplay.Type='group';
    groupWarningDisplay.Tag='GroupDisplayWarningMessage';
    groupWarningDisplay.LayoutGrid=[1,2];
    groupWarningDisplay.Items={imageWarningIcon,textWarnDisplayMessage};
    groupWarningDisplay.ColStretch=[1,30];
    groupWarningDisplay.Visible=~isempty(textWarnDisplayMessage.Name);
    groupWarningDisplay.RowSpan=[3,3];
    groupWarningDisplay.ColSpan=[1,1];

    textValidatingVCS.Type='text';
    textValidatingVCS.Tag='ValidatingVCSText';
    textValidatingVCS.Name=DAStudio.message('Simulink:VariantBlockPrompts:VASValidatingVCS');
    textValidatingVCS.RowSpan=[1,1];
    textValidatingVCS.ColSpan=[1,1];
    textValidatingVCS.Bold=1;

    groupValidatingVCS.Type='group';
    groupValidatingVCS.Tag='GroupValidatingVCS';
    groupValidatingVCS.LayoutGrid=[1,1];
    groupValidatingVCS.Items={textValidatingVCS};
    groupValidatingVCS.RowSpan=[4,4];
    groupValidatingVCS.ColSpan=[1,1];


    groupValidatingVCS.Visible=0;

    choicesTable.Name=DAStudio.message('Simulink:VariantBlockPrompts:VAS_VarTableTitle');
    choicesTable.NameLocation=3;
    choicesTable.Type='table';
    choicesTable.Size=size(refTabVarTableData);
    choicesTable.Data=refTabVarTableData;
    choicesTable.ColumnStretchable=[0,1];
    choicesTable.ReadOnlyColumns=[1,1];
    choicesTable.ColumnCharacterWidth=[15,45];
    choicesTable.ColHeader={DAStudio.message('Simulink:VariantBlockPrompts:VAS_VarTableCol1'),...
    DAStudio.message('Simulink:VariantBlockPrompts:VAS_VarTableCol2')};
    choicesTable.Grid=1;
    choicesTable.HeaderVisibility=[0,1];
    choicesTable.RowSpan=[1,1];
    choicesTable.ColSpan=[1,1];
    choicesTable.Editable=false;
    choicesTable.SelectionBehavior='Row';
    choicesTable.Tag='VariantsFromChSelTable';

    groupChoicesTable.Type='group';
    groupChoicesTable.Name='';
    groupChoicesTable.Items={choicesTable};
    groupChoicesTable.LayoutGrid=[1,1];
    groupChoicesTable.RowSpan=[5,5];
    groupChoicesTable.ColSpan=[1,1];
    groupChoicesTable.Enabled=groupChoiceSelector.Enabled;

    panel.Name='';
    panel.Type='panel';
    panel.LayoutGrid=[5,1];
    panel.Tag='choice_selector_panel_tag';
    panel.Items={panelVASRefTabDesc,groupChoiceSelector,groupWarningDisplay,groupValidatingVCS,groupChoicesTable};
    panel.RowStretch=[0,0,0,0,1];

end

function panelConvertToVAS=createConversionPanel(blockHandle)

    assert(slfeature('VariantAssemblySubsystem')>0)

    switch get_param(blockHandle,'StaticLinkStatus')
    case{'resolved','implicit'}
        isConvertBtnEnabled=false;
    case{'inactive','none'}
        isConvertBtnEnabled=true;
    end

    if strcmpi(get_param(blockHandle,'SimulinkSubDomain'),'architecture')||...
        strcmpi(get_param(blockHandle,'SimulinkSubDomain'),'softwarearchitecture')
        isConvertBtnEnabled=false;
    end

    textConvertDesc.Name=message('Simulink:VariantBlockPrompts:VSSReferenceTabDesc').getString();
    textConvertDesc.Type='text';
    textConvertDesc.WordWrap=true;
    textConvertDesc.Enabled=isConvertBtnEnabled;
    textConvertDesc.Tag='ConvertToVASHelpText';
    textConvertDesc.RowSpan=[1,1];
    textConvertDesc.ColSpan=[1,2];

    pushbuttonConvert.Name=message('Simulink:VariantBlockPrompts:VariantAssemblyTabConvertBtnTxt').getString();
    pushbuttonConvert.Alignment=2;
    pushbuttonConvert.Type='pushbutton';
    pushbuttonConvert.RowSpan=[2,2];
    pushbuttonConvert.ColSpan=[1,1];
    pushbuttonConvert.Enabled=isConvertBtnEnabled;
    pushbuttonConvert.Tag='ConvertToVASButton';
    pushbuttonConvert.MatlabMethod='subsysVariantsddg_cb';
    pushbuttonConvert.MatlabArgs={'doConvertToVAS','%dialog'};

    spacer.Name='';
    spacer.Type='text';
    spacer.RowSpan=[3,3];
    spacer.ColSpan=[1,2];

    panelConvertToVAS.Name='';
    panelConvertToVAS.Type='panel';
    panelConvertToVAS.LayoutGrid=[3,2];
    panelConvertToVAS.RowSpan=[1,3];
    panelConvertToVAS.ColSpan=[1,2];
    panelConvertToVAS.ColStretch=[1,1];
    panelConvertToVAS.RowStretch=[0,0,1];
    panelConvertToVAS.Tag='ConvertToVASPanel';
    panelConvertToVAS.Items={textConvertDesc,pushbuttonConvert,spacer};

end

function myData=prepareUserData(source,h)

    myData.TableItemChanged=0;


    if isempty(source.UserData)
        if isVariantAssemblySubsystem(h)


            isError=0;
            try
                slInternal('SyncVASGraphWithExternalSource',h.getFullName);
                myData.WarningDisplayText='';
            catch ex
                myData.WarningDisplayText=subsysVariantsddg_cb('getWarningDisplayText',ex);
                isError=isempty(myData.WarningDisplayText);
            end


            mainTabVarTableData=subsysVariantsddg_cb('getVariantsData',h.Handle);


            if isempty(myData.WarningDisplayText)&&~isError



                refTabVarTableData=...
                subsysVariantsddg_cb('getRefTabVarTableDataFromFilenames',mainTabVarTableData(:,2));
            else

                refTabVarTableData=cell(0,2);
            end

            myData.ChoiceSelector=get_param(h.Handle,...
            DAStudio.message('Simulink:VariantBlockPrompts:ChoiceSelectorParamName'));
            myData.RefTabVarTableData=refTabVarTableData;
        else

            mainTabVarTableData=subsysVariantsddg_cb('getVariantsData',h.Handle);

            myData.ChoiceSelector='';
            myData.RefTabVarTableData={};
            myData.WarningDisplayText='';
        end


        myData.MainTabVarTableData=mainTabVarTableData;

        myData.OverrideVariant=h.LabelModeActiveChoice;

        myData.VariantControlMode=h.VariantControlMode;

        myData.PropagateVariantConditions=h.PropagateVariantConditions;
        myData.AZVC=h.AllowZeroVariantControls;

        myData.VariantActivationTime=h.VariantActivationTime;
    else

        myData=source.UserData;
        mainTabVarTableData=myData.MainTabVarTableData;
    end


    if isempty(mainTabVarTableData)
        myData.Entries={};
    else

        entries=mainTabVarTableData(:,3);
        myData.Entries=entries;
    end


    source.UserData=myData;
end


function[VariantAssemblyTab]=i_GetAssemblyTab(block,myData)

    assert(slfeature('VariantAssemblySubsystem')>0)

    VariantAssemblyTab.Name=message('Simulink:VariantBlockPrompts:VSSTab_VariantAssembly').getString();
    VariantAssemblyTab.Tag='VariantAssemblyTab';
    VariantAssemblyTab.Items={};

    if isVariantAssemblySubsystem(block)
        VariantAssemblyTab.Items{1}=createChoiceSelectionPanel(myData,block.Handle);
    else
        VariantAssemblyTab.Items{1}=createConversionPanel(block.Handle);
    end

end


function[MainTab]=i_GetMainTab(source,h,opts,myData)

    isVAS=isVariantAssemblySubsystem(h);

    ls=h.StaticLinkStatus;
    readOnly=strcmp(ls,'resolved')||strcmp(ls,'implicit');

    perms=h.Permissions;
    isParentReadonly=strcmpi(perms,'ReadOnly')||strcmpi(perms,'NoReadOrWrite');

    mainTabVarTableData=myData.MainTabVarTableData;

    isInSimCodegenMode=slfeature('VariantKeywordsSimCodegen')>0...
    &&(strcmp(get_param(h.handle,'VariantControlMode'),'sim codegen switching')||strcmp(myData.VariantControlMode,opts.SimCodegenModeStr));

    rows=size(mainTabVarTableData,1);


    if(rows>0)
        varObject=strtrim(mainTabVarTableData{1,3});
        editEnabled=i_getEnableEditButton(varObject,h.VariantActivationTime);
    else
        editEnabled=false;
    end

    if isInSimCodegenMode
        editEnabled=false;
    end


    enableAddChoiceButton=~(isInSimCodegenMode&&rows>=2);






    VCTypeEntries={opts.ExpressionModeStr,opts.LabelModeStr};
    if slfeature('VariantKeywordsSimCodegen')>0
        VCTypeEntries{end+1}=opts.SimCodegenModeStr;
    end
    myData.VCTypeEntries=VCTypeEntries;


    vcTypeIdx=find(strcmp(myData.VCTypeEntries,myData.VariantControlMode));
    if isempty(vcTypeIdx)
        vcTypeIdx=0;
    else
        vcTypeIdx=vcTypeIdx-1;
    end


    pVCType.Name=message('Simulink:VariantBlockPrompts:VCType').getString();
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


    pVCType.Enabled=Simulink.isParameterEnabled(h.Handle,'LabelModeActiveChoice');

    pVCType.ToolTip=message('Simulink:Variants:VCTypeTooltip').getString();
    pVCType.MatlabMethod='subsysVariantsddg_cb';
    pVCType.MatlabArgs={'doVCType','%dialog'};










    isImplicit=false;
    linkStatusForBlock=get_param(source.getBlock.handle,'StaticLinkStatus');
    if strcmp(linkStatusForBlock,'resolved')
        pVCType.Enabled=false;
    elseif strcmp(linkStatusForBlock,'implicit')
        pVCType.Enabled=true;
        isImplicit=true;
    end



    pVCType.Enabled=pVCType.Enabled&&~isVAS;


    vcMode.IsExpressionMode=strcmp(myData.VariantControlMode,opts.ExpressionModeStr);
    vcMode.IsLabelMode=~vcMode.IsExpressionMode&&strcmp(myData.VariantControlMode,opts.LabelModeStr);
    vcMode.IsSimCodegenMode=~vcMode.IsExpressionMode&&~vcMode.IsLabelMode&&strcmp(myData.VariantControlMode,opts.SimCodegenModeStr);








    VATypeEntries={'update diagram','update diagram analyze all choices'};
    if vcMode.IsExpressionMode
        VATypeEntries{end+1}='code compile';
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


    pVAType.Name=message('Simulink:VariantBlockPrompts:VATime').getString();
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

    pVAType.ToolTip=message('Simulink:Variants:VATypeTooltip').getString();
    pVAType.MatlabMethod='subsysVariantsddg_cb';
    pVAType.MatlabArgs={'doSetVariantActivationTime','%dialog'};


    vcMode_val=myData.VariantControlMode;
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

    pVC_VAT_Panel.Type='panel';
    pVC_VAT_Panel.LayoutGrid=[3,1];
    pVC_VAT_Panel.Items={pVCType,pVAType,VC_VAT_Spacer};
    pVC_VAT_Panel.RowSpan=[1,1];
    pVC_VAT_Panel.ColSpan=[1,1];
    pVC_VAT_Panel.RowStretch=[0,0,1];




    groupVariantControlType.Type='group';
    groupVariantControlType.LayoutGrid=[1,2];
    groupVariantControlType.ColSpan=[1,2];
    groupVariantControlType.RowSpan=[1,1];
    groupVariantControlType.ColStretch=[1,1];
    groupVariantControlType.Items={pVC_VAT_Panel,pVC_VAT_DescPanel};




    pAddSubsys.Name='';
    pAddSubsys.Type='pushbutton';
    pAddSubsys.RowSpan=[3,3];
    pAddSubsys.ColSpan=[1,1];
    pAddSubsys.Enabled=~readOnly&&~isParentReadonly&&enableAddChoiceButton&&~isVAS;
    pAddSubsys.FilePath=getBlockSupportResource('AddSubsystemVariant.png');
    pAddSubsys.ToolTip=message('Simulink:dialog:SubsystemAddSubsystemChoiceTip').getString();
    pAddSubsys.Tag='AddSubsysButton';
    pAddSubsys.MatlabMethod='subsysVariantsddg_cb';
    pAddSubsys.MatlabArgs={'doAddSubsys','%dialog'};


    pAddModel.Name='';
    pAddModel.Type='pushbutton';
    pAddModel.RowSpan=[4,4];
    pAddModel.ColSpan=[1,1];
    pAddModel.Enabled=~readOnly&&~isParentReadonly&&enableAddChoiceButton&&~isVAS;
    pAddModel.FilePath=getBlockSupportResource('AddModelVariant.png');
    pAddModel.ToolTip=message('Simulink:dialog:SubsystemAddModelChoiceTip').getString();
    pAddModel.Tag='AddModelButton';
    pAddModel.MatlabMethod='subsysVariantsddg_cb';
    pAddModel.MatlabArgs={'doAddModel','%dialog'};


    pEdit.Name='';
    pEdit.Type='pushbutton';
    pEdit.RowSpan=[5,5];
    pEdit.ColSpan=[1,1];
    pEdit.Enabled=~isParentReadonly&&editEnabled&&vcMode.IsExpressionMode&&~isVAS;
    pEdit.FilePath=getBlockSupportResource('EditVariantObject.png');
    pEdit.ToolTip=message('Simulink:dialog:SubsystemEditVariantObjectTip').getString();
    pEdit.Tag='EditButton';
    pEdit.MatlabMethod='subsysVariantsddg_cb';
    pEdit.MatlabArgs={'doEdit','%dialog'};


    pOpen.Name='';
    pOpen.Type='pushbutton';
    pOpen.RowSpan=[6,6];
    pOpen.ColSpan=[1,1];
    pOpen.Enabled=1;
    pOpen.FilePath=getBlockSupportResource('OpenSubsystem.png');
    pOpen.ToolTip=message('Simulink:dialog:SubsystemOpenVariantTip').getString();
    pOpen.Tag='OpenButton';
    pOpen.MatlabMethod='subsysVariantsddg_cb';
    pOpen.MatlabArgs={'doOpen','%dialog'};


    pRefresh.Name='';
    pRefresh.Type='pushbutton';
    pRefresh.RowSpan=[7,7];
    pRefresh.ColSpan=[1,1];
    pRefresh.Enabled=1;
    pRefresh.FilePath=getBlockSupportResource('refresh.png');
    pRefresh.ToolTip=message('Simulink:dialog:SubsystemRefreshVariantTip').getString();
    pRefresh.Tag='RefreshButton';
    pRefresh.MatlabMethod='subsysVariantsddg_cb';
    pRefresh.MatlabArgs={'doRefresh','%dialog'};


    spacer1.Name='';
    spacer1.Type='text';
    spacer1.RowSpan=[8,8];
    spacer1.ColSpan=[1,1];

    panel1.Type='panel';
    panel1.Items={pAddSubsys,pAddModel,pEdit,pOpen,pRefresh,spacer1};
    panel1.LayoutGrid=[6,3];
    panel1.RowStretch=[0,0,0,0,0,1];
    panel1.RowSpan=[2,2];
    panel1.ColSpan=[1,1];




    pTable.Name='';
    pTable.Type='table';
    modeSpecificColHeaders={};
    if vcMode.IsLabelMode||vcMode.IsSimCodegenMode
        pTable.Size=[rows,2];
        pTable.Data=i_getTableDataWithComboBox(mainTabVarTableData(:,2:3),vcMode,opts,isVAS);
        pTable.ColumnCharacterWidth=[25,25];
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
        pTable.Data=i_getTableDataWithComboBox(mainTabVarTableData(:,2:4),vcMode,opts,isVAS);
        pTable.ReadOnlyColumns=[0,2];
        pTable.ColumnStretchable=[0,0,1];
        pTable.ColumnCharacterWidth=[20,30,20];
    end
    pTable.ColHeader=[
    DAStudio.message('Simulink:dialog:SubsystemVarTableCol0'),...
modeSpecificColHeaders
    ];
    pTable.Grid=1;
    pTable.HeaderVisibility=[0,1];
    pTable.RowSpan=[2,2];
    pTable.ColSpan=[2,2];
    pTable.Enabled=~isParentReadonly;
    pTable.Editable=~isParentReadonly;
    pTable.SelectionBehavior='Row';
    pTable.MinimumSize=[750,150];
    pTable.Tag='VariantsTable';
    pTable.ValueChangedCallback=@i_TableValueChanged;
    pTable.CurrentItemChangedCallback=@i_CurrentItemChangedCallback;
    pTable.SelectionChangedCallback=@i_SelectionChangedCallback;

    tableGrp.Name=DAStudio.message('Simulink:dialog:SubsystemVarChoices');
    tableGrp.Type='group';
    tableGrp.LayoutGrid=[1,2];
    tableGrp.ColSpan=[1,1];
    tableGrp.RowSpan=[2,1];
    tableGrp.Items={panel1,pTable};
    tableGrp.Enabled=i_VariantControlForChoiceBlksNotPromoted(h);










    entriesWithModelName={};

    entries=mainTabVarTableData(:,3);
    subsysBlocks=mainTabVarTableData(:,2);

    emptyIdx=find(strcmp(strtrim(entries),''));

    entries(emptyIdx)=[];
    subsysBlocks(emptyIdx)=[];

    commentedIdx=find(strncmp(strtrim(entries),'%',1));
    entries(commentedIdx)=[];
    subsysBlocks(commentedIdx)=[];


    myData.Entries=entries;

    for i=1:length(subsysBlocks)
        entriesWithModelName{i}=...
        sprintf('%s%s%s%s',entries{i},' (',subsysBlocks{i},') ');%#ok<AGROW>
    end


    idx=find(strcmp(myData.Entries,myData.OverrideVariant));
    if isempty(idx)
        idx=0;
    else
        idx=idx(1);
        idx=idx-1;
    end

    pOverride.Name=message('Simulink:Variants:LabelComboBox').getString();
    pOverride.Type='combobox';
    pOverride.Tag='OverrideVariantCombo';
    pOverride.Entries=entriesWithModelName;
    pOverride.Value=idx;
    pOverride.Visible=vcMode.IsLabelMode;
    pOverride.Enabled=vcMode.IsLabelMode;
    pOverride.ToolTip=message('Simulink:Variants:LabelComboBoxToolTip').getString();
    pOverride.MatlabMethod='subsysVariantsddg_cb';
    pOverride.MatlabArgs={'doOverride','%dialog'};


    pCodeGrp.Type='group';
    pCodeGrp.Tag='LabelGroup';
    pCodeGrp.LayoutGrid=[1,10];
    pCodeGrp.Items={pOverride};
    pCodeGrp.ColSpan=[1,1];
    pCodeGrp.RowSpan=[3,3];
    pCodeGrp.Visible=(vcTypeIdx==1);




    [pAZVCState,pAllowZeroValue]=i_getEnabledStateAndValueForAZVC(h,myData,vcMode);
    pAllowZeroConditionCheckBox.Name=message('Simulink:dialog:AZVC').getString();
    pAllowZeroConditionCheckBox.Type='checkbox';
    pAllowZeroConditionCheckBox.Tag='VariantSubsysBlockAllowZeroConditionCheckbox';
    pAllowZeroConditionCheckBox.Enabled=isImplicit||(pAZVCState&&Simulink.isParameterEnabled(source.getBlock.handle,'AllowZeroVariantControls'));
    pAllowZeroConditionCheckBox.Visible=vcMode.IsExpressionMode;
    pAllowZeroConditionCheckBox.Value=pAllowZeroValue;
    pAllowZeroConditionCheckBox.ToolTip=message('Simulink:dialog:AZVCTip').getString();
    pAllowZeroConditionCheckBox.MatlabMethod='subsysVariantsddg_cb';
    pAllowZeroConditionCheckBox.MatlabArgs={'doAZVCCheckbox','%dialog'};

    pGPC.Name=message('Simulink:dialog:GenPreprocessorConditionals').getString();
    pGPC.Type='checkbox';
    pGPC.Tag='GeneratePreprocessorCheckbox';
    pGPC.Value=strcmp(h.GeneratePreProcessorConditionals,'on');

    pGPC.Enabled=false;
    pGPC.Visible=false;

    pGPC.ToolTip=DAStudio.message('Simulink:dialog:GenPreprocessorConditionalsTip');
    pGPC.MatlabMethod='syncAllOpenDialogs';
    pGPC.MatlabArgs={source,'%dialog','%tag','%value',''};

    pPC.Name=DAStudio.message('Simulink:dialog:PropagateConditions');
    pPC.Type='checkbox';
    pPC.Tag='PropagateConditionsCheckbox';
    pPC.Value=strcmp(h.PropagateVariantConditions,'on');
    pPC.Enabled=isImplicit||Simulink.isParameterEnabled(source.getBlock.handle,'PropagateVariantConditions');
    pPC.ToolTip=message('Simulink:dialog:PropagateConditionsTip').getString();
    pPC.MatlabMethod='syncAllOpenDialogs';
    pPC.MatlabArgs={source,'%dialog','%tag','%value',''};

    varOptionsGroupExceptOverride.Name='Options except override';
    varOptionsGroupExceptOverride.Type='panel';
    varOptionsGroupExceptOverride.LayoutGrid=[1,1];
    varOptionsGroupExceptOverride.Items={pAllowZeroConditionCheckBox,pGPC,pPC};

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
    variantsPanelTableGrp.Items={groupVariantControlType,tableGrp};

    variantsPanelbotPanelOverride.Name='Table bottom panel override option';
    variantsPanelbotPanelOverride.Type='panel';
    variantsPanelbotPanelOverride.LayoutGrid=[1,1];
    variantsPanelbotPanelOverride.Items={varOptionsGroupOverride};

    variantsPanelbotPanelExceptOverride.Name='Table bottom panel except override';
    variantsPanelbotPanelExceptOverride.Type='panel';
    variantsPanelbotPanelExceptOverride.LayoutGrid=[1,1];
    variantsPanelbotPanelExceptOverride.Items={varOptionsGroupExceptOverride};


    variantsPanelTableGrp.Enabled=true;
    variantsPanelbotPanelOverride.Enabled=true;
    variantsPanelbotPanelExceptOverride.Enabled=true;

    MainTab.Name=message('Simulink:VariantBlockPrompts:VSSTab_Main').getString();
    MainTab.LayoutGrid=[1,1];
    MainTab.Items={variantsPanelTableGrp,variantsPanelbotPanelOverride,variantsPanelbotPanelExceptOverride};
    MainTab.Source=h;


    source.UserData=myData;
end


function openInVariantManagerPanel=i_GetOpenInVariantManagerPanel(~,h)

    openInVariantManagerLink.Name=message('Simulink:dialog:OpenInVariantManager').getString();
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
    data=myData.MainTabVarTableData;

    block=source.getBlock;
    mdl=bdroot(block.getFullName);

    if ishandle(block)
        temp=data{row+1,3};
        if(~strcmp(newVal,temp))
            myData.TableItemChanged=1;
        end
    end


    newVal=strtrim(newVal);
    data{row+1,3}=newVal;


    if Simulink.variant.keywords.isValidVariantKeyword(newVal)
        isVariantObject=false;
    else
        isVariantObject=slprivate('isVariantControlVariantObject',mdl,newVal);
    end

    if isempty(newVal)||newVal(1)=='%'
        condValue=DAStudio.message('Simulink:Variants:Ignored');
    else
        condValue=DAStudio.message('Simulink:dialog:VariantConditionNotApplicable');
    end
    if isVariantObject
        try
            condValue=evalinGlobalScope(mdl,[newVal,'.Condition']);
        catch
            condValue=DAStudio.message('Simulink:dialog:NoVariantObject');
        end
    end

    data{row+1,4}=condValue;
    myData.MainTabVarTableData=data;
    source.UserData=myData;


    dialogH.refresh;
end


function i_CurrentItemChangedCallback(dialogH,row,~)


    source=dialogH.getSource;
    myData=source.UserData;
    data=myData.MainTabVarTableData;


    varObject=strtrim(data{row+1,3});



    sel=dialogH.getWidgetValue('VariantControlModeCombo');
    entries=myData.VCTypeEntries;
    selVar=entries{sel+1};
    isExpressionMode=strcmp(selVar,'expression');
    dialogH.setEnabled('EditButton',isExpressionMode);



    if~isExpressionMode
        return;
    end



    variantActivationTime=myData.VATypeEntries{dialogH.getWidgetValue('VariantActivationTimeCombo')+1};
    dialogH.setEnabled('EditButton',i_getEnableEditButton(varObject,variantActivationTime));

end


function i_SelectionChangedCallback(dialogH,tag)



    source=dialogH.getSource;
    myData=source.UserData;
    data=myData.MainTabVarTableData;


    currentSelectedRow=dialogH.getSelectedTableRow(tag);

    if currentSelectedRow~=-1
        varObject=strtrim(data{currentSelectedRow+1,3});
    else
        varObject='';
    end


    sel=dialogH.getWidgetValue('VariantControlModeCombo');
    entries=myData.VCTypeEntries;
    selVar=entries{sel+1};
    isExpressionMode=strcmp(selVar,'expression');
    dialogH.setEnabled('EditButton',isExpressionMode);



    if~isExpressionMode
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


