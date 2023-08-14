


function dlg=getDialogSchema(obj)

    cr=simulinkcoder.internal.Report.getInstance();
    codeUrl=cr.getUrl();
    debugMode=slci.view.Manager.getInstance.getDebugMode;


    codeWebWindow.Type='webbrowser';
    codeWebWindow.Tag=obj.tag;
    codeWebWindow.Url=codeUrl;
    codeWebWindow.HomeURL='https://www.mathworks.com/products/simulink-code-inspector.html';
    codeWebWindow.EnableInspectorInContextMenu=debugMode;
    codeWebWindow.EnableInspectorOnLoad=false;
    codeWebWindow.EnableJsOnClipboard=true;
    codeWebWindow.DisableContextMenu=~debugMode;
    codeWebWindow.RowSpan=[1,1];
    codeWebWindow.ColSpan=[1,1];


    dlg.DialogTitle='';
    dlg.LayoutGrid=[1,1];
    dlg.ColStretch=[0];%#ok
    dlg.StandaloneButtonSet={''};
    dlg.EmbeddedButtonSet={''};
    dlg.Items={codeWebWindow};
end