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
    dlg.StandaloneButtonSet={''};
    dlg.EmbeddedButtonSet={''};
    dlg.ExplicitShow=true;
    dlg.DialogTag=[obj.tag,'_Dialog'];

    if~obj.debugMode
        dlg.DialogStyle='frameless';
        dlg.Transient=true;
    end

    src=obj.src;
    editor=src.editor;
    if isempty(editor)
        dlg.Geometry=[100,100,800,600];
    else
        dlg.Geometry=editor.getCanvas.GlobalPosition;
    end

    dlg.CloseMethod='onClose';
    dlg.CloseMethodArgs={};
    dlg.CloseMethodArgsDT={};

