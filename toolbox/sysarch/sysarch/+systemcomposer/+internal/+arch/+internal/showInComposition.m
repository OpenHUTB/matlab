function showInComposition(appName,compToShowUUID)



    app=systemcomposer.internal.arch.load(appName);
    compArchModel=app.getCompositionArchitectureModel;
    compToShow=compArchModel.findElement(compToShowUUID);

    blockHandle=systemcomposer.utils.getSimulinkPeer(compToShow);
    blockParent=get_param(blockHandle,'Parent');
    open_system(blockParent);
    Simulink.scrollToVisible(blockHandle,'ensureFit','on','panMode','minimal');
    set_param(blockHandle,'Selected','On');

end

