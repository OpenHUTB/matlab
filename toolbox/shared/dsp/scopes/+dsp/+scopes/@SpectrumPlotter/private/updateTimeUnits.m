function updateTimeUnits(this)




    hAxes=this.Axes(1,2);
    set(hAxes,'YScale','lin');


    if this.ShowYAxisLabels
        set(hAxes,'YTickMode','auto','YTickLabelMode','auto');
    end
    if any(strcmp(this.PlotMode,{'Spectrogram','SpectrumAndSpectrogram'}))
        YLim=calculateYLim(this);
        [~,this.TimeMultiplier,this.TimeUnitsDisplay]=engunits(abs(YLim),'time');
        if strcmp(this.TimeUnitsDisplay,'secs')
            this.TimeUnitsDisplay='s';
        end
        set(hAxes,'YLim',YLim);




        if~isempty(resetplotview(hAxes,'GetStoredViewStruct'))
            zoom(hAxes,'reset');
        end
    end
    updateYLabel(this);
    updateYTickLabels(this);
end
