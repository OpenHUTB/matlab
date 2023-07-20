function refreshReqsBrowser(cbinfo,action)



    appName='requirementsEditorApp';
    acm=cbinfo.studio.App.getAppContextManager;


    modelH=slreq.toolstrip.getModelHandle(cbinfo);

    context=acm.getCustomContext(appName);
    if isa(context,'slreq.toolstrip.ReqEditorAppContext')
        appmgr=slreq.app.MainManager.getInstance();
        if~isempty(appmgr.spreadsheetManager)
            spObj=appmgr.spreadsheetManager.getSpreadSheetObject(modelH);
            if~isempty(spObj)
                action.selected=spObj.isComponentVisible;
            end
        end
    end
end