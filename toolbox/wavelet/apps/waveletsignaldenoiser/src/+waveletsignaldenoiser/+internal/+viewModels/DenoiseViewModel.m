

classdef DenoiseViewModel<waveletsignaldenoiser.internal.viewModels.ViewModelBase


    methods(Hidden)

        function this=DenoiseViewModel(controller,dispatcher,signalPlotter)
            this@waveletsignaldenoiser.internal.viewModels.ViewModelBase(controller,dispatcher,signalPlotter);
            this.subscribeToControllerEvents();
        end

        function subscribeToControllerEvents(this)
            addlistener(this.Controller,"DenoiseComplete",@(src,args)this.cb_DenoiseComplete(src,args));
            addlistener(this.Controller,"GetWaveletNumbersComplete",@(src,args)this.cb_GetWaveletNumbersComplete(src,args));
            addlistener(this.Controller,"GetLevelsAndThresholdingRulesComplete",@(src,args)this.cb_GetLevelsAndThresholdingRulesComplete(src,args));
            addlistener(this.Controller,"GetMaxLevelsComplete",@(src,args)this.cb_GetMaxLevelsComplete(src,args));
            addlistener(this.Controller,"AddNewScenarioComplete",@(src,args)this.cb_AddNewScenarioComplete(src,args));
            addlistener(this.Controller,"PlotSignals",@(src,args)this.cb_PlotSignals(src,args));
        end

        function cb_DenoiseComplete(this,~,args)
            messageID=args.Data.messageID;

            switch messageID
            case "updateCoefficientsLevels"
                controllerID="coefficientsDisplayWidget";
                data=args.Data.data;
            case "removeCoefficientsLevels"
                controllerID="coefficientsDisplayWidget";
                data=args.Data.data;
            case "currentWaveletParametersTableData"
                controllerID="currentWaveletParametersTableWidget";
                messageID="replaceDataInCurrentWaveletParametersTable";
                data=args.Data.data;
            case "updateFitToViewFlag"
                controllerID="coefficientsDisplayWidget";
                data=args.Data.data;
            case "hideBusyOverlay"
                controllerID="toolstripWidget";
                data=struct;
            end

            this.publishToClient(controllerID,messageID,data);
        end

        function cb_GetWaveletNumbersComplete(this,~,args)
            messageID=args.Data.messageID;

            switch messageID
            case "setWaveletNumbers"
                controllerID="toolstripWidget";
                data=args.Data.data;
            case "hideBusyOverlay"
                controllerID="toolstripWidget";
                data=struct;
            end

            this.publishToClient(controllerID,messageID,data);
        end

        function cb_GetLevelsAndThresholdingRulesComplete(this,~,args)
            messageID=args.Data.messageID;

            switch messageID
            case "setLevelsAndThresholdingRules"
                controllerID="toolstripWidget";
                data=args.Data.data;
            case "hideBusyOverlay"
                controllerID="toolstripWidget";
                data=struct;
            end

            this.publishToClient(controllerID,messageID,data);
        end

        function cb_GetMaxLevelsComplete(this,~,args)
            messageID=args.Data.messageID;

            switch messageID
            case "setMaxLevels"
                controllerID="toolstripWidget";
                data=args.Data.data;
            case "hideBusyOverlay"
                controllerID="toolstripWidget";
                data=struct;
            end

            this.publishToClient(controllerID,messageID,data);
        end

        function cb_AddNewScenarioComplete(this,~,args)
            messageID=args.Data.messageID;

            switch messageID
            case "replaceCoefficientsLevels"
                controllerID="coefficientsDisplayWidget";
                data=args.Data.data;
            case "denoisedTableData"
                controllerID="denoisedSignalsTableWidget";
                messageID="addToDenoisedSignalsTable";
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
    end
end