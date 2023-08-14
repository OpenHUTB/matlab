function updateXAxisLabels(this,isVisible)





    this.ShowXAxisLabels=isVisible;
    uiservices.setListenerEnable(this.XTickListener,isVisible);
    uiservices.setListenerEnable(this.XLimitListener,isVisible);
    hXlabel1=get(this.Axes(1,1),'XLabel');
    hXlabel2=get(this.Axes(1,2),'XLabel');
    if isVisible
        updateXUnits(this);
        set(hXlabel1,'Visible','on');
        set(hXlabel2,'Visible','on');
    else
        set(this.Axes,'XTickLabel','');
        set(hXlabel1,'Visible','off');
        set(hXlabel2,'Visible','off');
    end
end
