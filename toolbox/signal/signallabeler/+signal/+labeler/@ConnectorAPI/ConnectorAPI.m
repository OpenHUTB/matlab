classdef ConnectorAPI<handle






    properties(Access=protected)
        Port='';
        ControllersInitialized=false;
    end



    methods(Static)
        function ret=getAPI()

            persistent labelerConnectorAPI;
            mlock;
            if isempty(labelerConnectorAPI)||~isvalid(labelerConnectorAPI)
                labelerConnectorAPI=signal.labeler.ConnectorAPI;
            end
            ret=labelerConnectorAPI;
        end
    end



    methods
        function url=getURL(this,pagePath)

            if isempty(this.Port)
                [hostInfo]=connector.ensureServiceOn;
                this.Port=hostInfo.securePort;
            end
            url=connector.getUrl(pagePath);
        end


        function start(this)

            if~isempty(this.Port)&&~connector.isRunning
                removeControllers(this);
            end


            [hostInfo]=connector.ensureServiceOn;
            this.Port=hostInfo.securePort;


            initControllers(this);
            initAudioMode(this);


            initWorkspaceBrowser(this);


            initLabelDataRepository(this);


            initFastLabelDataRepository(this);


            initDashboardDataRepository(this);


            initFeatureExtractionDataRepository(this);

        end


        function stop(this)
            if~isempty(this.Port)
                removeControllers(this);
                this.Port=[];
            end
        end


        function delete(this)
            stop(this);
        end
    end



    methods(Access=protected)
        function initControllers(this)
            if~this.ControllersInitialized

                signal.labeler.controllers.ImportDialog.getController();
                signal.labeler.viewmodels.LabelViewModel.getViewModel();
                signal.labeler.controllers.Import.getController();
                signal.labeler.controllers.Export.getController();
                signal.labeler.controllers.LabelDefinitionController.getController();
                signal.labeler.controllers.LabelController.getController();
                signal.labeler.controllers.SignalTableController.getController();
                signal.labeler.controllers.AutoLabeling.AutoLabeler.getController();
                signal.labeler.controllers.ImportLabelerFunction.getController();
                signal.labeler.controllers.SaveLabelerFunction.getController();
                signal.labeler.controllers.ImportLabelerFunction.getController();
                signal.labeler.controllers.SaveLabelerFunction.getController();
                signal.labeler.controllers.ImportAutoLabelMode.getController();
                signal.labeler.controllers.ExportAutoLabelMode.getController();
                signal.labeler.controllers.ImportSignalsFromWorkspace.getController();
                signal.labeler.controllers.SessionsController.getController();
                signal.labeler.controllers.ImportSignalsFromFile.getController();
                signal.labeler.controllers.ImportFastLabelMode.getController();
                signal.labeler.controllers.FastLabel.FastLabelController.getController();
                signal.labeler.controllers.ExportFastLabelMode.getController();
                signal.labeler.controllers.DashboardController.getController();
                signal.labeler.controllers.FeatureExtraction.ImportFeatureExtractionMode.getController();
                signal.labeler.controllers.FeatureExtraction.ExportFeatureExtractionMode.getController();
                signal.labeler.controllers.FeatureExtraction.LabelDefinitionCtrlFeatureExtractionMode.getController();
                signal.labeler.controllers.FeatureExtraction.SignalTableControllerFeatureExtractionMode.getController();
                signal.labeler.controllers.FeatureExtraction.FeatureExtractor.getController();


                timeMetadataController=signal.sigappsshared.controllers.TimeMetadataDialog.getController();
                addAppNameToAppsUsingControllerList(timeMetadataController,"SignalLabeler");


                Simulink.HMI.initializeWebClient();
                Simulink.HMI.initStreamingSubscribers();

                this.ControllersInitialized=true;
            end
            signal.labeler.controllers.SignalTableController.getController().setupSignalTreeTablePaging();
        end


        function removeControllers(this)
            if this.ControllersInitialized
                this.ControllersInitialized=false;
                importDialogController=signal.labeler.controllers.ImportDialog.getController;
                delete(importDialogController);
                labelViewModel=signal.labeler.viewmodels.LabelViewModel.getViewModel();
                delete(labelViewModel);
                importController=signal.labeler.controllers.Import.getController();
                delete(importController);
                exportController=signal.labeler.controllers.Export.getController();
                delete(exportController);
                labelDefinitionController=signal.labeler.controllers.LabelDefinitionController.getController();
                delete(labelDefinitionController);
                labelController=signal.labeler.controllers.LabelController.getController();
                delete(labelController);
                signalTableController=signal.labeler.controllers.SignalTableController.getController();
                delete(signalTableController);
                autoLabelerController=signal.labeler.controllers.AutoLabeling.AutoLabeler.getController();
                delete(autoLabelerController);
                importLabelerFunction=signal.labeler.controllers.ImportLabelerFunction.getController();
                delete(importLabelerFunction);
                saveLabelerFunction=signal.labeler.controllers.SaveLabelerFunction.getController();
                delete(saveLabelerFunction);
                importAutoLabelMode=signal.labeler.controllers.ImportAutoLabelMode.getController();
                delete(importAutoLabelMode);
                exportAutoLabelMode=signal.labeler.controllers.ExportAutoLabelMode.getController();
                delete(exportAutoLabelMode);
                importSignalsFromWorkspace=signal.labeler.controllers.ImportSignalsFromWorkspace.getController();
                delete(importSignalsFromWorkspace);
                sessionsController=signal.labeler.controllers.SessionsController.getController();
                delete(sessionsController);
                importSignalsFromFile=signal.labeler.controllers.ImportSignalsFromFile.getController();
                delete(importSignalsFromFile);
                importFastLabelModeController=signal.labeler.controllers.ImportFastLabelMode.getController();
                delete(importFastLabelModeController);
                fastLabelController=signal.labeler.controllers.FastLabel.FastLabelController.getController();
                delete(fastLabelController);
                exportFastLabelModeController=signal.labeler.controllers.ExportFastLabelMode.getController();
                delete(exportFastLabelModeController);
                dashboardController=signal.labeler.controllers.DashboardController.getController();
                delete(dashboardController);
                importFeatureExtractionMode=signal.labeler.controllers.FeatureExtraction.ImportFeatureExtractionMode.getController();
                delete(importFeatureExtractionMode);
                exportFeatureExtractionMode=signal.labeler.controllers.FeatureExtraction.ExportFeatureExtractionMode.getController();
                delete(exportFeatureExtractionMode);
                labelDefinitionCtrlFeatureExtractionMode=signal.labeler.controllers.FeatureExtraction.LabelDefinitionCtrlFeatureExtractionMode.getController();
                delete(labelDefinitionCtrlFeatureExtractionMode);
                signalTableControllerFeatureExtractionMode=signal.labeler.controllers.FeatureExtraction.SignalTableControllerFeatureExtractionMode.getController();
                delete(signalTableControllerFeatureExtractionMode);
                featureExtractor=signal.labeler.controllers.FeatureExtraction.FeatureExtractor.getController();
                delete(featureExtractor);



                delete(audio.labeler.internal.AudioModeController.getInstance());



                timeMetadataController=signal.sigappsshared.controllers.TimeMetadataDialog.getController();
                removeAppNameFromAppsUsingControllerList(timeMetadataController,"SignalLabeler");
                if isempty(getAppsUsingControllerList(timeMetadataController))
                    delete(timeMetadataController);
                end
            end
        end


        function initAudioMode(~)

            if audio.labeler.internal.AudioModeController.isAudioToolboxInstalled()
                initialize(audio.labeler.internal.AudioModeController.getInstance());
            end
        end


        function initWorkspaceBrowser(~)

            wsb=internal.matlab.workspace.peer.PeerWorkspaceBrowserFactory.createWorkspaceBrowser('signal.labeler.FilteredWorkspace','/SigLabelerWSBChannel');
            wsb.Documents.ViewModel.setTableModelProperty('ShowValueColumn',false);
        end


        function initLabelDataRepository(~)
            model=signal.labeler.models.LabelDataRepository.getModel();
            resetModel(model);
        end


        function initFastLabelDataRepository(~)
            model=signal.labeler.models.FastLabelDataRepository.getModel();
            resetModel(model);
        end


        function initDashboardDataRepository(~)
            model=signal.labeler.models.DashboardDataRepository.getModel();
            resetModel(model);
        end


        function initFeatureExtractionDataRepository(~)
            model=signal.labeler.models.FeatureExtractionDataRepository.getModel();
            resetModel(model);
        end
    end
end
