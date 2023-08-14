function removeControllers(this)
    if this.ControllersInitialized&&connector.isRunning
        this.ControllersInitialized=false;





        if~Simulink.sdi.internal.ConnectorAPI.getSetHaveControllersBeenRemoved()
            impCtrl=Simulink.sdi.internal.controllers.ImportDialog.getController;
            delete(impCtrl);

            rcCtrl=Simulink.sdi.internal.controllers.RunConfigDialog.getController;
            delete(rcCtrl);

            reportCtrl=Simulink.sdi.internal.controllers.ReportDialog.getController;
            delete(reportCtrl);

            exCtrl=Simulink.sdi.internal.controllers.ExportDialog.getController;
            delete(exCtrl);

            Simulink.sdi.internal.PrototypeTable.uninitializeEventListeners(this.EventListeners);

            sslCtrl=Simulink.sdi.internal.controllers.SessionSaveLoad.getController;
            delete(sslCtrl);

            sliceCtrl=Simulink.sdi.internal.controllers.Slicer.getController;
            delete(sliceCtrl);

            Simulink.HMI.uninitStreamingSubscribers();

            dispatcherObj=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher();
            delete(dispatcherObj);

            Simulink.sdi.internal.ConnectorAPI.getSetHaveControllersBeenRemoved(true);
        end
    end
end
