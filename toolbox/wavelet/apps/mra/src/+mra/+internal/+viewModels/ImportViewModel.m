

classdef ImportViewModel<mra.internal.viewModels.ViewModelBase


    methods(Hidden)
        function this=ImportViewModel(controller,dispatcher,signalPlotter)
            this@mra.internal.viewModels.ViewModelBase(controller,dispatcher,signalPlotter);
            this.subscribeToControllerEvents();
        end

        function subscribeToControllerEvents(this)
            addlistener(this.Controller,"OpenImportSignalDialogComplete",@(src,args)this.cb_OpenImportSignalDialogComplete(src,args));
            addlistener(this.Controller,"CloseImportSignalDialogComplete",@(src,args)this.cb_CloseImportSignalDialogComplete(src,args));
            addlistener(this.Controller,"WorkspaceBrowserSelectionChanged",@(src,args)this.cb_WorkspaceBrowserSelectionChanged(src,args));
            addlistener(this.Controller,"ImportComplete",@(src,args)this.cb_ImportComplete(src,args));
            addlistener(this.Controller,"PlotSignals",@(src,args)this.cb_PlotSignals(src,args));
        end

        function cb_ImportComplete(this,~,args)
            messageID=args.Data.messageID;

            switch messageID
            case "addDecompositionLevels"
                controllerID="decompositionDisplayWidget";
                data=args.Data.data;
            case "decompositionTableData"
                controllerID="decomposedSignalsTableWidget";
                messageID="addToDecomposedSignalsTable";
                data=args.Data.data;
            case "levelSelectionTableData"
                controllerID="levelSelectionTableWidget";
                messageID="addToLevelSelectionSignalsTable";
                data=args.Data.data;
            case "addReconstruction"
                controllerID="reconstructionAxesWidget";
                data=args.Data.data;
            case "setValuesInToolstrip"
                controllerID="toolstripWidget";
                data=args.Data.data;
            case "updateFrequencyColumnHeader"
                controllerID="levelSelectionTableWidget";
                data=args.Data.data;
            case "hideBusyOverlay"
                controllerID="importSignalWidget";
                data=struct;
            end

            this.publishToClient(controllerID,messageID,data);
        end

        function cb_OpenImportSignalDialogComplete(this,~,args)
            messageID=args.Data.messageID;

            switch messageID
            case "showDialog"
                controllerID="importSignalWidget";
                data=struct;
            case "hideBusyOverlay"
                controllerID="toolstripWidget";
                data=struct;
            end

            this.publishToClient(controllerID,messageID,data);
        end

        function cb_CloseImportSignalDialogComplete(this,~,args)
            messageID=args.Data.messageID;

            switch messageID
            case "closeDialog"
                controllerID="importSignalWidget";
                data=struct;
            end

            this.publishToClient(controllerID,messageID,data);
        end

        function cb_WorkspaceBrowserSelectionChanged(this,~,args)
            messageID=args.Data.messageID;

            switch messageID
            case "enableImportButton"
                controllerID="importSignalWidget";
                data=args.Data.data;
            end

            this.publishToClient(controllerID,messageID,data)
        end
    end
end