

classdef DecomposedSignalsTableViewModel<mra.internal.viewModels.ViewModelBase


    methods(Hidden)

        function this=DecomposedSignalsTableViewModel(controller,dispatcher,signalPlotter)
            this@mra.internal.viewModels.ViewModelBase(controller,dispatcher,signalPlotter);
            this.subscribeToControllerEvents();
        end

        function subscribeToControllerEvents(this)
            addlistener(this.Controller,"UpdateSelectionComplete",@(src,args)this.cb_UpdateSelectionComplete(src,args));
            addlistener(this.Controller,"DeleteScenarioComplete",@(src,args)this.cb_DeleteScenarioComplete(src,args));
            addlistener(this.Controller,"PlotSignals",@(src,args)this.cb_PlotSignals(src,args));
            addlistener(this.Controller,"RenameScenarioComplete",@(src,args)this.cb_RenameScenarioComplete(src,args));
        end

        function cb_UpdateSelectionComplete(this,~,args)
            messageID=args.Data.messageID;

            switch messageID
            case "replaceDecompositionLevels"
                controllerID="decompositionDisplayWidget";
                data=args.Data.data;
            case "levelSelectionTableData"
                controllerID="levelSelectionTableWidget";
                messageID="updateSelectionSignalsTable";
                data=args.Data.data;
            case "setValuesInToolstrip"
                controllerID="toolstripWidget";
                data=args.Data.data;
            case "updateReconstructionLineWidth"
                controllerID="reconstructionAxesWidget";
                data=args.Data.data;
            end

            this.publishToClient(controllerID,messageID,data);
        end

        function cb_DeleteScenarioComplete(this,~,args)
            messageID=args.Data.messageID;

            switch messageID
            case "deleteDecompositionComplete"
                controllerID="decomposedSignalsTableWidget";
                data=args.Data.data;
            case "removeDecompositionLevels"
                controllerID="decompositionDisplayWidget";
                data=args.Data.data;
            end

            this.publishToClient(controllerID,messageID,data);
        end

        function cb_RenameScenarioComplete(this,~,args)
            messageID=args.Data.messageID;

            switch messageID
            case "renameLegend"
                controllerID="reconstructionAxesWidget";
                data=args.Data.data;
            case "updateScenarioName"
                controllerID="decomposedSignalsTableWidget";
                data=args.Data.data;
            case "hideBusyOverlay"
                controllerID="decomposedSignalsTableWidget";
                data=struct;
            end

            this.publishToClient(controllerID,messageID,data);
        end
    end
end