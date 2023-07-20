function refreshExportWebView(cbinfo,action)



    appName='requirementsEditorApp';
    acm=cbinfo.studio.App.getAppContextManager;

    context=acm.getCustomContext(appName);
    if isa(context,'slreq.toolstrip.ReqEditorAppContext')
        if strcmp(action.name,'generateWebViewReqEditorAction')
            action.enabled=context.isExportWebviewEnabled;
        end
    end
end

