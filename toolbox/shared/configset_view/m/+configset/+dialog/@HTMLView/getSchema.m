function web=getSchema(obj)





    web.Type='webbrowser';
    web.Name='cs';
    web.WebKit=~obj.useCEF();
    web.Tag=obj.Tag;
    web.DialogRefresh=false;
    web.Graphical=true;
    web.Url=obj.getUrl();
    if obj.debugMode
        web.DisableContextMenu=false;
        web.EnableInspectorInContextMenu=true;
        web.EnableInspectorOnLoad=true;
    else
        web.DisableContextMenu=true;
    end
    web.MinimumSize=[400,300];