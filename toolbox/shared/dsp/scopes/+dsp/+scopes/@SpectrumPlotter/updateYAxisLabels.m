function updateYAxisLabels(this,isVisible)





    this.ShowYAxisLabels=isVisible;
    uiservices.setListenerEnable(this.YTickListener,isVisible);
    uiservices.setListenerEnable(this.YLimitListener,isVisible);
    hYlabel=get(this.Axes(1,1),'YLabel');
    if this.CCDFMode
        updateCCDFYAxis(this);
    else
        updateTimeUnits(this);
    end
    if isVisible
        set(hYlabel,'Visible','on');
    end
end
