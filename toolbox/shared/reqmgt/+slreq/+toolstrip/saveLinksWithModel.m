function saveLinksWithModel(cbinfo)

    appName='requirementsEditorApp';
    acm=cbinfo.studio.App.getAppContextManager;
    [~,canvasModelHandle]=slreq.toolstrip.getModelHandle(cbinfo);
    context=acm.getCustomContext(appName);
    if isa(context,'slreq.toolstrip.ReqEditorAppContext')
        rmidata.embed(canvasModelHandle);
        rmisl.notify(canvasModelHandle,'');

        context.isInternalLinkStorage=true;
    end
end
