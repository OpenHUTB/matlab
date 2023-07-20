function dlgStruct=variantPMConnectorddg(source,h)





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




    descTxt.Name=DAStudio.message('Simulink:dialog:VariantConnectorBlkDescription');
    descTxt.Type='text';
    descTxt.WordWrap=true;

    descGrp.Name=DAStudio.message('Simulink:dialog:VariantConnectorBlkName');
    descGrp.Type='group';
    descGrp.Items={descTxt};
    descGrp.RowSpan=[1,1];
    descGrp.ColSpan=[1,1];





    [connectorBlkOptionPanel,variantsConditionSettingPanel,showVariantConditionPanel]=i_GetVariantsPanel(source,h);


    linkStatusForBlock=get_param(source.getBlock.handle,'StaticLinkStatus');
    switch linkStatusForBlock
    case{'resolved','implicit'}
        enableDialog=false;
    case{'inactive','none'}
        enableDialog=true;
    end

    connectorBlkOptionPanel.Enabled=true;
    variantsConditionSettingPanel.Enabled=enableDialog;
    showVariantConditionPanel.Enabled=true;

    paramGrp.Type='panel';
    paramGrp.LayoutGrid=[4,1];
    paramGrp.Items={connectorBlkOptionPanel,variantsConditionSettingPanel,showVariantConditionPanel};
    paramGrp.RowSpan=[2,2];
    paramGrp.ColSpan=[1,1];
    paramGrp.Source=h;





    if isa(h,'Simulink.VariantPMConnector')
        dlgStruct.DialogTag='Variant Connector';
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


    dlgStruct.PreApplyCallback='variantPMConnectorddg_cb';
    dlgStruct.PreApplyArgs={'doPreApply','%dialog'};
    dlgStruct.CloseCallback='variantPMConnectorddg_cb';
    dlgStruct.CloseArgs={'doClose','%dialog'};


    dlgStruct.CloseMethod='closeCallback';
    dlgStruct.CloseMethodArgs={'%dialog'};
    dlgStruct.CloseMethodArgsDT={'handle'};


    dlgStruct.DisableDialog=disableWholeDialog;

end


function[connectorBlkOptionPanel,variantsConditionSettingPanel,showVariantConditionPanel]=i_GetVariantsPanel(source,h)



    myData.TableItemChanged=0;



    if isempty(source.UserData)

        tableData=variantPMConnectorddg_cb('getVariantsData',h.Handle);
        myData.TableData=tableData;
        myData.ConnectorBlkType=h.ConnectorBlkType;
        myData.ConnectorTag=h.ConnectorTag;
        myData.ShowConditionOnBlock=h.ShowConditionOnBlock;
    else

        myData=source.UserData;
        tableData=myData.TableData;
    end


    if isempty(tableData)
        myData.Entries={};
    else

        myData.Entries=tableData(:,1);
    end
    rows=size(tableData,1);


    if(rows>0)
        varObject=strtrim(tableData{1,1});
        editEnabled=i_VCEditEnabled(varObject);
    else
        editEnabled=false;
    end


    source.UserData=myData;



    BlockTypeEntries={DAStudio.message('Simulink:Variants:LEAF_CONNECTOR_TYPE_CB'),DAStudio.message('Simulink:Variants:PRIMARY_CONNECTOR_TYPE_CB'),DAStudio.message('Simulink:Variants:NONPRIMARY_CONNECTOR_TYPE_CB')};



    myData.BlockTypeEntries={'Leaf','Primary','Nonprimary'};


    connectorBlkIdx=find(strcmp(myData.BlockTypeEntries,myData.ConnectorBlkType));
    if isempty(connectorBlkIdx)
        connectorBlkIdx=0;
    else
        connectorBlkIdx=connectorBlkIdx-1;
    end


    pConnectorType.Name=DAStudio.message('Simulink:Variants:ConnectorType');
    pConnectorType.Type='combobox';
    pConnectorType.Tag='ConnectorBlockTypeCombo';
    pConnectorType.RowSpan=[1,1];
    pConnectorType.ColSpan=[1,1];
    pConnectorType.Entries=BlockTypeEntries;
    pConnectorType.Value=connectorBlkIdx;
    pConnectorType.Enabled=Simulink.isParameterEnabled(source.getBlock.handle,'ConnectorBlkType');
    pConnectorType.ToolTip=DAStudio.message('Simulink:Variants:ConnectorBlkTypeTooltip');
    pConnectorType.MatlabMethod='variantPMConnectorddg_cb';
    pConnectorType.MatlabArgs={'doVariantConnectorBlkType','%dialog'};


    blockIsNonPrimary=strcmp(myData.ConnectorBlkType,'Nonprimary');
    blockIsLeaf=strcmp(myData.ConnectorBlkType,'Leaf');


    connectorBlkTag=myData.ConnectorTag;

    pConnectorTag.Name=DAStudio.message('Simulink:Variants:ConnectorTag');
    pConnectorTag.Type='edit';
    pConnectorTag.RowSpan=[1,1];
    pConnectorTag.ColSpan=[2,2];
    pConnectorTag.Tag='ConnectorTagEditBox';
    pConnectorTag.Enabled=Simulink.isParameterEnabled(source.getBlock.handle,'ConnectorTag');
    pConnectorTag.Visible=true;
    pConnectorTag.ToolTip=DAStudio.message('Simulink:Variants:ConnectorBlkTagTooltip');
    pConnectorTag.Value=connectorBlkTag;
    pConnectorTag.MatlabMethod='variantPMConnectorddg_cb';
    pConnectorTag.MatlabArgs={'doConnectorTag','%dialog'};




    pTagDummyWidget.Name='                                                                                         ';
    pTagDummyWidget.Type='text';
    pTagDummyWidget.RowSpan=[1,1];
    pTagDummyWidget.ColSpan=[2,2];

    pVariantControlDesc.Type='text';
    pVariantControlDesc.Name=message('Simulink:Variants:ConnectorBlk_VariantExpr_desc').getString();
    pVariantControlDesc.WordWrap=true;
    pVariantControlDesc.Tag='VariantControlExprDesc';
    pVariantControlDesc.Visible=~blockIsNonPrimary;
    pVariantControlDesc.RowSpan=[2,2];
    pVariantControlDesc.ColSpan=[1,2];

    if blockIsLeaf
        pConnectorBlkOptionGroupItem={pConnectorType,pTagDummyWidget,pVariantControlDesc};
    else
        pConnectorBlkOptionGroupItem={pConnectorType,pConnectorTag,pVariantControlDesc};
    end





    pConnectorBlkOptionGroup.Type='group';
    pConnectorBlkOptionGroup.Tag='ConnectorBlkOptionGroup';
    pConnectorBlkOptionGroup.LayoutGrid=[3,2];
    pConnectorBlkOptionGroup.Items=pConnectorBlkOptionGroupItem;
    pConnectorBlkOptionGroup.Enabled=Simulink.isParameterEnabled(source.getBlock.handle,'ConnectorBlkType');


    connectorBlkOptionPanel.Type='panel';
    connectorBlkOptionPanel.Tag='connectorBlkOptionPanel';
    connectorBlkOptionPanel.LayoutGrid=[1,1];
    connectorBlkOptionPanel.Items={pConnectorBlkOptionGroup};
    connectorBlkOptionPanel.ColSpan=[1,1];
    connectorBlkOptionPanel.RowSpan=[1,1];


    pVariantObjEdit.Name='';
    pVariantObjEdit.Type='pushbutton';
    pVariantObjEdit.RowSpan=[4,4];
    pVariantObjEdit.ColSpan=[1,1];
    pVariantObjEdit.Enabled=editEnabled;
    pVariantObjEdit.FilePath=getBlockSupportResource('EditVariantObject.png');
    pVariantObjEdit.ToolTip=DAStudio.message('Simulink:dialog:SubsystemEditVariantObjectTip');
    pVariantObjEdit.Tag='EditVariantObjButton';
    pVariantObjEdit.MatlabMethod='variantPMConnectorddg_cb';
    pVariantObjEdit.MatlabArgs={'doEditVariantObj','%dialog'};



    pDummyWidget1.Name='';
    pDummyWidget1.Type='text';
    pDummyWidget1.RowSpan=[5,5];
    pDummyWidget1.ColSpan=[1,1];

    variantObjEditPanel.Type='panel';
    variantObjEditPanel.Tag='VariantObjEditPanel';
    variantObjEditPanel.Items={pVariantObjEdit,pDummyWidget1};
    variantObjEditPanel.LayoutGrid=[4,1];
    variantObjEditPanel.RowStretch=[0,0,0,1];
    variantObjEditPanel.RowSpan=[2,2];
    variantObjEditPanel.ColSpan=[1,1];

    isLinkedBlk=false;
    linkStatusForBlock=get_param(source.getBlock.handle,'StaticLinkStatus');
    if strcmp(linkStatusForBlock,'resolved')
        isLinkedBlk=true;
    end


    pVariantTable.Name='';
    pVariantTable.Type='table';
    pVariantTable.Size=[rows,2];
    pVariantTable.Data=tableData;
    pVariantTable.Grid=1;
    pVariantTable.ColHeader={DAStudio.message('Simulink:Variants:ExpressionMode_VariantControlColumnName'),...
    DAStudio.message('Simulink:dialog:SubsystemVarTableCol2')};

    pVariantTable.HeaderVisibility=[0,1];
    pVariantTable.ColumnCharacterWidth=[30,25];
    pVariantTable.RowSpan=[2,2];
    pVariantTable.ColSpan=[2,2];
    pVariantTable.Enabled=~isLinkedBlk&&Simulink.isParameterEnabled(source.getBlock.handle,'VariantControls');
    pVariantTable.Editable=true;
    pVariantTable.ReadOnlyColumns=(1);
    pVariantTable.SelectionBehavior='Row';
    pVariantTable.PreferredSize=[550,10];
    pVariantTable.LastColumnStretchable=1;
    pVariantTable.Tag='VariantsTable';
    pVariantTable.ValueChangedCallback=@i_TableValueChanged;
    pVariantTable.CurrentItemChangedCallback=@i_CurrentItemChangedCallback;
    pVariantTable.SelectionChangedCallback=@i_SelectionChangedCallback;

    variantTableGroup.Name=DAStudio.message('Simulink:dialog:VariantConnectorBlkTableItems');
    variantTableGroup.Type='group';
    variantTableGroup.Tag='VariantTableGroup';
    variantTableGroup.LayoutGrid=[1,2];
    variantTableGroup.ColStretch=[0,1];
    variantTableGroup.ColSpan=[1,1];
    variantTableGroup.RowSpan=[2,1];
    variantTableGroup.Items={variantObjEditPanel,pVariantTable};


    variantsConditionSettingPanel.Name='Variant control settings group';
    variantsConditionSettingPanel.Tag='VariantConditionSettingPanel';
    variantsConditionSettingPanel.Type='panel';
    variantsConditionSettingPanel.LayoutGrid=[1,1];
    variantsConditionSettingPanel.Visible=~blockIsNonPrimary;
    variantsConditionSettingPanel.Items={variantTableGroup};



    pShowVCCheckbox.Name=DAStudio.message('Simulink:dialog:VariantConnectorVariantCondIconOption');
    pShowVCCheckbox.Type='checkbox';
    pShowVCCheckbox.Tag='ShowVariantControlCheckbox';
    pShowVCCheckbox.Value=strcmp(myData.ShowConditionOnBlock,'on');
    pShowVCCheckbox.Enabled=~blockIsNonPrimary&&Simulink.isParameterEnabled(source.getBlock.handle,'ShowConditionOnBlock');
    pShowVCCheckbox.Visible=~blockIsNonPrimary;
    pShowVCCheckbox.MatlabMethod='variantPMConnectorddg_cb';
    pShowVCCheckbox.MatlabArgs={'doShowVariantCondition','%dialog'};


    showVariantConditionPanel.Name='Show variant condition group';
    showVariantConditionPanel.Tag='ShowVariantConditionPanel';
    showVariantConditionPanel.Type='panel';
    showVariantConditionPanel.LayoutGrid=[1,1];
    showVariantConditionPanel.Items={pShowVCCheckbox};



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
        temp=data{row+1,1};
        if(~strcmp(newVal,temp))
            myData.TableItemChanged=1;
        end
    end


    newVal=strtrim(newVal);
    data{row+1,1}=newVal;


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
    data{row+1,2}=condValue;


    myData.TableData=data;
    source.UserData=myData;


    dialogH.refresh;
end


function i_CurrentItemChangedCallback(dialogH,row,~)


    source=dialogH.getSource;
    myData=source.UserData;
    data=myData.TableData;


    varObject=strtrim(data{row+1,1});




    if~isempty(varObject)
        if varObject(1)=='%'
            dialogH.setEnabled('EditVariantObjButton',isvarname(varObject(2:end)));
        else
            dialogH.setEnabled('EditVariantObjButton',i_VCEditEnabled(varObject));
        end
    else
        dialogH.setEnabled('EditVariantObjButton',false);
    end
end


function i_SelectionChangedCallback(dialogH,tag)



    source=dialogH.getSource;
    myData=source.UserData;
    data=myData.TableData;


    currentSelectedRow=dialogH.getSelectedTableRow(tag);

    if currentSelectedRow~=-1
        varObject=strtrim(data{currentSelectedRow+1,1});
    else
        varObject='';
    end





    if~isempty(varObject)
        if varObject(1)=='%'
            dialogH.setEnabled('EditVariantObjButton',isvarname(varObject(2:end)));
        else
            dialogH.setEnabled('EditVariantObjButton',i_VCEditEnabled(varObject));
        end
    else
        dialogH.setEnabled('EditVariantObjButton',false);
    end
end


function VCEditable=i_VCEditEnabled(varObject)
    VCEditable=~isempty(varObject)&&isvarname(varObject)...
    &&~(strcmp(varObject,'true')||strcmp(varObject,'false'));
end

