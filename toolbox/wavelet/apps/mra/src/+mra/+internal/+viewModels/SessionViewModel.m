

classdef SessionViewModel<mra.internal.viewModels.ViewModelBase


    methods(Hidden)

        function this=SessionViewModel(controller,dispatcher,signalPlotter)
            this@mra.internal.viewModels.ViewModelBase(controller,dispatcher,signalPlotter);
            this.subscribeToControllerEvents();
        end

        function subscribeToControllerEvents(this)
            addlistener(this.Controller,"NewSessionComplete",@(src,args)this.cb_NewSessionComplete(src,args));
        end

        function cb_NewSessionComplete(this,~,args)
            messageID=args.Data.messageID;

            switch messageID
            case "resetFrequencyColumnHeader"
                controllerID="levelSelectionTableWidget";
                data=args.Data.data;
            case "removeDecompositionLevels"
                controllerID="decompositionDisplayWidget";
                data=args.Data.data;
            case "decompositionTableData"
                controllerID="decomposedSignalsTableWidget";
                messageID="clearDecomposedSignalsTable";
                data=struct;
            case "levelSelectionTableData"
                controllerID="levelSelectionTableWidget";
                messageID="clearLevelSelectionSignalsTable";
                data=struct;
            case "removeReconstruction"
                controllerID="reconstructionAxesWidget";
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