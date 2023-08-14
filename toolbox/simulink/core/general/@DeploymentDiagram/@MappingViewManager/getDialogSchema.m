function dlgStruct=getDialogSchema(h,name)%#ok






    button_refreshMapping.Type='pushbutton';
    button_refreshMapping.Name='';
    button_refreshMapping.Tag='button_refreshMapping';
    button_refreshMapping.Enabled=1;
    button_refreshMapping.MatlabMethod='DeploymentDiagram.callbackFunction';
    button_refreshMapping.MatlabArgs={'refreshMapping','%dialog'};
    button_refreshMapping.ToolTip=DAStudio.message('Simulink:taskEditor:RefreshMappingTableToolTip');
    button_refreshMapping.FilePath=DeploymentDiagram.colorUtil('getRefreshIconPath');

    refreshMappingText.Name=...
    DAStudio.message('Simulink:taskEditor:RefreshMappingTableText');
    refreshMappingText.Type='text';



    emptyPanel.Name='';
    emptyPanel.Type='panel';

    [indexedItems,layout]=...
    slprivate('getIndexedGroupItems',3,{...
    refreshMappingText,button_refreshMapping,emptyPanel});

    synthTasksGrp.Name='';
    synthTasksGrp.Type='panel';
    synthTasksGrp.Items=indexedItems;
    synthTasksGrp.LayoutGrid=layout;


    [indexedItems,layout]=...
    slprivate('getIndexedGroupItems',2,{...
    synthTasksGrp,'blank'});


    automaticAnalysisGrp.Name='';
    automaticAnalysisGrp.Type='group';
    automaticAnalysisGrp.Items=indexedItems;
    automaticAnalysisGrp.LayoutGrid=layout;
    automaticAnalysisGrp.RowStretch=[1,0];
    automaticAnalysisGrp.ColStretch=[0,1];

    m=h.Explorer.getRoot;



    title=DAStudio.message('Simulink:taskEditor:TaskandTaskGroupDDGLink');
    dlgStruct.DialogTitle=title;
    dlgStruct.Items={automaticAnalysisGrp};
    dlgStruct.DisableDialog=DeploymentDiagram.isTaskConfigurationInUse(m);
    dlgStruct.Source=h;
    dlgStruct.DialogTag='TaskEditor_Mapping_DDG';
    dlgStruct.LayoutGrid=[1,1];
    dlgStruct.EmbeddedButtonSet={''};

