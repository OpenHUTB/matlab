function initControllers(this)
    if~this.ControllersInitialized||Simulink.sdi.internal.ConnectorAPI.getSetHaveControllersBeenRemoved()
        this.ControllersInitialized=true;
        Simulink.HMI.initStreamingSubscribers();
        Simulink.HMI.initializeWebClient();
        dispatcherObj=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher();
        Simulink.sdi.internal.controllers.ImportDialog.getController(dispatcherObj);
        Simulink.sdi.internal.controllers.RunConfigDialog.getController(dispatcherObj);
        Simulink.sdi.internal.controllers.UnifiedPreferencesDialog.getController(dispatcherObj);
        Simulink.sdi.internal.controllers.ReportDialog.getController(dispatcherObj);
        Simulink.sdi.internal.controllers.ExportDialog.getController(dispatcherObj);
        Simulink.sdi.internal.controllers.SessionSaveLoad.getController();
        Simulink.sdi.internal.controllers.Slicer.getController(dispatcherObj);
        this.EventListeners=...
        Simulink.sdi.internal.PrototypeTable.initializeEventListeners;

        Simulink.sdi.internal.ConnectorAPI.getSetHaveControllersBeenRemoved(false);
    end
end
