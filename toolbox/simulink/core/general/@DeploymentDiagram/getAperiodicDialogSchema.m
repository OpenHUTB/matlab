function dlgStruct=getAperiodicDialogSchema(h,name)%#ok




    if ismethod(h,'getMCOSObjectReference')
        obj=h.getMCOSObjectReference();
    else
        obj=h;
    end

    isAutogenTrigger=isa(obj,'Simulink.SoftwareTarget.AutogenTrigger');



    isReadOnly=isAutogenTrigger||...
    DeploymentDiagram.isTaskConfigurationInUse(obj);

    title=[DAStudio.message('Simulink:taskEditor:AperiodicTaskGroupTitleText'),' ',obj.Name];
    dlgStruct.DialogTitle=title;
    dlgStruct.DisableDialog=isReadOnly;
    dlgStruct.HelpMethod='helpview';
    mapId=['mapkey:',class(h)];
    dlgStruct.HelpArgs={mapId,'help_button','CSHelpWindow'};

    propGroup.Name=DAStudio.message('Simulink:taskEditor:PropertiesGroupText');
    propGroup.Type='group';
    propGroup.Items={};


    widgetLbl.Name=DAStudio.message('Simulink:taskEditor:NameText');
    widgetLbl.Type='text';
    widget.Type='edit';
    widget.ObjectProperty='Name';
    widget.Tag='Name_tag';
    widget.Source=obj;
    widgetLbl.Buddy=widget.Tag;
    propGroup.Items{end+1}=widget;


    explorer=DeploymentDiagram.getexplorer('name',obj.ParentDiagram);

    aehColorLabel.Name=DAStudio.message('Simulink:taskEditor:ColorText');
    aehColorLabel.Type='text';
    aehColorLabel.Enabled=1;
    aehColorLabel.Tag='aehColorLabel_tag';
    aehColorLabel.Buddy=aehColorLabel.Tag;
    aehColorButton.Name='';
    aehColorButton.Type='pushbutton';
    aehColorButton.Enabled=true;
    aehColorButton.Tag='colorButton';
    aehColorButton.MatlabMethod='DeploymentDiagram.colorUtil';
    aehColorButton.MatlabArgs={'openColorDlg',obj,explorer};
    aehColorButton.DialogRefresh=1;
    aehColorButton.MinimumSize=[37,26];
    aehColorButton.MaximumSize=[37,26];
    aehColorButton.FilePath=...
    DeploymentDiagram.colorUtil('getIconPath');
    aehColorButton.BackgroundColor=255*(obj.Color);

    [indexedItems,layout]=...
    slprivate('getIndexedGroupItems',2,{...
    widgetLbl,widget,...
    aehColorLabel,aehColorButton});

    propGroup.Items=indexedItems;
    propGroup.LayoutGrid=layout;

    custompanel.Name='';
    custompanel.Type='panel';

    dlgStruct.Items=[[{propGroup}...
    ,DeploymentDiagram.getCodeGenerationSubSchema(obj)]...
    ,custompanel];

    rows=length(dlgStruct.Items);
    dlgStruct.LayoutGrid=[rows+1,1];
    dlgStruct.RowStretch=[zeros(1,rows),1];

end
