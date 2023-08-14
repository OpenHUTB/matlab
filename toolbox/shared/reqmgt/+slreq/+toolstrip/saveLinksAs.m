function saveLinksAs(cbinfo)


    appName='requirementsEditorApp';
    acm=cbinfo.studio.App.getAppContextManager;
    [~,canvasModelHandle]=slreq.toolstrip.getModelHandle(cbinfo);

    context=acm.getCustomContext(appName);
    if isa(context,'slreq.toolstrip.ReqEditorAppContext')
        destinationPath=rmimap.StorageMapper.getInstance.promptForReqFile(canvasModelHandle,false);
        if~isempty(destinationPath)
            rmidata.export(canvasModelHandle,true,destinationPath);


            context.isInternalLinkStorage=false;
        end
    end
end
