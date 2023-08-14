function dlgStruct=getArchitectureDialogSchema(h,name)%#ok




    descGroup.Name=DAStudio.message('Simulink:taskEditor:PropertiesGroupText');
    descGroup.Type='group';
    descGroup.Items={};

    archNameEdit.Name=DAStudio.message('Simulink:taskEditor:NameText');
    archNameEdit.Type='edit';
    archNameEdit.ObjectProperty='Name';
    archNameEdit.Source=h;
    archNameEdit.Tag='archNameEdit_tag';
    descGroup.Items{end+1}=archNameEdit;





    title=[DAStudio.message('Simulink:taskEditor:ArchitectureTitleText'),' ',h.Name];
    dlgStruct.DialogTitle=title;
    dlgStruct.Items={descGroup};
    dlgStruct.LayoutGrid=[2,1];
    dlgStruct.RowStretch=[0,1];
    dlgStruct.ColStretch=[1];%#ok
    dlgStruct.Source=h;
    dlgStruct.HelpMethod='helpview';
    mapId=['mapkey:',class(h)];
    dlgStruct.HelpArgs={mapId,'help_button','CSHelpWindow'};
