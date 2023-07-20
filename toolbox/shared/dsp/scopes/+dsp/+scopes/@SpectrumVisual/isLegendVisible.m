function b=isLegendVisible(this)




    if~isempty(this.Plotter)
        b=uiservices.onOffToLogical(this.Plotter.LegendVisibility);
    else
        b=false;
    end