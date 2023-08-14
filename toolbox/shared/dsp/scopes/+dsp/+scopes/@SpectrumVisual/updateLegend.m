function updateLegend(this)






    if~ishghandle(this.Axes)
        return
    end
    legendVisibility=uiservices.logicalToOnOff(getPropertyValue(this,'Legend')&&~isSpectrogramMode(this));
    this.Plotter.LegendVisibility=legendVisibility;



    updateNoDataAvailableMessage(this);
    updateSamplesPerUpdateMessage(this);
    updateSpanReadOut(this);
    updateColorBar(this);
end
