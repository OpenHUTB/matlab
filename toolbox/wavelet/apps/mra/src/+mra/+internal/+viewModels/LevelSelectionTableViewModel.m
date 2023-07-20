

classdef LevelSelectionTableViewModel<mra.internal.viewModels.ViewModelBase


    methods(Hidden)
        function this=LevelSelectionTableViewModel(controller,dispatcher,signalPlotter)
            this@mra.internal.viewModels.ViewModelBase(controller,dispatcher,signalPlotter);
            this.subscribeToControllerEvents();
        end

        function subscribeToControllerEvents(this)
            addlistener(this.Controller,"UpdateIncludeInReconstructionComplete",@(src,args)this.cb_UpdateIncludeInReconstructionComplete(src,args));
            addlistener(this.Controller,"UpdateShowInDecompositionComplete",@(src,args)this.cb_UpdateShowInDecompositionComplete(src,args));
            addlistener(this.Controller,"PlotSignalOnInclude",@(src,args)this.cb_PlotSignalsOnInclude(src,args));
        end

        function cb_UpdateIncludeInReconstructionComplete(this,~,args)
            messageID=args.Data.messageID;

            switch messageID
            case "updateAlphaOnInclude"
                controllerID="decompositionDisplayWidget";
                data=args.Data.data;
            end

            this.publishToClient(controllerID,messageID,data);
        end

        function cb_UpdateShowInDecompositionComplete(this,~,args)
            messageID=args.Data.messageID;

            switch messageID
            case "updateDecompositionLevels"
                controllerID="decompositionDisplayWidget";
                data=args.Data.data;
            case "removeDecompositionLevels"
                controllerID="decompositionDisplayWidget";
                data=args.Data.data;
            case "setXLabelInLastVisibleAxes"
                controllerID="decompositionDisplayWidget";
                messageID="setXLabelInLastVisibleAxes";
                data=args.Data.data;
            case "hideBusyOverlay"
                controllerID="levelSelectionTableWidget";
                data=struct;
            end

            this.publishToClient(controllerID,messageID,data);
        end

        function cb_PlotSignalsOnInclude(this,~,args)
            data=args.Data;
            signalIDs=data.SignalIDs;
            signalData=data.SignalData;
            plottingMap=data.PlottingMap;
            performFitToView=data.PerformFitToView;

            this.SignalPlotter.plotSignals(signalIDs,signalData,plottingMap,performFitToView);
        end
    end
end