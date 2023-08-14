

classdef DenoisedSignalsTableViewModel<waveletsignaldenoiser.internal.viewModels.ViewModelBase


    methods(Hidden)

        function this=DenoisedSignalsTableViewModel(controller,dispatcher,signalPlotter)
            this@waveletsignaldenoiser.internal.viewModels.ViewModelBase(controller,dispatcher,signalPlotter);
            this.subscribeToControllerEvents();
        end

        function subscribeToControllerEvents(this)
            addlistener(this.Controller,"UpdateSelectionComplete",@(src,args)this.cb_UpdateSelectionComplete(src,args));
            addlistener(this.Controller,"PlotSignals",@(src,args)this.cb_PlotSignals(src,args));
            addlistener(this.Controller,"DeleteScenarioComplete",@(src,args)this.cb_DeleteScenarioComplete(src,args));
            addlistener(this.Controller,"RenameScenarioComplete",@(src,args)this.cb_RenameScenarioComplete(src,args));
        end

        function cb_UpdateSelectionComplete(this,~,args)
            messageID=args.Data.messageID;

            switch messageID
            case "replaceCoefficientsLevels"
                controllerID="coefficientsDisplayWidget";
                data=args.Data.data;
            case "currentWaveletParametersTableData"
                controllerID="currentWaveletParametersTableWidget";
                messageID="replaceDataInCurrentWaveletParametersTable";
                data=args.Data.data;
            case "setValuesInToolstrip"
                controllerID="toolstripWidget";
                data=args.Data.data;
            case "updateDenoisingSignalWidth"
                controllerID="denoisingAxesWidget";
                data=args.Data.data;
            end

            this.publishToClient(controllerID,messageID,data);
        end

        function cb_DeleteScenarioComplete(this,~,args)
            messageID=args.Data.messageID;

            switch messageID
            case "deleteDenoisedSignalComplete"
                controllerID="denoisedSignalsTableWidget";
                data=args.Data.data;
            case "removeCoefficientsLevels"
                controllerID="coefficientsDisplayWidget";
                data=args.Data.data;
            end

            this.publishToClient(controllerID,messageID,data);
        end

        function cb_RenameScenarioComplete(this,~,args)
            messageID=args.Data.messageID;

            switch messageID
            case "renameLegend"
                controllerID="denoisingAxesWidget";
                data=args.Data.data;
            case "currentWaveletParametersTableData"
                controllerID="currentWaveletParametersTableWidget";
                messageID="replaceDataInCurrentWaveletParametersTable";
                data=args.Data.data;
            case "updateScenarioName"
                controllerID="denoisedSignalsTableWidget";
                data=args.Data.data;
            case "hideBusyOverlay"
                controllerID="denoisedSignalsTableWidget";
                data=struct;
            end

            this.publishToClient(controllerID,messageID,data);
        end
    end
end