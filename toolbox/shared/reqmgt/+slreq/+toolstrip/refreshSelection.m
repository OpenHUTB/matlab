

function refreshSelection(cbinfo,action)


    appName='requirementsEditorApp';
    acm=cbinfo.studio.App.getAppContextManager;





















    context=acm.getCustomContext(appName);
    if isa(context,'slreq.toolstrip.ReqEditorAppContext')

        if strcmp(action.name,'saveReqSetAsReqEditorAction')
            action.enabled=context.isReqSetSelected;
        end
    end

end
