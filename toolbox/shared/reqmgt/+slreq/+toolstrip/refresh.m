

function refresh(cbinfo)


    appName='requirementsEditorApp';
    acm=cbinfo.studio.App.getAppContextManager;

    context=acm.getCustomContext(appName);
    if isa(context,'slreq.toolstrip.ReqEditorAppContext')
        context.MyTriggerProperty=~context.MyTriggerProperty;
    end
end
