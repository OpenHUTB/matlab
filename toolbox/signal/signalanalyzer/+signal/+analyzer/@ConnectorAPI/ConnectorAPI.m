classdef ConnectorAPI<Simulink.sdi.internal.ConnectorAPI





    methods(Static)


        function ret=getAPI()

            persistent connectorAPI;
            mlock;
            if isempty(connectorAPI)||~isvalid(connectorAPI)
                connectorAPI=signal.analyzer.ConnectorAPI;
            end


            ret=connectorAPI;
        end


        function enableEventCallback(evtName)
            apiObj=signal.analyzer.ConnectorAPI.getAPI();
            apiObj.setEventCallbackState(evtName,true);
        end


        function disableEventCallback(evtName)
            apiObj=signal.analyzer.ConnectorAPI.getAPI();
            apiObj.setEventCallbackState(evtName,false);
        end
    end


    methods


        function start(this)

            if~isempty(this.Port)&&~connector.isRunning
                removeControllers(this);
            end


            [hostInfo]=connector.ensureServiceOn;
            this.Port=hostInfo.securePort;


            initControllers(this);


            initWorkspaceBrowser(this);
        end

    end


    methods(Access=protected)


        function initControllers(this)
            cacheControllersInitialized=this.ControllersInitialized;
            initControllers@Simulink.sdi.internal.ConnectorAPI(this);

            if~cacheControllersInitialized
                Simulink.sdi.internal.controllers.SessionSaveLoad.getController('siganalyzer');


                signal.analyzer.controllers.ImportFromDrop.getController();
                signal.analyzer.controllers.ScriptGeneration.BaseScriptGenerator.getController();
                signal.analyzer.controllers.Preprocessing.Preprocessor.getController();
                signal.analyzer.controllers.ScriptGeneration.PreprocessingFunctionGenerator.getController();
                signal.analyzer.controllers.Scalogram.getController();
                signal.analyzer.controllers.ImportFunction.getController();
                signal.analyzer.controllers.SaveFunction.getController();
                signal.analyzer.controllers.AppState.getController();
                signal.analyzer.controllers.PreprocessMode.ImportPreprocessModeController.getController();
                signal.analyzer.controllers.PreprocessMode.ExportPreprocessModeController.getController();


                signal.analyzer.viewModels.PreprocessViewModel.getViewModel();


                timeMetadataController=signal.sigappsshared.controllers.TimeMetadataDialog.getController();
                addAppNameToAppsUsingControllerList(timeMetadataController,"SignalAnalyzer");
            end
        end


        function removeControllers(this)
            cacheControllersInitialized=this.ControllersInitialized;

            if cacheControllersInitialized&&connector.isRunning
                sslCtrl=Simulink.sdi.internal.controllers.SessionSaveLoad.getController('siganalyzer');
                delete(sslCtrl);


                impDropCtrl=signal.analyzer.controllers.ImportFromDrop.getController();
                delete(impDropCtrl);
                scriptGeneratorCtrl=signal.analyzer.controllers.ScriptGeneration.BaseScriptGenerator.getController();
                delete(scriptGeneratorCtrl);
                preprocessingCtrl=signal.analyzer.controllers.Preprocessing.Preprocessor.getController();
                delete(preprocessingCtrl);
                scalogramCtrl=signal.analyzer.controllers.Scalogram.getController();
                delete(scalogramCtrl);
                importFunctionCtrl=signal.analyzer.controllers.ImportFunction.getController();
                delete(importFunctionCtrl);
                saveFunctionCtrl=signal.analyzer.controllers.SaveFunction.getController();
                delete(saveFunctionCtrl);
                appStateCtrl=signal.analyzer.controllers.AppState.getController();
                delete(appStateCtrl);
                importPreprocessModeCtrl=signal.analyzer.controllers.PreprocessMode.ImportPreprocessModeController.getController();
                delete(importPreprocessModeCtrl);
                exportPreprocessModeCtrl=signal.analyzer.controllers.PreprocessMode.ExportPreprocessModeController.getController();
                delete(exportPreprocessModeCtrl);


                preprocessViewModel=signal.analyzer.viewModels.PreprocessViewModel.getViewModel();
                delete(preprocessViewModel);



                timeMetadataController=signal.sigappsshared.controllers.TimeMetadataDialog.getController();
                removeAppNameFromAppsUsingControllerList(timeMetadataController,"SignalAnalyzer");
                if isempty(getAppsUsingControllerList(timeMetadataController))
                    delete(timeMetadataController);
                end
            end
        end


        function initWorkspaceBrowser(~)

            wsb=internal.matlab.workspace.peer.PeerWorkspaceBrowserFactory.createWorkspaceBrowser('signal.analyzer.FilteredWorkspace','/SigAnalyzerWSBChannel');
            wsb.Documents.ViewModel.setTableModelProperty('ShowValueColumn',false);
        end
    end
end
