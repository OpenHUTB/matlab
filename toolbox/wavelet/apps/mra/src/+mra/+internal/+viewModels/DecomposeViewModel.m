classdef DecomposeViewModel<mra.internal.viewModels.ViewModelBase





    methods(Hidden)

        function this=DecomposeViewModel(controller,dispatcher,signalPlotter)
            this@mra.internal.viewModels.ViewModelBase(controller,dispatcher,signalPlotter);
            this.subscribeToControllerEvents();
        end

        function subscribeToControllerEvents(this)
            addlistener(this.Controller,"DecomposeComplete",@(src,args)this.cb_DecomposeComplete(src,args));
            addlistener(this.Controller,"GetWaveletNumberComplete",@(src,args)this.cb_GetWaveletNumberComplete(src,args));
            addlistener(this.Controller,"AddNewScenarioComplete",@(src,args)this.cb_AddNewScenarioComplete(src,args));
            addlistener(this.Controller,"UpdateTimeInfoComplete",@(src,args)this.cb_UpdateTimeInfoComplete(src,args));
            addlistener(this.Controller,"PlotSignals",@(src,args)this.cb_PlotSignals(src,args));
        end

        function cb_DecomposeComplete(this,~,args)
            messageID=args.Data.messageID;

            switch messageID
            case "updateDecompositionLevels"
                controllerID="decompositionDisplayWidget";
                data=args.Data.data;
            case "removeDecompositionLevels"
                controllerID="decompositionDisplayWidget";
                data=args.Data.data;
            case "levelSelectionTableData"
                controllerID="levelSelectionTableWidget";
                messageID="updateSelectionSignalsTable";
                data=args.Data.data;
            case "updateFitToViewFlag"
                controllerID="decompositionDisplayWidget";
                data=args.Data.data;
            case "hideBusyOverlay"
                controllerID="toolstripWidget";
                data=struct;
            case "setVMDFields"
                controllerID="toolstripWidget";
                messageID="setVMDFieldsInToolstrip";
                data=args.Data.data;
            end

            this.publishToClient(controllerID,messageID,data);
        end

        function cb_GetWaveletNumberComplete(this,~,args)
            messageID=args.Data.messageID;

            switch messageID
            case "setWaveletNumbers"
                controllerID="toolstripWidget";
                messageID="setWaveletNumbersInToolstrip";
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
            case "replaceDecompositionLevels"
                controllerID="decompositionDisplayWidget";
                data=args.Data.data;
            case "decompositionTableData"
                controllerID="decomposedSignalsTableWidget";
                messageID="addToDecomposedSignalsTable";
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
            case "hideBusyOverlay"
                controllerID="toolstripWidget";
                data=struct;
            end

            this.publishToClient(controllerID,messageID,data);
        end

        function cb_UpdateTimeInfoComplete(this,~,args)
            messageID=args.Data.messageID;

            switch messageID
            case "levelSelectionTableData"
                controllerID="levelSelectionTableWidget";
                messageID="updateSelectionSignalsTable";
                data=args.Data.data;
            case "updateXLabelInDecompositionAxes"
                controllerID="decompositionDisplayWidget";
                messageID="updateXLabel";
                data=args.Data.data;
            case "updateXLabelInReconstructionAxes"
                controllerID="reconstructionAxesWidget";
                messageID="updateXLabel";
                data=args.Data.data;
            case "updateFrequencyColumnHeader"
                controllerID="levelSelectionTableWidget";
                data=args.Data.data;
            case "updateXRulerMultiplier"
                controllerID="decompositionDisplayWidget";
                data=args.Data.data;
            end

            this.publishToClient(controllerID,messageID,data);
        end
    end
end
