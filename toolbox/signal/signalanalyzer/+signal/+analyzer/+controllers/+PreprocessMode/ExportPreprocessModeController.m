

classdef ExportPreprocessModeController<handle


    properties(Access=private)
        Dispatcher;
        Model;
        AppState;
    end

    properties(Constant)
        ControllerID='ExportPreprocessModeController';
    end

    events
CloseModeComplete
    end


    methods(Static)
        function ret=getController()

            persistent ctrlObj;
            mlock;
            if isempty(ctrlObj)||~isvalid(ctrlObj)
                dispatcherObj=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher();
                modelObj=signal.analyzer.models.PreprocessModel.getModel();
                appStateCtrl=signal.analyzer.controllers.AppState.getController();
                ctrlObj=signal.analyzer.controllers.PreprocessMode.ExportPreprocessModeController(modelObj,dispatcherObj,appStateCtrl);
            end


            ret=ctrlObj;
        end
    end


    methods(Access=protected)

        function this=ExportPreprocessModeController(modelObj,dispatcherObj,appStateCtrl)

            this.Dispatcher=dispatcherObj;
            this.Model=modelObj;
            this.AppState=appStateCtrl;
            import signal.analyzer.controllers.PreprocessMode.ExportPreprocessModeController;

            this.Dispatcher.subscribe(...
            [ExportPreprocessModeController.ControllerID,'/','closemode'],...
            @(arg)cb_CloseMode(this,arg));
        end

    end

    methods(Hidden)




        function cb_CloseMode(this,args)

            clientID=args.clientID;
            signalAnalyzerClientID=args.data.signalAnalyzerClientID;

            if args.data.type=="Accept"
                this.acceptAllPreprocessing(signalAnalyzerClientID);
            else
                this.discardAllPreprocessing(signalAnalyzerClientID);
            end


            clearSignalToTableData.clientID=clientID;
            clearSignalToTableData.messageID='clearSignalsInTable';
            clearSignalToTableData.data=struct;
            this.notify('CloseModeComplete',signal.internal.SAEventData(clearSignalToTableData));



            closeModeData.clientID=clientID;
            closeModeData.messageID='closeMode';
            closeModeData.data=struct;
            this.notify('CloseModeComplete',signal.internal.SAEventData(closeModeData));


            this.Model.resetModel();


            this.AppState.setModeName('');

            if args.data.showSaveSessionDialog
                this.showSaveSessionDialog();
            end
        end
    end

    methods(Access=protected)




        function acceptAllPreprocessing(this,clientID)

            this.setDirtyAppState();
            signalIDs=this.Model.getPreprocessedSignalIDs();

            signal.analyzer.SignalUtilities.deleteAllSignalsAfterCurrentPreprocessingIdx(signalIDs);

            signal.analyzer.SignalUtilities.deleteLastActionBackupSignalID(signalIDs);

            signal.analyzer.SignalUtilities.requestPlotUpdates(signalIDs,clientID,false,'preprocessApply');
            if isempty(this.Model.getCreatedSignalIDs())




                signal.analyzer.SignalUtilities.notifyWithUpdatedTableSelectionFlags(this.Model.getSelectedSignalsFlagsForPreprocessedSignalIDs());
            end

            signal.analyzer.SignalUtilities.notifySignalsInsertedEvent();

            signal.analyzer.SignalUtilities.notifyTableUpdates(signalIDs);
        end

        function discardAllPreprocessing(this,signalAnalyzerClientID)
            preprocessedSignalIDs=this.Model.getPreprocessedSignalIDs();

            for idx=1:numel(preprocessedSignalIDs)
                preprocessedSignalID=preprocessedSignalIDs(idx);
                backupSignalIDs=this.Model.getBackupSignalIDs(preprocessedSignalID);
                numberOfStoredBackupSignalIDs=this.Model.getStoredNumberOfBackupSignalIDsMapForSignals(preprocessedSignalID);

                if numel(backupSignalIDs)==numberOfStoredBackupSignalIDs


                    backupSignalIDForNewData=this.Model.getLastActionBackupSignalID(preprocessedSignalID);
                else
                    backupSignalIDForNewData=backupSignalIDs(end-numberOfStoredBackupSignalIDs);
                end
                signalData=this.Model.getSignalDataValues(backupSignalIDForNewData);


                notifyFlag=false;
                signal.analyzer.SignalUtilities.updateData(preprocessedSignalID,signalData,num2str(signalAnalyzerClientID),notifyFlag);
            end



            signalIDsCreated=this.Model.getCreatedSignalIDs();
            signalIDsToDelete=[this.Model.getAllInModePreprocessBackupIDs();signalIDsCreated];
            signal.sigappsshared.SignalUtilities.deleteSignalsAndResampledSignalsInEngine(signalIDsToDelete);


            signalIDsWithLastActionBackupSignalIDToBeDeleted=setdiff(preprocessedSignalIDs,signalIDsCreated,'stable');
            signal.analyzer.SignalUtilities.deleteLastActionBackupSignalID(signalIDsWithLastActionBackupSignalIDToBeDeleted);


            this.Model.resetSignalSaPreprocessBackupIDs();
        end
    end

    methods(Hidden)
        function showSaveSessionDialog(~)
            import Simulink.sdi.internal.controllers.SessionSaveLoad;
            SessionSaveLoad.saveSDISessionBeforeClose(signal.analyzer.Instance.gui(),'appName','siganalyzer');
        end

        function setDirtyAppState(~)
            signal.analyzer.SignalUtilities.setDirtyAppState();
        end
    end
end