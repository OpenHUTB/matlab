function updateFrequencyScale(this)




    if~getPropertyValue(this,'IsSpanValuesValid')||this.IsInitModeFlag



        set(this.Axes,'XLim',[0,1]);
    end
    this.Plotter.FrequencyScale=getPropertyValue(this,'FrequencyScale');
end
