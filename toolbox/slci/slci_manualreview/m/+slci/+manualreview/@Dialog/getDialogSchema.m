

function dlgStruct=getDialogSchema(obj,~)

    url=obj.getUrl();
    debugMode=slci.manualreview.Manager.getInstance.getDebugMode;

    main.Type='webbrowser';
    main.Tag=obj.tag;
    main.Url=connector.getUrl(url);
    main.HomeURL='https://www.mathworks.com/products/simulink-code-inspector.html';
    main.EnableInspectorInContextMenu=debugMode;
    main.EnableInspectorOnLoad=false;
    main.EnableJsOnClipboard=true;
    main.DisableContextMenu=~debugMode;
    main.RowSpan=[1,1];
    main.ColSpan=[1,1];


    dlgStruct.DialogTitle='';
    dlgStruct.LayoutGrid=[1,1];
    dlgStruct.ColStretch=[0];%#ok
    dlgStruct.StandaloneButtonSet={''};
    dlgStruct.EmbeddedButtonSet={''};
    dlgStruct.Items={main};
    dlgStruct.IsScrollable=false;

end