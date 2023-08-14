

classdef SessionViewModel<waveletsignaldenoiser.internal.viewModels.ViewModelBase


    methods(Hidden)

        function this=SessionViewModel(controller,dispatcher,signalPlotter)
            this@waveletsignaldenoiser.internal.viewModels.ViewModelBase(controller,dispatcher,signalPlotter);
            this.subscribeToControllerEvents();
        end

        function subscribeToControllerEvents(this)
            addlistener(this.Controller,"NewSessionComplete",@(src,args)this.cb_NewSessionComplete(src,args));
        end

        function cb_NewSessionComplete(this,~,args)
            messageID=args.Data.messageID;

            switch messageID
            case "removeCoefficientsLevels"
                controllerID="coefficientsDisplayWidget";
                data=args.Data.data;
            case "denoisingTableData"
                controllerID="denoisedSignalsTableWidget";
                messageID="clearDenoisedSignalsTable";
                data=struct;
            case "currentWaveletParametersTableData"
                controllerID="currentWaveletParametersTableWidget";
                messageID="clearCurrentWaveletParametersTable";
                data=struct;
            case "removeDenoisingAxes"
                controllerID="denoisingAxesWidget";
                data=args.Data.data;
            case "resetToolstrip"
                controllerID="toolstripWidget";
                data=struct;
            case "hideBusyOverlay"
                controllerID="toolstripWidget";
                data=struct;
            case "importAfterNewSession"
                controllerID="importSignalWidget";
                data=struct;
            end

            this.publishToClient(controllerID,messageID,data);
        end
    end
end