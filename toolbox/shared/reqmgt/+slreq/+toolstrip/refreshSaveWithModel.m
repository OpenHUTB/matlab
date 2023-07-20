function refreshSaveWithModel(cbinfo,action)



    appName='requirementsEditorApp';
    acm=cbinfo.studio.App.getAppContextManager;
    [~,modelH]=slreq.toolstrip.getModelHandle(cbinfo);

    context=acm.getCustomContext(appName);
    if isa(context,'slreq.toolstrip.ReqEditorAppContext')
        modelName=get_param(modelH,'Name');
        dataLinkSet=slreq.utils.getLinkSet(modelName);
        if isempty(dataLinkSet)
            action.enabled=0;
        elseif slreq.utils.isEmbeddedLinkSet(dataLinkSet)

            action.enabled=0;
        else
            action.enabled=1;
        end
    end
end