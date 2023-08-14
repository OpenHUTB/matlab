

classdef ViewModelBase<handle


    properties(Access=protected)
Controller
Dispatcher
SignalPlotter
    end

    methods

        function this=ViewModelBase(controller,dispatcher,signalPlotter)

            this.Controller=controller;
            this.Dispatcher=dispatcher;
            this.SignalPlotter=signalPlotter;
        end

        function publishToClient(this,controllerID,messageID,data)



            this.Dispatcher.publishToClient(controllerID,messageID,data)
        end

        function cb_PlotSignals(this,~,args)
            data=args.Data;
            signalIDs=data.SignalIDs;
            signalData=data.SignalData;
            plottingMap=data.PlottingMap;

            this.SignalPlotter.plotSignals(signalIDs,signalData,plottingMap)
        end
    end
end