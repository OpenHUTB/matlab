function synchronizeWithPlotter(this)





    dirtyState=getDirtyStatus(this);
    c=onCleanup(@()restoreDirtyStatus(this,dirtyState));

    this.Plotter.PlotType=getPropertyValue(this,'PlotType');

    this.Plotter.InputDomain=this.pInputDomain;


    if this.updateTracesRequired
        updateTraces(this);
    end

    setLineProperties(this);


    if this.updateTracesRequired
        updateLegend(this);
        this.updateTracesRequired=false;
    end

    refreshStyleDialog(this);
    updateTitle(this);
    updateYLabel(this);


    hPlotNav=getExtInst(this.Application,'Tools','Plot Navigation');
    if~isempty(hPlotNav)
        this.pAutoScaleListenerState=enableLimitListeners(hPlotNav,false);
    end
    this.Plotter.ColorMap=evaluateColorMapExpression(this,getPropertyValue(this,'ColorMap'));
    this.Plotter.ColorLim=[evalPropertyValue(this,'MinColorLim'),evalPropertyValue(this,'MaxColorLim')];
    if isSpectrogramMode(this)||isCombinedViewMode(this)


        updateView(this);
    end
    if~isempty(hPlotNav)
        enableLimitListeners(hPlotNav,this.pAutoScaleListenerState);
    end


    notify(this,'DisplayUpdated',uiservices.DataEventData(struct('UserGenerated',false)));
end
