function code=getCodeSchema(obj)

    url=obj.getUrl;

    cr=simulinkcoder.internal.Report.getInstance;
    tag=cr.tag;


    code.Type='webbrowser';
    code.Tag=tag;
    code.DialogRefresh=false;
    code.Graphical=true;
    code.Url=url;
    code.BackgroundColor=[255,255,255];
    code.KeyShortcutsAcceptPolicy={'All'};

    if cr.debugMode
        code.DisableContextMenu=false;
        code.EnableInspectorInContextMenu=true;
        code.EnableInspectorOnLoad=true;
    else
        code.DisableContextMenu=true;
    end