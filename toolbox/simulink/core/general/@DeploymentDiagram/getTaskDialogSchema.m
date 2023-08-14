function dlgStruct=getTaskDialogSchema(h,name)%#ok




    if(isa(h,'Simulink.SoftwareTarget.Task')||...
        isa(h,'Simulink.SoftwareTarget.AutogenTask'))
        obj=h;
    elseif isa(h,"DAStudio.DAObjectProxy")
        obj=h.getMCOSObjectReference();
    else
        obj=h;
    end
    isAutogenTask=isa(obj,'Simulink.SoftwareTarget.AutogenTask');
    isPeriodic=true;
    if~isAutogenTask
        parentTrigger=obj.ParentTaskGroup;
        isPeriodic=isa(parentTrigger,'Simulink.SoftwareTarget.PeriodicTrigger');
    end
    isReadOnly=isAutogenTask||DeploymentDiagram.isTaskConfigurationInUse(h);

    descGroup.Name=DAStudio.message('Simulink:taskEditor:PropertiesGroupText');
    descGroup.Type='group';


    taskEditTxt.Name=DAStudio.message('Simulink:taskEditor:NameText');
    taskEditTxt.Type='text';


    taskEdit.Name='';
    taskEdit.Type='edit';
    taskEdit.ObjectProperty='Name';
    taskEdit.Source=h;
    taskEdit.Tag='taskName_tag';
    taskEditTxt.Buddy=taskEdit.Tag;


    taskPeriodTxt.Name=DAStudio.message('Simulink:taskEditor:PeriodText');
    taskPeriodTxt.Type='text';
    taskPeriodTxt.Visible=isPeriodic;

    taskPeriodPEdit.Name='';
    taskPeriodPEdit.Type='edit';
    taskPeriodPEdit.ObjectProperty='Period';
    taskPeriodPEdit.Source=h;
    taskPeriodPEdit.Tag='taskPeriod_tag';
    taskPeriodPEdit.Visible=isPeriodic;
    taskPeriodTxt.Buddy=taskPeriodPEdit.Tag;



    taskColorLabel.Name=DAStudio.message('Simulink:taskEditor:ColorText');
    taskColorLabel.Type='text';
    taskColorLabel.Enabled=1;
    taskColorLabel.Tag='taskColorLabel_tag';
    taskColorLabel.Buddy=taskColorLabel.Tag;

    explorer=DeploymentDiagram.getexplorer('name',obj.ParentDiagram);
    taskColorButton.Name='';
    taskColorButton.Type='pushbutton';
    taskColorButton.Enabled=true;
    taskColorButton.Tag='colorButton';
    taskColorButton.MatlabMethod='DeploymentDiagram.colorUtil';
    taskColorButton.MatlabArgs={'openColorDlg',obj,explorer};
    taskColorButton.DialogRefresh=1;
    taskColorButton.MinimumSize=[37,26];
    taskColorButton.MaximumSize=[37,26];
    taskColorButton.FilePath=...
    DeploymentDiagram.colorUtil('getIconPath');
    taskColorButton.BackgroundColor=255*(h.Color);

    [indexedItems,layout]=...
    slprivate('getIndexedGroupItems',2,{...
    taskEditTxt,taskEdit,...
    taskPeriodTxt,taskPeriodPEdit,...
    taskColorLabel,taskColorButton});
    descGroup.Items=indexedItems;
    descGroup.LayoutGrid=layout;




    title=[DAStudio.message('Simulink:taskEditor:TaskTitleText'),' ',h.Name];

    items=[{descGroup}...
    ,DeploymentDiagram.getCodeGenerationSubSchema(obj)];

    [indexedItems,layout]=...
    slprivate('getIndexedGroupItems',1,items);

    dlgStruct.DialogTitle=title;
    dlgStruct.Items=indexedItems;
    dlgStruct.DisableDialog=isReadOnly;
    dlgStruct.LayoutGrid=layout;
    dlgStruct.RowStretch=[zeros(1,length(items)),1];
    dlgStruct.ColStretch=1;
    dlgStruct.Source=h;
    dlgStruct.HelpMethod='helpview';
    mapId=['mapkey:',class(h)];
    dlgStruct.HelpArgs={mapId,'help_button','CSHelpWindow'};

