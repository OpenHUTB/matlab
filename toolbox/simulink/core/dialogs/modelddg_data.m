function[dlgItems,rows,cols]=modelddg_data(h,showDescription)




    if~(bdIsSubsystem(h.Handle))&&~(h.isLibrary)&&slfeature('AllowExternalDataSources')>0
        [dlgItems,rows,cols]=modelddg_externaldata(h,showDescription);
        return;
    end

    ddProperty=h.DataDictionary;

    rowNum=1;

    if showDescription
        if h.isLibrary&&slfeature('SlLibrarySLDD')>0
            dataSourceSelectDesc.Name=DAStudio.message('Simulink:dialog:ModelDataSourceSelectDescLibrary');
            dataSourceSelectDesc.ToolTip=DAStudio.message('Simulink:dialog:ModelDataSourceSelectDescLibrary');
        elseif slfeature('EnableDictionaryToLookIntoBWS')>0

            dataSourceSelectDesc.Name=DAStudio.message('Simulink:dialog:ModelDataSourceSelectDesc1');
            dataSourceSelectDesc.ToolTip=DAStudio.message('Simulink:dialog:ModelDataSourceSelectDesc1');
        else
            dataSourceSelectDesc.Name=DAStudio.message('Simulink:dialog:ModelDataSourceSelectDesc');
            dataSourceSelectDesc.ToolTip=DAStudio.message('Simulink:dialog:ModelDataSourceSelectDesc');
        end

        dataSourceSelectDesc.Type='text';
        dataSourceSelectDesc.WordWrap=true;
        dataSourceSelectDesc.RowSpan=[rowNum,rowNum];
        dataSourceSelectDesc.ColSpan=[1,5];

        dataSourceSelectDesc.Tag='dataSourceSelectDesc';

        rowNum=rowNum+1;
    end

    if slfeature('SLModelAllowedBaseWorkspaceAccess')>1


        dataSourceSelect.Type='text';
        dataSourceSelect.Name=DAStudio.message('Simulink:dialog:ModelDataSourceSelectDD');


        dataSourceSelect.Value=1;
        dataSourceSelect.RowSpan=[rowNum,rowNum];
        dataSourceSelect.ColSpan=[1,1];
    else

        dataSourceSelect.Type='radiobutton';
        dataSourceSelect.Entries={...
        DAStudio.message('Simulink:dialog:ModelDataSourceSelectBWS')...
        ,DAStudio.message('Simulink:dialog:ModelDataSourceSelectDD')};
        if slfeature('EnableDictionaryToLookIntoBWS')>0
            dataSourceSelect.Name=DAStudio.message('Simulink:dialog:ModelDataSourceSelectLabel1');
        else
            dataSourceSelect.Name=DAStudio.message('Simulink:dialog:ModelDataSourceSelectLabel');
        end
        dataSourceSelect.MatlabArgs={'%dialog','doSelectDataSource'};

        if isempty(ddProperty)
            dataSourceSelect.Value=0;
        else
            dataSourceSelect.Value=1;
        end
        dataSourceSelect.ToolTip=DAStudio.message('Simulink:dialog:ModelDataSourceSelectTooltip');
        dataSourceSelect.ShowBorder=0;
        dataSourceSelect.Tag='DataSourceSelect';
        dataSourceSelect.RowSpan=[rowNum,rowNum];
        dataSourceSelect.ColSpan=[1,5];
        dataSourceSelect.MatlabMethod='modelddg_cb';
    end

    dataDict.Name='';


    dataDict.Value=h.DataDictionary;

    dataDict.Type='edit';
    dataDict.Editable=true;
    dataDict.Enabled=dataSourceSelect.Value==1||slfeature('SLModelAllowedBaseWorkspaceAccess')>1;
    dataDict.ToolTip=DAStudio.message('Simulink:dialog:ModelDataDictTooltip');
    dataDict.Tag='DataDictionary';
    dataDict.MatlabMethod='modelddg_cb';
    dataDict.MatlabArgs={'%dialog','doChangeDDName'};
    dataDict.Mode=1;
    dataDict.ColSpan=[1,4];

    rowNum=rowNum+1;
    pbSelectDD.Name=DAStudio.message('Simulink:dialog:ModelSelectDDBtn');
    pbSelectDD.Type='pushbutton';
    pbSelectDD.RowSpan=[rowNum,rowNum];
    pbSelectDD.ColSpan=[1,1];
    pbSelectDD.ToolTip=DAStudio.message('Simulink:dialog:ModelSelectDDTooltip');
    pbSelectDD.Tag='SelectDD';
    pbSelectDD.Enabled=dataSourceSelect.Value==1||slfeature('SLModelAllowedBaseWorkspaceAccess')>1;
    pbSelectDD.MatlabMethod='modelddg_cb';
    pbSelectDD.MatlabArgs={'%dialog','doSelectDD',dataDict.Tag};

    pbNewDD.Name=DAStudio.message('Simulink:dialog:ModelNewDDBtn');
    pbNewDD.Type='pushbutton';
    pbNewDD.RowSpan=[rowNum,rowNum];
    pbNewDD.ColSpan=[2,2];
    pbNewDD.ToolTip=DAStudio.message('Simulink:dialog:ModelNewDDTooltip');
    pbNewDD.Tag='NewDD';
    pbNewDD.Enabled=dataSourceSelect.Value==1||slfeature('SLModelAllowedBaseWorkspaceAccess')>1;
    pbNewDD.MatlabMethod='modelddg_cb';
    pbNewDD.MatlabArgs={'%dialog','doNewDD',dataDict.Tag};

    pbOpenDD.Name=DAStudio.message('Simulink:dialog:ModelOpenDDBtn');
    pbOpenDD.Type='pushbutton';
    pbOpenDD.RowSpan=[rowNum,rowNum];
    pbOpenDD.ColSpan=[3,3];
    pbOpenDD.ToolTip=DAStudio.message('Simulink:dialog:ModelOpenDDTooltip');
    pbOpenDD.Tag='OpenDD';
    pbOpenDD.Enabled=(dataSourceSelect.Value==1)&&~isempty(dataDict.Value);
    pbOpenDD.MatlabMethod='modelddg_cb';
    pbOpenDD.MatlabArgs={'%dialog','doOpenDD',dataDict.Tag};

    rowNum=rowNum+1;
    dataDict.RowSpan=[rowNum,rowNum];

    hasBWSAccess=true;
    ddHasBWSAccess=false;
    if slfeature('SLModelAllowedBaseWorkspaceAccess')>1

        rowNum=rowNum+1;

        enableBWSAccess.Name=DAStudio.message('Simulink:dialog:EnableBaseWorkspaceAccess');
        enableBWSAccess.Tag='EnableBWSAccess';
        enableBWSAccess.ColSpan=[1,5];
        enableBWSAccess.RowSpan=[rowNum,rowNum];
        enableBWSAccess.Type='checkbox';
        enableBWSAccess.Mode=true;
        enableBWSAccess.Value=strcmp(get_param(h.name,'EnableAccessToBaseWorkspace'),'on');
        hasBWSAccess=enableBWSAccess.Value;
        enableBWSAccess.ToolTip=DAStudio.message('Simulink:dialog:EnableBaseWorkspaceAccessTooltip');


        enableBWSAccess.MatlabMethod='modelddg_cb';
        enableBWSAccess.MatlabArgs={'%dialog','doSetEnableBWS','%value'};

        warnImagePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','search_warning.png');
        warningIcon.Type='image';
        warningIcon.RowSpan=[rowNum,rowNum];
        warningIcon.ColSpan=[1,1];
        warningIcon.FilePath=warnImagePath;
        warningIcon.Tag='inheritedBWSWarnIcon';
        ddAccessBWSMsg.Name=DAStudio.message('Simulink:dialog:BWSAccessViaDD');
        ddAccessBWSMsg.Type='text';
        ddAccessBWSMsg.WordWrap=true;
        ddAccessBWSMsg.Tag='HasBWSAccessViaDD';
        ddAccessBWSMsg.RowSpan=[rowNum,rowNum];
        ddAccessBWSMsg.ColSpan=[2,5];

        ddAccessBWS.Type='panel';
        ddAccessBWS.Tag='inheritedBWSAccess';
        ddAccessBWS.LayoutGrid=[1,5];
        ddAccessBWS.Items={warningIcon,ddAccessBWSMsg};
        ddAccessBWS.ColSpan=[1,5];
        ddAccessBWS.Visible=false;
        if~isempty(ddProperty)
            try
                ddTmp=Simulink.dd.open(ddProperty);
                ddAccessBWS.Visible=ddTmp.HasAccessToBaseWorkspace...
                &&~enableBWSAccess.Value;
                ddTmp.close;
            catch e


                if~strcmp(e.identifier,'SLDD:sldd:DictionaryNotFound')
                    DAStudio.warning(e.identifier);
                end
            end
        end
        ddHasBWSAccess=ddAccessBWS.Visible;
        rowNum=rowNum+1;
        ddAccessBWS.RowSpan=[rowNum,rowNum];

    end

    rowNum=rowNum+1;

    enforceDataConsistency.Name=DAStudio.message('Simulink:dialog:EnforceDataConsistency');
    enforceDataConsistency.Tag='EnforceDataConsistency';
    enforceDataConsistency.ColSpan=[1,5];
    enforceDataConsistency.RowSpan=[rowNum,rowNum];
    enforceDataConsistency.Type='checkbox';
    enforceDataConsistency.Value=strcmp(get_param(h.name,'EnforceDataConsistency'),'on');
    enforceDataConsistency.ToolTip=DAStudio.message('Simulink:dialog:EnforceDataConsistencyTooltip');

    if slfeature('SlDataEnableDataConsistencyCheck')<2
        enforceDataConsistency.Visible=false;
    end

    if slfeature('SLDataDictionaryMigrateUI')>0

        rowNum=rowNum+1;

        dataMigrationBtn.Type='pushbutton';
        dataMigrationBtn.Tag='DataMigrationBtn';
        dataMigrationBtn.Name=DAStudio.message('Simulink:dialog:MigrateDataButton');
        dataMigrationBtn.ToolTip=DAStudio.message('Simulink:dialog:MigrateDataButtonTooltip');
        dataMigrationBtn.RowSpan=[rowNum,rowNum];
        dataMigrationBtn.ColSpan=[1,1];
        dataMigrationBtn.Visible=(hasBWSAccess||ddHasBWSAccess);
        dataMigrationBtn.Enabled=~isempty(ddProperty);
        dataMigrationBtn.MatlabMethod='modelddg_cb';
        dataMigrationBtn.MatlabArgs={'%dialog',dataMigrationBtn.Tag,h};
    end

    encapMdl.Name=DAStudio.message('Simulink:dialog:EncapsulatedModel');
    encapMdl.Tag='EncapsulatedModel';
    encapMdl.RowSpan=[3,3];
    encapMdl.ColSpan=[1,2];
    encapMdl.Type='checkbox';
    encapMdl.DialogRefresh=1;
    encapMdl.MatlabMethod='modelddg_cb';
    encapMdl.MatlabArgs={'%dialog','doSetEM','%value'};
    if(strcmp(get_param(h.name,'IndependentSystem'),'on'))
        encapMdl.Value=1;
    else
        encapMdl.Value=0;
    end


    designDataGrp.Name=DAStudio.message('Simulink:dialog:ModelDesignDataGroupName');
    designDataGrp.Type='panel';
    designDataGrp.LayoutGrid=[7,5];

    designDataGrp.ColStretch=[0,0,0,0,1];
    designDataGrp.Items={};
    if showDescription
        designDataGrp.Items={dataSourceSelectDesc};
    else
        designDataGrp.Alignment=2;
    end
    if slfeature('SLModelAllowedBaseWorkspaceAccess')>1&&...
        ~((h.isLibrary&&slfeature('SLLibrarySLDD')>0)||...
        (bdIsSubsystem(h.Handle)&&slfeature('SLSubsystemSLDD')>0))
        designDataGrp.LayoutGrid=[9,5];
        designDataGrp.Items=[designDataGrp.Items,...
        dataSourceSelect,...
        pbSelectDD,pbNewDD,pbOpenDD,...
        dataDict,...
        enableBWSAccess,...
        ddAccessBWS,...
        ];
    else
        designDataGrp.Items=[designDataGrp.Items,...
        dataSourceSelect,...
        pbSelectDD,pbNewDD,pbOpenDD,...
        dataDict,...
        ];
    end
    if slfeature('SLDataDictionaryMigrateUI')>0&&...
        ~((h.isLibrary&&slfeature('SLLibrarySLDD')>0)||...
        (bdIsSubsystem(h.Handle)&&slfeature('SLSubsystemSLDD')>0))
        designDataGrp.Items{end+1}=dataMigrationBtn;
    end

    if slfeature('SlDataEnableDataConsistencyCheck')>1&&...
        ~(h.isLibrary&&slfeature('SLLibrarySLDD')>0)

        designDataGrp.Items{end+1}=enforceDataConsistency;
    end

    dlgRow=1;
    designDataGrp.RowSpan=[dlgRow,dlgRow];








    if~(bdIsSubsystem(h.Handle))&&~(h.isLibrary)&&slfeature('ShowExternalDataNode')>1
        rowNum=rowNum+1;
        extdataSourceSelectDesc.Name=DAStudio.message('Simulink:dialog:ModelAdditionalSources');

        extdataSourceSelectDesc.Type='text';
        extdataSourceSelectDesc.WordWrap=true;

        extdataSourceSelectDesc.RowSpan=[rowNum,rowNum];
        extdataSourceSelectDesc.ColSpan=[1,4];
        extdataSourceSelectDesc.PreferredSize=[150,-1];

        rowNum=rowNum+1;
        extSourcesName.Name='';
        extSourcesName.Type='edit';
        extSourcesName.Tag='extSourcesName';
        extSourcesName.RowSpan=[rowNum,rowNum];
        extSourcesName.ColSpan=[1,1];
        extSourcesName.Visible=false;

        extSourcesList.Type='listbox';
        extSourcesList.Tag='extSourcesList';
        extSourcesList.RowSpan=[rowNum,rowNum+4];
        extSourcesList.ColSpan=[1,2];
        sources=get_param(h.name,'ExternalSources');
        ddIdx=find(strcmp(sources,h.DataDictionary));
        if ddIdx>0
            sources(ddIdx)='';
        end
        extSourcesList.Entries=sources;
        extSourcesList.UserData=extSourcesList.Entries;
        extSourcesList.MatlabMethod='modelddg_cb';
        extSourcesList.MatlabArgs={'%dialog','%tag',h};

        extSourcesBrowse.Name=DAStudio.message('Simulink:dialog:ModelSelectDDBtn');
        extSourcesBrowse.Type='pushbutton';
        extSourcesBrowse.Tag='extSourcesBrowse';
        extSourcesBrowse.RowSpan=[rowNum,rowNum];
        extSourcesBrowse.ColSpan=[3,3];
        extSourcesBrowse.MatlabMethod='modelddg_cb';
        extSourcesBrowse.MatlabArgs={'%dialog','%tag',h,extSourcesList.Tag,extSourcesName.Tag};

        rowNum=rowNum+1;

        extSourcesNew.Name=DAStudio.message('Simulink:dialog:ModelNewDDBtn');
        extSourcesNew.Type='pushbutton';
        extSourcesNew.Tag='extSourcesNew';
        extSourcesNew.RowSpan=[rowNum,rowNum];
        extSourcesNew.ColSpan=[3,3];
        extSourcesNew.MatlabMethod='modelddg_cb';
        extSourcesNew.MatlabArgs={'%dialog','%tag',h,extSourcesList.Tag,extSourcesName.Tag};

        rowNum=rowNum+1;

        extSourcesRemove.MatlabMethod='modelddg_cb';
        extSourcesRemove.MatlabArgs={'%dialog','%tag',h};
        extSourcesRemove.Name=DAStudio.message('Simulink:dialog:RemoveButton');
        extSourcesRemove.Type='pushbutton';
        extSourcesRemove.Tag='extSourcesRemove';
        extSourcesRemove.RowSpan=[rowNum,rowNum];
        extSourcesRemove.ColSpan=[3,3];
        extSourcesRemove.MatlabMethod='modelddg_cb';
        extSourcesRemove.MatlabArgs={'%dialog','%tag',h,extSourcesList.Tag};
        extSourcesRemove.Enabled=false;

        rowNum=rowNum+1;

        extSourcesOpen.Name=DAStudio.message('Simulink:dialog:ModelOpenDDBtn');
        extSourcesOpen.Type='pushbutton';
        extSourcesOpen.Tag='extSourcesOpen';
        extSourcesOpen.RowSpan=[rowNum,rowNum];
        extSourcesOpen.ColSpan=[3,3];
        extSourcesOpen.MatlabMethod='modelddg_cb';
        extSourcesOpen.MatlabArgs={'%dialog','%tag',h,extSourcesList.Tag};
        extSourcesOpen.Enabled=false;

        designDataGrp.Items=[designDataGrp.Items,{extdataSourceSelectDesc,extSourcesName,extSourcesList,extSourcesBrowse,extSourcesNew,extSourcesRemove,extSourcesOpen}];
    end

    if h.isLibrary&&slfeature('SLLibrarySLDD')==0

        dlgItems={};
    else
        dlgItems={designDataGrp};
        if slfeature('SLDataDictionaryDataScopeSimSystemOfSystems')==2
            dlgItems{end+1}=encapMdl;
        end
    end

    rows=dlgRow;
    cols=5;
end



