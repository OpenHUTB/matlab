function dlgStruct=getPeriodicDialogSchema(h,name)%#ok




    if ismethod(h,'getMCOSObjectReference')
        obj=h.getMCOSObjectReference();
    else
        obj=h;
    end

    isReadOnly=DeploymentDiagram.isTaskConfigurationInUse(obj);

    descGroup.Name=DAStudio.message('Simulink:taskEditor:PropertiesGroupText');
    descGroup.Type='group';


    widgetLbl.Name=DAStudio.message('Simulink:taskEditor:NameText');
    widgetLbl.Type='text';
    widget.Name='';
    widget.Type='edit';
    widget.ObjectProperty='Name';
    widget.Source=obj;
    widget.Tag='pTaskGName_tag';
    widgetLbl.Buddy=widget.Tag;
    widget.WidgetId='pTaskGName_tag';


    periodTxt.Name=DAStudio.message('Simulink:taskEditor:PeriodText');
    periodTxt.Type='text';

    periodPEdit.Name='';
    periodPEdit.Type='edit';
    periodPEdit.ObjectProperty='Period';
    periodPEdit.Source=h;
    periodPEdit.Tag='triggerPeriod_tag';
    periodTxt.Buddy=periodPEdit.Tag;


    explorer=DeploymentDiagram.getexplorer('name',obj.ParentDiagram);

    ehColorLabel.Name=DAStudio.message('Simulink:taskEditor:ColorText');
    ehColorLabel.Type='text';
    ehColorLabel.Enabled=1;
    ehColorLabel.Tag='ehColorLabel_tag';
    ehColorLabel.Buddy=ehColorLabel.Tag;
    ehColorButton.Name='';
    ehColorButton.Type='pushbutton';
    ehColorButton.Enabled=true;
    ehColorButton.Tag='colorButton';
    ehColorButton.MatlabMethod='DeploymentDiagram.colorUtil';
    ehColorButton.MatlabArgs={'openColorDlg',obj,explorer};
    ehColorButton.DialogRefresh=1;
    ehColorButton.MinimumSize=[37,26];
    ehColorButton.MaximumSize=[37,26];
    ehColorButton.FilePath=...
    DeploymentDiagram.colorUtil('getIconPath');
    ehColorButton.BackgroundColor=255*(obj.Color);

    [indexedItems,layout]=...
    slprivate('getIndexedGroupItems',2,{...
    widgetLbl,widget,...
    periodTxt,periodPEdit,...
    ehColorLabel,ehColorButton});

    descGroup.Items=indexedItems;
    descGroup.LayoutGrid=layout;




    title=[DAStudio.message('Simulink:taskEditor:PeriodicTaskGroupTitleText'),' ',obj.Name];
    dlgStruct.DialogTitle=title;
    dlgStruct.DisableDialog=isReadOnly;
    dlgStruct.LayoutGrid=[2,1];
    dlgStruct.RowStretch=[0,1];
    dlgStruct.ColStretch=[1];%#ok
    dlgStruct.Source=obj;
    dlgStruct.HelpMethod='helpview';
    mapId=['mapkey:',class(h)];
    dlgStruct.HelpArgs={mapId,'help_button','CSHelpWindow'};

    custompanel.Name='';
    custompanel.Type='panel';

    dlgStruct.Items=[[{descGroup}...
    ,DeploymentDiagram.getCodeGenerationSubSchema(obj)]...
    ,custompanel];

    rows=length(dlgStruct.Items);
    dlgStruct.LayoutGrid=[rows+1,1];
    dlgStruct.RowStretch=[zeros(1,rows),1];

end

