function updateLabels(this)



    hAx=this.Axes(1);
    hLabels=[get(hAx,'XLabel');get(hAx,'YLabel');get(hAx,'Title')];
    set(hLabels,'Color',this.AxesTickColor);
end
