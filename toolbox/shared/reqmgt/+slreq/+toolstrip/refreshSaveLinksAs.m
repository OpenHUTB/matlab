function refreshSaveLinksAs(cbinfo,action)



    appName='requirementsEditorApp';
    acm=cbinfo.studio.App.getAppContextManager;
    [~,modelH]=slreq.toolstrip.getModelHandle(cbinfo);

    context=acm.getCustomContext(appName);
    if isa(context,'slreq.toolstrip.ReqEditorAppContext')
        modelName=get_param(modelH,'Name');
        dataLinkSet=slreq.utils.getLinkSet(modelName);
        if isempty(dataLinkSet)

            action.text=getString(message('Slvnv:reqmgt:toolstrip:SaveLinksAsReqEditorActionText'));
            action.enabled=0;
        elseif slreq.utils.isEmbeddedLinkSet(dataLinkSet)

            action.text=getString(message('Slvnv:reqmgt:toolstrip:SaveLinksAsLinkeSetReqEditorActionText'));
            action.enabled=1;
        else

            action.text=getString(message('Slvnv:reqmgt:toolstrip:SaveLinksAsReqEditorActionText'));
            action.enabled=1;
        end
    end
end