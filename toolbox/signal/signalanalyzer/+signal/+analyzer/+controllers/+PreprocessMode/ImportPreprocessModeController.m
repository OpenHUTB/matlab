

classdef ImportPreprocessModeController<handle


    properties(Access=private)
        Dispatcher;
        Model;
        AppState;
    end

    properties(Constant)
        ControllerID='ImportPreprocessModeController';
    end

    events
ImportComplete
PlotSelectedSignalsComplete
    end


    methods(Static)
        function ret=getController()

            persistent ctrlObj;
            mlock;
            if isempty(ctrlObj)||~isvalid(ctrlObj)
                dispatcherObj=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher();
                modelObj=signal.analyzer.models.PreprocessModel.getModel();
                appStateCtrl=signal.analyzer.controllers.AppState.getController();
                ctrlObj=signal.analyzer.controllers.PreprocessMode.ImportPreprocessModeController(modelObj,dispatcherObj,appStateCtrl);
            end


            ret=ctrlObj;
        end
    end


    methods(Access=protected)

        function this=ImportPreprocessModeController(modelObj,dispatcherObj,appStateCtrl)

            this.Dispatcher=dispatcherObj;
            this.Model=modelObj;
            this.AppState=appStateCtrl;
            import signal.analyzer.controllers.PreprocessMode.ImportPreprocessModeController;

            this.Dispatcher.subscribe(...
            [ImportPreprocessModeController.ControllerID,'/','importsignalsinpreprocessmode'],...
            @(arg)cb_ImportSignals(this,arg));
            this.Dispatcher.subscribe(...
            [ImportPreprocessModeController.ControllerID,'/','plotsignalontableselection'],...
            @(arg)cb_PlotSelectedSignals(this,arg));
        end

    end

    methods(Hidden)




        function cb_ImportSignals(this,args)


            this.AppState.setModeName('preprocessingMode');


            this.Model.resetModel();

            selectedSignalIDs=args.data.selectedSignalIDs;


            this.Model.setSelectedSignalsFlagsForMainApp(args.data.selectedSignalsFlags);


            signalIDsForSignalsTable=this.Model.getSignalIDsForTableSignals(selectedSignalIDs);



            this.Model.createBackupSignalIDsMapForImportedSignals(signalIDsForSignalsTable);



            this.Model.setCurrentPreprocessingIdxForSignals(signalIDsForSignalsTable,0);


            addSignalToTableData.clientID=args.clientID;
            addSignalToTableData.messageID='addSignalsToTable';
            addSignalToTableData.data.signalIDs=signalIDsForSignalsTable;
            addSignalToTableData.data.data=this.Model.getSignalsTableData(signalIDsForSignalsTable);
            addSignalToTableData.data.isSelectFirstRow=true;
            this.notify('ImportComplete',signal.internal.SAEventData(addSignalToTableData));


            toolstripData.clientID=args.clientID;
            toolstripData.messageID='enableSelectAndPanMode';
            toolstripData.data=struct;
            this.notify('ImportComplete',signal.internal.SAEventData(toolstripData));
        end

        function cb_PlotSelectedSignals(this,args)


            plotSelectedSignalsData.clientID=args.clientID;
            plotSelectedSignalsData.messageID='plotSignalsInDisplay';
            signalsData=this.Model.getSignalsPlotData(args.data.selectedSignalIDs);
            plotSelectedSignalsData.data=signalsData;
            this.notify('PlotSelectedSignalsComplete',signal.internal.SAEventData(plotSelectedSignalsData));



            this.Model.setCurrentPlottedSignalIDs(args.data.selectedSignalIDs);

            isPreserveStartTimeEnabled=args.data.isPreserveStartTimeEnabled;
            isAllSelectedSignalsTmModeSamples=strcmp({signalsData.TmMode},"samples");
            if isPreserveStartTimeEnabled&&all(isAllSelectedSignalsTmModeSamples)


                checboxData.clientID=args.clientID;
                checboxData.messageID='togglePreserveStartTimeCheckbox';
                checboxData.data.isEnabled=false;
                this.notify('PlotSelectedSignalsComplete',signal.internal.SAEventData(checboxData));
            elseif~isPreserveStartTimeEnabled&&all(~isAllSelectedSignalsTmModeSamples)



                checboxData.clientID=args.clientID;
                checboxData.messageID='togglePreserveStartTimeCheckbox';
                checboxData.data.isEnabled=true;
                this.notify('PlotSelectedSignalsComplete',signal.internal.SAEventData(checboxData));
            end
        end

    end

end