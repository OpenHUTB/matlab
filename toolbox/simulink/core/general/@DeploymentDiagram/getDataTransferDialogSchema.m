function dlgStruct=getDataTransferDialogSchema(h,~)












    defSyncTxt.Name=DAStudio.message('Simulink:taskEditor:DataTransferOptionsPeriodic');
    defSyncTxt.Type='text';
    defSyncTxt.Tag='DefaultTransitionBetweenSyncTasks_txt_tag';
    defSyncTxt.Buddy=defSyncTxt.Tag;
    defSyncTxt.Enabled=strcmp(get_param(h.ParentDiagram,'ExplicitPartitioning'),'on');

    defSyncCmb.Name='';
    defSyncCmb.Type='combobox';
    defSyncCmb.Tag='DefaultTransitionBetweenSyncTasks_tag';
    defSyncCmb.Entries={'Ensure data integrity only',...
    'Ensure deterministic transfer (maximum delay)',...
    'Ensure deterministic transfer (minimum delay)'};
    defSyncCmb.Enabled=defSyncTxt.Enabled;
    defSyncCmb.ObjectProperty='DefaultTransitionBetweenSyncTasks';
    defSyncCmb.Source=h;
    defSyncTxt.Buddy=defSyncCmb.Tag;



    defContTxt.Name=DAStudio.message('Simulink:taskEditor:DataTransferOptionsContinuous');
    defContTxt.Type='text';
    defContTxt.Tag='DefaultTransitionBetweenContTasks_txt_tag';
    defContTxt.Enabled=strcmp(get_param(h.ParentDiagram,'ExplicitPartitioning'),'on');

    defContCmb.Name='';
    defContCmb.Type='combobox';
    defContCmb.Tag='DefaultTransitionBetweenContTasks_tag';
    defContCmb.Enabled=defContTxt.Enabled;
    defContCmb.Entries={'Ensure data integrity only',...
    'Ensure deterministic transfer (maximum delay)',...
    'Ensure deterministic transfer (minimum delay)'};
    defContCmb.ObjectProperty='DefaultTransitionBetweenContTasks';
    defContCmb.Source=h;
    defContTxt.Buddy=defContCmb.Tag;



    defExtrMethTxt.Name=DAStudio.message('Simulink:taskEditor:DataTransferOptionsExtrapolation');
    defExtrMethTxt.Type='text';
    defExtrMethTxt.Tag='DefaultExtrapolationMethodBetweenContTasks_txt_tag';
    defExtrMethTxt.Enabled=strcmp(get_param(h.ParentDiagram,'ExplicitPartitioning'),'on');


    defExtrMethCmb.Name='';
    defExtrMethCmb.Type='combobox';
    defExtrMethCmb.Tag='DefaultExtrapolationMethodBetweenContTasks_tag';
    defExtrMethCmb.Entries={'None',...
    'Zero Order Hold',...
    'Linear',...
    'Quadratic'};
    defExtrMethCmb.Enabled=defExtrMethTxt.Enabled;
    defExtrMethCmb.ObjectProperty='DefaultExtrapolationMethodBetweenContTasks';
    defExtrMethCmb.Source=h;
    defExtrMethCmb.AutoTranslateStrings=0;
    defExtrMethTxt.Buddy=defExtrMethCmb.Tag;


    [indexedItems,layout]=...
    slprivate('getIndexedGroupItems',2,{...
    defSyncTxt,defSyncCmb,...
    defContTxt,defContCmb,...
    defExtrMethTxt,defExtrMethCmb});

    defaultsGrp.Name=DAStudio.message('Simulink:taskEditor:DataTransferOptionsDefaults');
    defaultsGrp.Type='group';
    defaultsGrp.Items=indexedItems;
    defaultsGrp.LayoutGrid=layout;






    [indexedItems,layout]=...
    slprivate('getIndexedGroupItems',2,{...
    defaultsGrp,'blank'});

    title=DAStudio.message('Simulink:taskEditor:DataTransferOptionsTitle');
    dlgStruct.DialogTitle=title;
    dlgStruct.Items=indexedItems;
    dlgStruct.LayoutGrid=layout;
    dlgStruct.RowStretch=[0,1];
    dlgStruct.ColStretch=[0,1];
    dlgStruct.Source=h;
    dlgStruct.DisableDialog=DeploymentDiagram.isTaskConfigurationInUse(h);
    dlgStruct.HelpMethod='helpview';
    mapId=['mapkey:',class(h)];
    dlgStruct.HelpArgs={mapId,'help_button','CSHelpWindow'};




