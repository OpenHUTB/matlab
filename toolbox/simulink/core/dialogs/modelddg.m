function dlgstruct=modelddg(h,name)









    if strcmp(name,'Simulink:Model:ForwardingTable')
        dlgstruct=i_ForwardingTableStandalone(h);
    else
        dlgstruct=i_FullDialog(h);
    end
    dlgstruct.DialogTag=name;

end

function dlgstruct=i_ForwardingTableStandalone(h)

    descTxt.Name=DAStudio.message('Simulink:dialog:ForwardingTableDescription');
    descTxt.Type='text';
    descTxt.WordWrap=true;

    descGrp.Name=DAStudio.message('Simulink:dialog:ModelTabThreeName');
    descGrp.Type='group';
    descGrp.Items={descTxt};

    tableGrp=i_GetTableGroup(h);

    dlgstruct.DialogTitle=[h.name,': ',DAStudio.message('Simulink:dialog:ModelTabThreeName')];
    dlgstruct.Items={descGrp,tableGrp};
    dlgstruct.PreApplyCallback='modelddg_cb';
    dlgstruct.PreApplyArgs={'%dialog','doPreApply'};
    dlgstruct.PostApplyArgs={'%dialog','doPostApply'};
    dlgstruct.PostApplyCallback='modelddg_cb';
    dlgstruct.HelpMethod='helpview';
    dlgstruct.HelpArgs={[docroot,'/mapfiles/simulink.map'],'modelpropertiesdialog'};
end


function s=i_Main(h)




    info.Type='textbrowser';
    info.Text=i_model_info(h);
    info.DialogRefresh=1;
    info.Tag='Info';

    s={info};
end

function s=i_Callbacks(h)







    skipRuntimCallbacks=bdIsLibrary(h.Handle)||bdIsSubsystem(h.Handle);
    [callbackProp,callbackPrompt,widget_tags]=Simulink.BlockDiagram.getCallbacks(skipRuntimCallbacks);

    items=cell(1,length(callbackProp));
    markedProps=callbackProp;
    for i=1:length(callbackProp)
        widget.Name=callbackPrompt{i};
        widget.Type='matlabeditor';
        widget.ObjectProperty=callbackProp{i};
        widget.Tag=widget_tags{i};

        panel.Type='panel';
        panel.Items={widget};
        panel.Tag=strcat('Panel_',num2str(i));

        items(i)={panel};

        if~all(isspace(h.(callbackProp{i})))
            markedProps{i}=[markedProps{i},'*'];
        end
    end

    cbTree.Name=DAStudio.message('Simulink:dialog:ModelCbTreeName');
    cbTree.Type='tree';
    cbTree.RowSpan=[1,1];
    cbTree.ColSpan=[1,1];
    cbTree.TreeItems=markedProps;
    cbTree.TreeItemIds=num2cell(0:length(cbTree.TreeItems)-1);
    cbTree.TargetWidget='CallbackStack';
    cbTree.Graphical=true;
    cbTree.MinimumSize=[85,10];
    cbTree.Tag='CallbackFunctions';

    callback2Prop={'SetupFcn',...
    'CleanupFcn'};
    callback2Prompt={...
    DAStudio.message('Simulink:dialog:ModelCallbackPromptSetupFcn'),...
    DAStudio.message('Simulink:dialog:ModelCallbackPromptCleanupFcn')};
    widget2_tags={'Model setup function:',...
    'Model cleanup function:'};
    items2=cell(1,length(callback2Prop));
    marked2Props=callback2Prop;
    for i=1:length(callback2Prop)
        widget.Name=callback2Prompt{i};
        widget.Type='editarea';
        widget.ObjectProperty=callback2Prop{i};
        widget.Tag=widget2_tags{i};

        panel2.Type='panel';
        panel2.Items={widget};
        panel2.Tag=strcat('Panel_',num2str(i+numel(items)));

        items2(i)={panel2};

        if~isempty(h.(callback2Prop{i}))
            marked2Props{i}=[marked2Props{i},'*'];
        end
    end

    cb2Tree.Name=DAStudio.message('Simulink:dialog:TopModelCbTreeName');
    cb2Tree.Type='tree';
    cb2Tree.RowSpan=[2,2];
    cb2Tree.ColSpan=[1,1];
    cb2Tree.TreeItems=marked2Props;
    cb2Tree.TreeItemIds=num2cell((0:length(cb2Tree.TreeItems)-1)+numel(items));
    cb2Tree.TargetWidget='CallbackStack';
    cb2Tree.Graphical=true;
    cb2Tree.MinimumSize=[25,10];
    cb2Tree.Tag='CallbackFunctions2';
    if slfeature('SetupAndCleanupCallbacks')>0
        cb2Tree.Visible=true;
    else
        cb2Tree.Visible=false;
    end

    cbTree.MatlabMethod='modelddg_cb';
    cbTree.MatlabArgs={'%dialog','doSelectCallbackFcn',cb2Tree.Tag};
    cb2Tree.MatlabMethod='modelddg_cb';
    cb2Tree.MatlabArgs={'%dialog','doSelectCallbackFcn',cbTree.Tag};

    cbStack.Type='widgetstack';
    cbStack.RowSpan=[1,2];
    cbStack.ColSpan=[2,2];
    cbStack.Tag='CallbackStack';
    cbStack.Items=[items,items2];

    s={cbTree,cb2Tree,cbStack};
end

function s=i_ForwardingTable(h)






    descTxt.Name=DAStudio.message('Simulink:dialog:ForwardingTableDescription');
    descTxt.Type='text';
    descTxt.WordWrap=true;

    descGrp.Name=DAStudio.message('Simulink:dialog:ModelTabThreeName');
    descGrp.Type='group';
    descGrp.Items={descTxt};
    descGrp.RowSpan=[1,1];
    descGrp.ColSpan=[1,2];

    tableGrp=i_GetTableGroup(h);
    tablePanel.Type='panel';
    tablePanel.LayoutGrid=[1,1];
    tablePanel.Items={tableGrp};
    tablePanel.RowSpan=[2,2];
    tablePanel.ColSpan=[1,1];

    s={descGrp,tablePanel};
end

function s=i_Properties(h)






    readOnly.Name=DAStudio.message('Simulink:dialog:ModelReadOnlyName');
    readOnly.Tag=readOnly.Name;
    readOnly.RowSpan=[3,3];
    readOnly.ColSpan=[1,1];
    readOnly.Type='checkbox';
    readOnly.DialogRefresh=1;
    readOnly.MatlabMethod='modelddg_cb';
    readOnly.MatlabArgs={'%dialog','doReadOnly',h,'%value'};
    if(strcmp(h.EditVersionInfo,'ViewCurrentValues'))
        readOnly.Value=1;
        editMode=0;
    else
        readOnly.Value=0;
        editMode=1;
    end

    creatorEditLbl.Name=DAStudio.message('Simulink:dialog:ModelCreatorEditLblName');
    creatorEditLbl.Type='text';
    creatorEditLbl.RowSpan=[1,1];
    creatorEditLbl.ColSpan=[1,1];
    creatorEditLbl.Tag='CreatorEditLbl';

    creatorEdit.Name='';
    creatorEdit.Tag=creatorEditLbl.Name;
    creatorEdit.RowSpan=[1,1];
    creatorEdit.ColSpan=[2,2];
    creatorEdit.Type='edit';
    creatorEdit.ObjectProperty='Creator';
    if editMode==1
        creatorEdit.Enabled=1;
    else
        creatorEdit.Enabled=0;
    end

    lastByValLbl.Name=DAStudio.message('Simulink:dialog:ModelLastByValLblName');
    lastByValLbl.Type='text';
    lastByValLbl.RowSpan=[1,1];
    lastByValLbl.ColSpan=[3,3];
    lastByValLbl.Tag='LastByValLbl';

    lastByVal.Name='';
    lastByVal.Tag=lastByValLbl.Name;
    lastByVal.RowSpan=[1,1];
    lastByVal.ColSpan=[4,4];
    lastByVal.Type='edit';
    if(editMode==1)
        lastByVal.ObjectProperty='ModifiedByFormat';
    else
        lastByVal.Value=h.LastModifiedBy;
        lastByVal.Enabled=0;
    end


    createdEditLbl.Name=DAStudio.message('Simulink:dialog:ModelCreatedEditLblName');
    createdEditLbl.Type='text';
    createdEditLbl.RowSpan=[2,2];
    createdEditLbl.ColSpan=[1,1];
    createdEditLbl.Tag='CreatedEditLbl';

    createdEdit.Name='';
    createdEdit.Tag=createdEditLbl.Name;
    createdEdit.RowSpan=[2,2];
    createdEdit.ColSpan=[2,2];
    createdEdit.Type='edit';
    createdEdit.ObjectProperty='Created';
    if editMode==1
        createdEdit.Enabled=1;
    else
        createdEdit.Enabled=0;
    end

    lastOnVerValLbl.Name=DAStudio.message('Simulink:dialog:ModelLastOnVerValLblName');
    lastOnVerValLbl.Type='text';
    lastOnVerValLbl.RowSpan=[2,2];
    lastOnVerValLbl.ColSpan=[3,3];
    lastOnVerValLbl.Tag='LastOnVerValLbl';

    lastOnVerVal.Name='';
    lastOnVerVal.Tag=lastOnVerValLbl.Name;
    lastOnVerVal.RowSpan=[2,2];
    lastOnVerVal.ColSpan=[4,4];
    lastOnVerVal.Type='edit';
    lastOnVerVal.Value=h.LastModifiedDate;
    if(editMode==1)
        lastOnVerVal.ObjectProperty='ModifiedDateFormat';
    else
        lastOnVerVal.Value=h.LastModifiedDate;
        lastOnVerVal.Enabled=0;
    end

    modelVerValLbl.Name=DAStudio.message('Simulink:dialog:ModelModelVerValLblName');
    modelVerValLbl.Type='text';
    modelVerValLbl.RowSpan=[3,3];
    modelVerValLbl.ColSpan=[3,3];
    modelVerValLbl.Tag='ModelVerValLbl';

    modelVerVal.Name='';
    modelVerVal.Tag=modelVerValLbl.Name;
    modelVerVal.RowSpan=[3,3];
    modelVerVal.ColSpan=[4,4];
    modelVerVal.Type='edit';
    if(editMode==1)
        modelVerVal.ObjectProperty='ModelVersionFormat';
    else
        modelVerVal.Enabled=0;
        modelVerVal.Value=h.ModelVersion;
    end

    SLXCompressionWidget=Simulink.ModelPropertiesDDGSource.createSLXCompressionWidget(h.name);
    SLXCompressionWidget.label.RowSpan=[4,4];
    SLXCompressionWidget.combobox.RowSpan=[4,4];

    version.Name='';
    version.Type='group';
    version.LayoutGrid=[4,4];
    version.ColStretch=[0,1,0,1];
    version.RowSpan=[1,1];
    version.ColSpan=[1,1];
    version.Items={creatorEditLbl,creatorEdit,...
    lastByValLbl,lastByVal,...
    createdEditLbl,createdEdit,...
    lastOnVerValLbl,lastOnVerVal,...
    readOnly,...
    modelVerValLbl,modelVerVal,...
    SLXCompressionWidget.label,SLXCompressionWidget.combobox};
    version.Tag='Version';

    s={version};
end

function s=i_Description(~)





    description.Name=DAStudio.message('Simulink:dialog:ModelDescriptionName');
    description.Type='editarea';
    description.ObjectProperty='Description';
    description.Tag='Model description:';

    s={description};
end

function dlgstruct=i_FullDialog(h)




    tab1.Name=DAStudio.message('Simulink:dialog:ModelTabOneName');
    tab1.LayoutGrid=[1,1];
    tab1.Items=i_Main(h);
    tab1.Tag='TabOne';

    tab2.Name=DAStudio.message('Simulink:dialog:ModelTabTwoName');
    tab2.LayoutGrid=[1,2];
    tab2.ColStretch=[1,2];
    tab2.Items=i_Callbacks(h);
    tab2.Tag='TabTwo';

    tab4.Name=DAStudio.message('Simulink:dialog:ModelTabFourName');
    tab4.LayoutGrid=[2,1];
    tab4.RowStretch=[0,1];
    tab4.Items=i_Properties(h);
    tab4.Tag='TabFour';

    tab5.Name=DAStudio.message('Simulink:dialog:ModelTabFiveName');
    tab5.Items=i_Description(h);
    tab5.Tag='TabFive';


    if slfeature('ShowExternalDataNode')>0
        tabData.Name=DAStudio.message('Simulink:dialog:ModelDataTabName_External');
    else
        tabData.Name=DAStudio.message('Simulink:dialog:ModelDataTabName');
    end
    [tabData.Items,dataRows,dataCols]=modelddg_data(h,true);
    tabData.LayoutGrid=[dataRows,dataCols];
    tabData.RowStretch=[0,0,0,1];
    tabData.Tag='TabData';

    tabcont.Type='tab';

    if bdIsLibrary(h.Handle)
        tab3.Name=DAStudio.message('Simulink:dialog:ModelTabThreeName');
        tab3.LayoutGrid=[2,1];
        tab3.RowStretch=[0,1];
        tab3.Items=i_ForwardingTable(h);
        tab3.Tag='TabThree';

        tabcont.Tabs={tab1,tab2,tab3,tab4,tab5};

        extSources=get_param(h.name,'ExternalSources');
        hasExtSources=~(isempty(extSources)||...
        isequal(extSources,{''}));
        if slfeature('ShowExternalDataNode')>0&&(hasExtSources||slfeature('SLLibrarySLDD')>0)
            tabcont.Tabs{end+1}=tabData;
        end

        titleMsg=[DAStudio.message('Simulink:dialog:LibraryDialogTitle'),':   ',h.name];
    elseif bdIsSubsystem(h.Handle)

        tabcont.Tabs={tab1,tab2,tab4,tab5};

        extSources=get_param(h.name,'ExternalSources');
        hasExtSources=~(isempty(extSources)||...
        isequal(extSources,{''}));
        if slfeature('ShowExternalDataNode')>0&&(hasExtSources||slfeature('SLSubsystemSLDD')>0)
            tabcont.Tabs{end+1}=tabData;
        end

        titleMsg=[DAStudio.message('Simulink:dialog:SubsystemDialogTitle'),': ',h.name];
    else

        tabcont.Tabs={tab1,tab2,tab4,tab5,tabData};
        titleMsg=[DAStudio.message('Simulink:dialog:ModelDialogTitle'),': ',h.name];
    end

    tabcont.Tag='Tabcont';
    dlgstruct.Items={tabcont};



    dlgstruct.DialogTitle=titleMsg;
    dlgstruct.SmartApply=0;
    dlgstruct.PreApplyCallback='modelddg_cb';
    dlgstruct.PreApplyArgs={'%dialog','doPreApply'};
    dlgstruct.PostApplyArgs={'%dialog','doPostApply'};
    dlgstruct.PostApplyCallback='modelddg_cb';
    dlgstruct.HelpMethod='helpview';
    dlgstruct.HelpArgs={[docroot,'/mapfiles/simulink.map'],'modelpropertiesdialog'};

end

function tableGrp=i_GetTableGroup(h)

    openDialogs=DAStudio.ToolRoot.getOpenDialogs;
    fwTable=[];

    if(~isempty(openDialogs))



        [dialogFound,dialogH]=searchOpenDialogs(openDialogs,h);


        if(dialogFound)
            fwTable=dialogH.getUserData('ForwardingTable');
        end
    end

    if isempty(fwTable)||isempty(openDialogs)||~dialogFound
        fwTable=ForwardingTableSpreadsheet(h.name);
    end


    pTableFilter.Type='spreadsheetfilter';
    pTableFilter.RowSpan=[1,1];
    pTableFilter.ColSpan=[1,2];
    pTableFilter.Tag='ForwardingTableFilter';
    pTableFilter.TargetSpreadsheet='ForwardingTable';
    pTableFilter.PlaceholderText=DAStudio.message('Simulink:dialog:ForwardingTableFilterPlaceholderText');
    pTableFilter.Clearable=true;



    pTable.Name=DAStudio.message('Simulink:dialog:ModelTabThreeName');
    pTable.Type='spreadsheet';
    pTable.Source=fwTable;
    pTable.Columns=fwTable.m_Columns;
    pTable.Config=['{"columns":[{"name":"',ForwardingTableSpreadsheet.sOldBlockVersionColumn,'", "minsize":100},'...
    ,'{"name":"',ForwardingTableSpreadsheet.sNewBlockVersionColumn,'", "minsize":100}'...
    ,']}'];
    pTable.UserData=fwTable;
    pTable.RowSpan=[2,2];
    pTable.ColSpan=[2,2];
    pTable.MinimumSize=[600,150];
    pTable.Enabled=true;
    pTable.Editable=1;
    pTable.Tag='ForwardingTable';

    pTable.SelectionChangedCallback=@ProcessSpreadsheetItemSelectionChange;
    pTable.ValueChangedCallback=@ProcessSpreadsheetItemValueChange;
    pTable.ItemClickedCallback=@ProcessSpreadsheetItemClick;
    pTable.ItemDoubleClickedCallback=@ProcessSpreadsheetItemClick;

    deleteEnabled=false;
    TableSize=size(fwTable.m_Children,1);

    [moveUpEnabled,moveDownEnabled]=MoveButtonEnable(1,TableSize);



    pAdd.Name='';
    pAdd.Type='pushbutton';
    pAdd.RowSpan=[1,1];
    pAdd.ColSpan=[1,1];
    pAdd.FilePath=slprivate('getResourceFilePath','add.png');
    pAdd.ToolTip=DAStudio.message('Simulink:dialog:ForwardingTableAddEntryTip');
    pAdd.Tag='AddButton';
    pAdd.MatlabMethod='modelddg_cb';
    pAdd.MatlabArgs={'%dialog','doAdd'};


    pDelete.Name='';
    pDelete.Type='pushbutton';
    pDelete.RowSpan=[2,2];
    pDelete.ColSpan=[1,1];
    pDelete.Enabled=deleteEnabled;
    pDelete.FilePath=slprivate('getResourceFilePath','delete.png');
    pDelete.ToolTip=DAStudio.message('Simulink:dialog:ForwardingTableDeleteEntryTip');
    pDelete.Tag='DeleteButton';
    pDelete.MatlabMethod='modelddg_cb';
    pDelete.MatlabArgs={'%dialog','doDelete'};


    pMoveUp.Name='';
    pMoveUp.Type='pushbutton';
    pMoveUp.RowSpan=[3,3];
    pMoveUp.ColSpan=[1,1];
    pMoveUp.Enabled=moveUpEnabled;
    pMoveUp.FilePath=slprivate('getResourceFilePath','up.png');
    pMoveUp.ToolTip=DAStudio.message('Simulink:dialog:ForwardingTableMoveUpEntryTip');
    pMoveUp.Tag='MoveUpButton';
    pMoveUp.MatlabMethod='modelddg_cb';
    pMoveUp.MatlabArgs={'%dialog','doMoveUp'};


    pMoveDown.Name='';
    pMoveDown.Type='pushbutton';
    pMoveDown.RowSpan=[4,4];
    pMoveDown.ColSpan=[1,1];
    pMoveDown.Enabled=moveDownEnabled;
    pMoveDown.FilePath=slprivate('getResourceFilePath','down.png');
    pMoveDown.ToolTip=DAStudio.message('Simulink:dialog:ForwardingTableMoveDownEntryTip');
    pMoveDown.Tag='MoveDownButton';
    pMoveDown.MatlabMethod='modelddg_cb';
    pMoveDown.MatlabArgs={'%dialog','doMoveDown'};


    pGetGcb.Name=DAStudio.message('Simulink:dialog:ForwardingTableGetGcb');
    pGetGcb.Type='pushbutton';
    pGetGcb.RowSpan=[5,5];
    pGetGcb.ColSpan=[1,1];
    pGetGcb.Enabled=false;
    pGetGcb.ToolTip=DAStudio.message('Simulink:dialog:ForwardingTableGetGcbTip');
    pGetGcb.Tag='GetGcb';
    pGetGcb.MatlabMethod='modelddg_cb';
    pGetGcb.MatlabArgs={'%dialog','doGetGcb'};


    spacer1.Name='';
    spacer1.Type='text';
    spacer1.RowSpan=[6,6];
    spacer1.ColSpan=[1,1];

    panel1.Type='panel';
    panel1.Items={pAdd,pDelete,pMoveUp,pMoveDown,pGetGcb,spacer1};
    panel1.LayoutGrid=[6,1];
    panel1.RowStretch=[0,0,0,0,0,1];
    panel1.RowSpan=[2,2];
    panel1.ColSpan=[1,1];

    tableGrp.Name=DAStudio.message('Simulink:dialog:ForwardingTable');
    tableGrp.Type='group';
    tableGrp.LayoutGrid=[1,2];
    tableGrp.ColStretch=[0,1];
    tableGrp.ColSpan=[1,1];
    tableGrp.RowSpan=[1,1];
    tableGrp.Items={panel1,pTableFilter,pTable};

end


function ProcessSpreadsheetItemValueChange(ssTag,ssSelectedItem,propName,propValue,ssDlg)
    fwTable=ssDlg.getUserData(ssTag);



    if fwTable.isPathProperty(propName)

        if strcmp(ssSelectedItem{1}.m_OldBlockPath,ssSelectedItem{1}.m_NewBlockPath)==true

            version=get_param(ssDlg.getSource.name,'ModelVersion');
            ssSelectedItem{1}.m_NewBlockVersion=version;

            if fwTable.isValidMapEntry(propValue)

                ssSelectedItem{1}.m_OldBlockVersion=fwTable.getMapValue(propValue);
            else

                ssSelectedItem{1}.m_OldBlockVersion='0.0';
            end


            fwTable.setMapValue(propValue,version);
        else




























            fwTable.createMapData();


            ssSelectedItem{1}.m_OldBlockVersion=DAStudio.message('Simulink:dialog:ForwardingTableDefBlockVer');
            ssSelectedItem{1}.m_NewBlockVersion=DAStudio.message('Simulink:dialog:ForwardingTableDefBlockVer');
        end
    elseif fwTable.isVersionProperty(propName)







        fwTable.createMapData();
    end
end


function ProcessSpreadsheetItemSelectionChange(ssTag,ssSelectedRow,ssDlg)

    fwTable=ssDlg.getUserData(ssTag);



    tableSize=length(fwTable.m_Children);

    index=fwTable.getSelectedRowIndex(ssSelectedRow{1});


    if index>1&&index<tableSize

        ssDlg.setEnabled('MoveUpButton',true);
        ssDlg.setEnabled('MoveDownButton',true);
        ssDlg.setEnabled('DeleteButton',true);
    elseif index==1&&index==tableSize

        ssDlg.setEnabled('MoveUpButton',false);
        ssDlg.setEnabled('MoveDownButton',false);
        ssDlg.setEnabled('DeleteButton',true);
    elseif index==1

        ssDlg.setEnabled('MoveUpButton',false);
        ssDlg.setEnabled('MoveDownButton',true);
        ssDlg.setEnabled('DeleteButton',true);
    elseif index==tableSize

        ssDlg.setEnabled('MoveUpButton',true);
        ssDlg.setEnabled('MoveDownButton',false);
        ssDlg.setEnabled('DeleteButton',true);
    else

        ssDlg.setEnabled('MoveUpButton',false);
        ssDlg.setEnabled('MoveDownButton',false);
        ssDlg.setEnabled('DeleteButton',false);
    end
end


function ProcessSpreadsheetItemClick(ssTag,ssSelectedRow,ssPropName,ssDlg)

    fwTable=ssDlg.getUserData(ssTag);



    tableSize=length(fwTable.m_Children);

    index=fwTable.getSelectedRowAndPropertyIndex(ssSelectedRow{1},ssPropName);


    if index>1&&index<tableSize

        ssDlg.setEnabled('MoveUpButton',true);
        ssDlg.setEnabled('MoveDownButton',true);
        ssDlg.setEnabled('DeleteButton',true);
    elseif index==1&&index==tableSize

        ssDlg.setEnabled('MoveUpButton',false);
        ssDlg.setEnabled('MoveDownButton',false);
        ssDlg.setEnabled('DeleteButton',true);
    elseif index==1

        ssDlg.setEnabled('MoveUpButton',false);
        ssDlg.setEnabled('MoveDownButton',true);
        ssDlg.setEnabled('DeleteButton',true);
    elseif index==tableSize

        ssDlg.setEnabled('MoveUpButton',true);
        ssDlg.setEnabled('MoveDownButton',false);
        ssDlg.setEnabled('DeleteButton',true);
    else

        ssDlg.setEnabled('MoveUpButton',false);
        ssDlg.setEnabled('MoveDownButton',false);
        ssDlg.setEnabled('DeleteButton',false);

        return;
    end


    if fwTable.isPathProperty(ssPropName)
        ssDlg.setEnabled('GetGcb',true);
    else
        ssDlg.setEnabled('GetGcb',false);
    end
end


function htm=i_model_info(h)

    if isequal(h.Dirty,'on')
        isModifiedStr='<font color=''red''>yes</font>';
    else
        isModifiedStr='no';
    end

    isharness=Simulink.harness.isHarnessBD(h.name);

    if isharness
        title=DAStudio.message('Simulink:dialog:HarnessHTMLTextHarnessInfoFor');
    else
        title=DAStudio.message('Simulink:dialog:ModelHTMLTextModelInfoFor');
    end

    tableheading=sprintf(['<table width="200%%"  BORDER=0 CELLSPACING=0 CELLPADDING=0 bgcolor="#ededed">',...
    '<tr><td>',...
    '<b><font size=+3>%s <a href="matlab:%s">%s</a></b></font>',...
    '<table>'],...
    title,h.Name,h.Name);

    rowformat='<tr><td align="right"><b>%s</b></td><td>%s</td></tr>';

    modelnamerow=sprintf(rowformat,DAStudio.message('Simulink:dialog:ModelHTMLTextSourceFile'),h.FileName);
    lastmodifiedrow=sprintf(rowformat,DAStudio.message('Simulink:dialog:ModelHTMLTextLastSaved'),h.LastModifiedDate);
    createdrow=sprintf(rowformat,DAStudio.message('Simulink:dialog:ModelHTMLTextCreatedOn'),h.Created);
    ismodifiedrow=sprintf(rowformat,DAStudio.message('Simulink:dialog:ModelHTMLTextIsModified'),isModifiedStr);
    modelversionrow=sprintf(rowformat,DAStudio.message('Simulink:dialog:ModelHTMLTextModelVersion'),h.ModelVersion);

    if isharness
        systemModelStr=Simulink.harness.internal.getHarnessOwnerBD(h.name);
        systembdrow=sprintf(rowformat,DAStudio.message('Simulink:dialog:HarnessHTMLTextSystemBD'),systemModelStr);
        ownerStr='';
        activeHarness=Simulink.harness.internal.getHarnessList(systemModelStr,'active');
        if strcmp(activeHarness.name,h.name)
            ownerStr=activeHarness.ownerFullPath;
        end
        ownerrow=sprintf(rowformat,DAStudio.message('Simulink:dialog:HarnessHTMLTextOwner'),ownerStr);
    else
        systembdrow='';
        ownerrow='';
    end

    tablefooter=['</table>',...
    '</td></tr>',...
    '</table>'];

    htm=[tableheading,modelnamerow,lastmodifiedrow,createdrow,ismodifiedrow,modelversionrow,systembdrow,ownerrow,tablefooter];

end


function[dialogFound,dialogH]=searchOpenDialogs(openDialogs,h)
    dialogFound=false;
    dialogH=[];

    for i=1:length(openDialogs)
        bdH=openDialogs(i).getSource;
        if(isa(bdH,'Simulink.BlockDiagram'))
            dialogName=bdH.Name;
            if(strcmp(dialogName,h.name)&&~strcmp('Simulink:Model:Info',openDialogs(i).DialogTag))
                dialogFound=true;
                dialogH=openDialogs(i);
                break;
            end
        end
    end

end


function[upEnabled,downEnabled]=MoveButtonEnable(selectedRow,TableSize)
    upEnabled=(selectedRow>1);
    downEnabled=(selectedRow<TableSize);
end



