function refreshShareDoors(cbinfo,action)



    appName='requirementsEditorApp';
    acm=cbinfo.studio.App.getAppContextManager;

    context=acm.getCustomContext(appName);
    if isa(context,'slreq.toolstrip.ReqEditorAppContext')
        if strcmp(action.name,'synchronizeWithDoorsAction')
            action.enabled=context.isDoorsEnabled;
        end
    end
end

