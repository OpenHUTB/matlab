function dlgStruct=getSoftwareNodeDialogSchema(h,name)%#ok




    if isa(h,'DAStudio.DAObjectProxy')
        obj=h.getMCOSObjectReference();
    elseif isa(h,'Simulink.DistributedTarget.SoftwareNode')
        obj=h;
    end



    isReadOnly=false;

    descGroup.Name=DAStudio.message('Simulink:taskEditor:PropertiesGroupText');
    descGroup.Type='group';
    descGroup.Items={};

    swNodeNameEdit.Name=DAStudio.message('Simulink:taskEditor:NameText');
    swNodeNameEdit.Type='edit';
    swNodeNameEdit.ObjectProperty='Name';
    swNodeNameEdit.Source=h;
    swNodeNameEdit.Tag='swNodeNameEdit_tag';
    descGroup.Items{end+1}=swNodeNameEdit;





    title=[DAStudio.message('Simulink:taskEditor:SoftwareNodeTitleText'),' ',h.Name];

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
