function dlg=getDialogSchema(obj)

    main.Type='webbrowser';
    main.Name=obj.title;
    main.Tag=obj.tag;
    main.DialogRefresh=false;
    main.Graphical=true;
    main.Url=obj.generateUrl();

    if obj.debugMode
        main.DisableContextMenu=false;
        main.EnableInspectorInContextMenu=true;
        main.EnableInspectorOnLoad=true;
    else
        main.DisableContextMenu=true;
    end

    dlg.DialogTitle='';
    dlg.Items={main};
    dlg.DialogMode='Slim';
    dlg.StandaloneButtonSet={''};
    dlg.EmbeddedButtonSet={''};
    dlg.DialogTag=[obj.tag,'_Dialog'];

    dlg.IsScrollable=false;