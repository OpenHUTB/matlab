


function dlg=getDialogSchema(obj)

    url=obj.getUrl();
    debugMode=slci.view.Manager.getInstance.getDebugMode;


    cwindow.Type='webbrowser';
    cwindow.Tag=obj.tag;
    cwindow.Url=url;
    cwindow.HomeURL='https://www.mathworks.com/products/simulink-code-inspector.html';
    cwindow.EnableInspectorInContextMenu=debugMode;
    cwindow.EnableInspectorOnLoad=false;
    cwindow.EnableJsOnClipboard=true;
    cwindow.DisableContextMenu=~debugMode;
    cwindow.RowSpan=[1,1];
    cwindow.ColSpan=[1,1];


    dlg.DialogTitle='';
    dlg.LayoutGrid=[1,1];
    dlg.ColStretch=[0];%#ok
    dlg.StandaloneButtonSet={''};
    dlg.EmbeddedButtonSet={''};
    dlg.Items={cwindow};
end