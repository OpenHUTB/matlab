

classdef AxesViewModel<mra.internal.viewModels.ViewModelBase


    methods(Hidden)
        function this=AxesViewModel(controller,dispatcher,signalPlotter)
            this@mra.internal.viewModels.ViewModelBase(controller,dispatcher,signalPlotter);
            this.subscribeToControllerEvents();
        end

        function subscribeToControllerEvents(this)
            addlistener(this.Controller,"UpdateIncludeInReconstructionComplete",@(src,args)this.cb_UpdateIncludeInReconstructionComplete(src,args));
            addlistener(this.Controller,"PlotSignalOnInclude",@(src,args)this.cb_PlotSignalsOnInclude(src,args));
        end

        function cb_UpdateIncludeInReconstructionComplete(this,~,args)
            messageID=args.Data.messageID;

            switch messageID
            case "updateAlphaOnInclude"
                controllerID="decompositionDisplayWidget";
                data=args.Data.data;
            case "toggleIncludeCheckBoxState"
                controllerID="levelSelectionTableWidget";
                data=args.Data.data;
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