function updateYTickLabels(this)



    if this.CCDFMode&&this.ShowYAxisLabels
        hAxes=this.Axes(1,1);
        yLim=get(hAxes,'YLim');
        if yLim(1)>1e-5&&yLim(2)<=100
            yTick=get(hAxes(1,1),'YTick');
            yTickStr=num2str(yTick');
            set(hAxes(1,1),'YTickLabel',yTickStr);
        else
            set(hAxes,'YTickMode','auto');
            set(hAxes,'YTickLabelMode','auto');
        end
    elseif(any(strcmp(this.PlotMode,{'Spectrogram','SpectrumAndSpectrogram'})))&&this.ShowYAxisLabels
        hAxes=this.Axes(1,2);
        if strcmp(this.pYTickLabelMode,'auto')||isempty(this.pYTickLabel)
            yTickStr=get(hAxes,'YTick')*this.TimeMultiplier;


            yTickLabels=num2str(yTickStr',4);
        else
            yTickLabels=this.pYTickLabel;
        end
        set(hAxes,'YTickLabel',yTickLabels);
    else
        tickSetOps={'YTickMode','auto'};
        labelSetOps={'YTickLabelMode','auto'};
        set(this.Axes(1,1),tickSetOps{:},labelSetOps{:});
        set(this.Axes(1,2),tickSetOps{:},labelSetOps{:})
    end

    updateStemPlotBaseValue(this);
end
