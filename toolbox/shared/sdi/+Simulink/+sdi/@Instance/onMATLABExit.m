function onMATLABExit()

    Simulink.sdi.Instance.close();
    gui=Simulink.sdi.Instance.getSetOffscreenBrowser();
    if~isempty(gui)
        delete(gui);
        Simulink.sdi.Instance.getSetOffscreenBrowser([]);
    end


    obj=Simulink.sdi.internal.ConnectorAPI.getAPI();
    delete(obj);


    interface=Simulink.sdi.internal.Framework.getFramework();
    interface.unregisterEnginePlugins();


    eng=Simulink.sdi.Instance.getSetEngine();
    if~isempty(eng)
        onMATLABExit(eng);
    end
end
