function dlgStruct=getComponentSimpleDialogSchema(cc)



    name=cc.Name;
    w.Type='textbrowser';
    w.Text=message('configset:dialog:ConfigSetComponentDDGText',name).getString();
    dlgStruct.Items={w};
    dlgStruct.DialogTitle=name;
    dlgStruct.StandaloneButtonSet={''};
    dlgStruct.EmbeddedButtonSet={''};

