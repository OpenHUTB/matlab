function updateXUnits(this)




    hAxes=this.Axes;


    if this.ShowXAxisLabels
        set(hAxes,'XTickMode','auto','XTickLabelMode','auto');
    end
    XLim=calculateXLim(this);
    [~,this.FrequencyMultiplier,this.FrequencyUnitsDisplay]=engunits(XLim);
    set(hAxes,'XLim',XLim);



    if~isempty(resetplotview(hAxes,'GetStoredViewStruct'))
        zoom(hAxes(1,1),'reset');
        zoom(hAxes(1,2),'reset');
    end
    updateXLabel(this);
end
