classdef TableController<handle




    properties(Access=private)
Model
    end

    events

ClearAxes
UpdatePlot
CalculateAxesAndUpdatePlot

ClearStatusBar

UpdateTableSelection

ClearToolstrip
UpdateToolstrip
    end

    methods(Hidden)

        function this=TableController(model)
            this.Model=model;
        end


        function cb_TableSelectionChanged(this,args,deleteFlag)
            busyOverlay=wavelettfanalyzer.internal.BusyOverlay.setGetBusyOverlay();
            busyOverlay.show();
            if~isempty(args.Indices)
                idx=args.Indices(1);
                name=args.Source.Data(idx);
                this.Model.setCurrentSignalName(name);

                if~this.Model.getScalogramIsComputed
                    if this.Model.getUseBackgroundPool()
                        bp=backgroundPool;
                        bkgpcwt=parfeval(bp,@()this.Model.updateScalogramDefaultParamsWithCompute(),1);
                        afterAll(bkgpcwt,@(varargin)this.calculateScalogramComplete(varargin{:}),0);
                    else
                        info=this.Model.updateScalogramDefaultParamsWithCompute();
                        this.calculateScalogramComplete(info);
                    end

                else
                    updateAxesEventData=this.Model.getUpdatePlotData();
                    this.notify("UpdatePlot",wavelettfanalyzer.internal.EventData(updateAxesEventData));
                    updateToolstripEventData=this.Model.getToolstripData();
                    this.notify("UpdateToolstrip",wavelettfanalyzer.internal.EventData(updateToolstripEventData));
                    this.notify("ClearStatusBar");
                    busyOverlay.hide();
                end
            else
                if deleteFlag
                    this.notify("ClearAxes");
                    this.notify("ClearToolstrip");
                    this.notify("ClearStatusBar");
                else
                    updateTableEventData.name=this.Model.getCurrentSignalName();
                    this.notify("UpdateTableSelection",wavelettfanalyzer.internal.EventData(updateTableEventData));
                end
                busyOverlay.hide();
            end
        end
    end

    methods(Access=private)

        function calculateScalogramComplete(this,varargin)
            info=varargin{1};
            this.Model.storeCWTInfo(info.name,info);
            updateToolstripEventData=this.Model.getToolstripData();
            this.notify("UpdateToolstrip",wavelettfanalyzer.internal.EventData(updateToolstripEventData));
            this.notify("ClearStatusBar");
            updateAxesEventData.calculateAxesData=info;
            updateAxesEventData.updatePlotData=this.Model.getUpdatePlotData();
            this.notify("CalculateAxesAndUpdatePlot",wavelettfanalyzer.internal.EventData(updateAxesEventData));
        end
    end

end
