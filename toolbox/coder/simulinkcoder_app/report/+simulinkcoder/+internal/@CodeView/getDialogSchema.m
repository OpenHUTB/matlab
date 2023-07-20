function dlgStruct=getDialogSchema(obj)



    inner=obj.getCodeSchema();
    dlgStruct.Items={inner};



    cr=simulinkcoder.internal.Report.getInstance;

    dlgStruct.DialogTitle='';
    dlgStruct.DialogMode='Slim';
    dlgStruct.StandaloneButtonSet={''};
    dlgStruct.EmbeddedButtonSet={''};
    dlgStruct.DialogTag=[cr.tag,'_Dialog'];
    dlgStruct.IsScrollable=false;

    if isempty(obj.studio)
        dlgStruct.Geometry=[100,100,800,800];
    end

