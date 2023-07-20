function[dlgItems,rows,cols]=modelddg_externaldata(h,showDescription)






























    dataMigrationBtn.Tag='DataMigrationBtn';
    extSourcesList.Tag='extSourcesList';
    extSourcesName.Tag='extSourcesName';

    ddProperty=h.DataDictionary;

    rowNum=1;

    if showDescription
        dataSourceSelectDesc.Name=DAStudio.message('Simulink:dialog:ModelDataSourceSelectDesc1');
        dataSourceSelectDesc.ToolTip=DAStudio.message('Simulink:dialog:ModelDataSourceSelectDesc1');
        dataSourceSelectDesc.Type='text';
        dataSourceSelectDesc.WordWrap=true;
        dataSourceSelectDesc.RowSpan=[rowNum,rowNum];
        dataSourceSelectDesc.ColSpan=[1,5];

        dataSourceSelectDesc.Tag='dataSourceSelectDesc';

        rowNum=rowNum+1;
    end

    rowNum=rowNum+1;

    enforceDataConsistency.Name=DAStudio.message('Simulink:dialog:EnforceDataConsistency');
    enforceDataConsistency.Tag='EnforceDataConsistency';
    enforceDataConsistency.ColSpan=[1,5];
    enforceDataConsistency.RowSpan=[rowNum,rowNum];
    enforceDataConsistency.Type='checkbox';
    enforceDataConsistency.Value=strcmp(get_param(h.name,'EnforceDataConsistency'),'on');
    enforceDataConsistency.ToolTip=DAStudio.message('Simulink:dialog:EnforceDataConsistencyTooltip');

    enforceDataConsistency.MatlabMethod='Simulink.enforceDataConsistencyCallback';
    enforceDataConsistency.MatlabArgs={'%dialog',h,'%value'};
    if slfeature('SlDataEnableDataConsistencyCheck')<2
        enforceDataConsistency.Visible=false;
    end

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


    enableBWSAccess.MatlabMethod='modelddg_externaldata_cb';
    enableBWSAccess.MatlabArgs={'%dialog','doSetEnableBWS',h,extSourcesName.Tag,extSourcesList.Tag,'%value'};

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

    rowNum=rowNum+1;

    dataSourceSelect.Type='text';
    dataSourceSelect.Name=DAStudio.message('sl_data_adapter:messages:DataSources');
    dataSourceSelect.Value=1;
    dataSourceSelect.RowSpan=[rowNum,rowNum];
    dataSourceSelect.ColSpan=[1,1];

    extSourcesName.Name='';
    extSourcesName.Type='edit';
    extSourcesName.RowSpan=[rowNum,rowNum];
    extSourcesName.ColSpan=[1,1];
    extSourcesName.Visible=false;

    rowNum=rowNum+1;

    pbSelectDD.Name=DAStudio.message('Simulink:dialog:ModelSelectDDBtn');
    pbSelectDD.Type='pushbutton';
    pbSelectDD.RowSpan=[rowNum,rowNum];
    pbSelectDD.ColSpan=[1,1];
    pbSelectDD.ToolTip=DAStudio.message('Simulink:dialog:ModelSelectDDTooltip');
    pbSelectDD.Tag='SelectDD';
    pbSelectDD.MatlabMethod='modelddg_externaldata_cb';
    pbSelectDD.MatlabArgs={'%dialog','doSelectDD',h,extSourcesName.Tag,extSourcesList.Tag};

    pbNewDD.Name=DAStudio.message('Simulink:dialog:ModelNewDDBtn');
    pbNewDD.Type='pushbutton';
    pbNewDD.RowSpan=[rowNum,rowNum];
    pbNewDD.ColSpan=[2,2];
    pbNewDD.ToolTip=DAStudio.message('Simulink:dialog:ModelNewDDTooltip');
    pbNewDD.Tag='NewDD';
    pbNewDD.MatlabMethod='modelddg_externaldata_cb';
    pbNewDD.MatlabArgs={'%dialog','doNewDD',h,extSourcesName.Tag,extSourcesList.Tag};

    extSourcesRemove.Name=DAStudio.message('Simulink:dialog:RemoveButton');
    extSourcesRemove.Type='pushbutton';
    extSourcesRemove.Tag='extSourcesRemove';
    extSourcesRemove.RowSpan=[rowNum,rowNum];
    extSourcesRemove.ColSpan=[3,3];
    extSourcesRemove.MatlabMethod='modelddg_externaldata_cb';
    extSourcesRemove.MatlabArgs={'%dialog','doRemoveDD',h,extSourcesName.Tag,extSourcesList.Tag};
    extSourcesRemove.Enabled=false;

    rowNum=rowNum+1;
    extSourcesList.Type='listbox';
    extSourcesList.RowSpan=[rowNum,rowNum+3];
    extSourcesList.ColSpan=[1,3];
    sources=get_param(h.name,'ExternalSources');
    ddIdx=any(find(strcmp(sources,h.DataDictionary)));
    if(ddIdx==0)&&~isempty(h.DataDictionary)
        sources{end+1}=h.DataDictionary;
    end
    extSourcesList.Entries=sources;
    extSourcesList.UserData=extSourcesList.Entries;
    extSourcesList.MatlabMethod='modelddg_externaldata_cb';
    extSourcesList.MatlabArgs={'%dialog','doSelectExtSource',h,extSourcesName.Tag,...
    extSourcesList.Tag,dataMigrationBtn.Tag,extSourcesRemove.Tag};




    rowNum=rowNum+3;


    rowNum=rowNum+1;

    dataMigrationBtn.Type='pushbutton';
    dataMigrationBtn.Name=DAStudio.message('Simulink:dialog:MigrateDataButton');
    dataMigrationBtn.ToolTip=DAStudio.message('Simulink:dialog:MigrateDataButtonTooltip');
    dataMigrationBtn.RowSpan=[rowNum,rowNum];
    dataMigrationBtn.ColSpan=[1,1];
    dataMigrationBtn.Visible=(hasBWSAccess||ddHasBWSAccess);
    dataMigrationBtn.Enabled=false;
    dataMigrationBtn.MatlabMethod='modelddg_cb';
    dataMigrationBtn.MatlabArgs={'%dialog',dataMigrationBtn.Tag,h};



    rowNum=rowNum+1;
    dataDictionaryEdit.Type='edit';
    dataDictionaryEdit.Tag='DataDictionary';
    dataDictionaryEdit.Value=h.DataDictionary';
    dataDictionaryEdit.RowSpan=[rowNum,rowNum];
    dataDictionaryEdit.ColSpan=[1,1];
    dataDictionaryEdit.Visible=false;


    designDataGrp.Name=DAStudio.message('Simulink:dialog:ModelDesignDataGroupName');
    designDataGrp.Type='panel';
    designDataGrp.ColStretch=[0,0,0,0,1];
    designDataGrp.Items={};
    if showDescription
        designDataGrp.Items={dataSourceSelectDesc};
    else
        designDataGrp.Alignment=2;
    end
    designDataGrp.LayoutGrid=[7,5];
    designDataGrp.LayoutGrid=[9,5];

    designDataGrp.Items=[designDataGrp.Items,...
    enableBWSAccess,...
    ddAccessBWS,...
    enforceDataConsistency,...
    dataSourceSelect,...
    pbSelectDD,...
    pbNewDD,...
    extSourcesRemove,...
    extSourcesList,...
    dataMigrationBtn,...
    dataDictionaryEdit,...
    extSourcesName,...
    ];

    dlgRow=1;
    designDataGrp.RowSpan=[dlgRow,dlgRow];
    dlgItems={designDataGrp};
    rows=dlgRow;
    cols=5;

end



