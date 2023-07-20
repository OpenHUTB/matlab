function updateYLabel(this)






    this.Plotter.ViewType=this.pViewType;
    this.Plotter.SpectrumUnits=this.pSpectrumUnits;
    if~isFrequencyInputMode(this)
        this.Plotter.SpectrumType=this.pSpectrumType;
        this.Plotter.AxesLayout=this.pAxesLayout;
    end

    this.Plotter.YLabel=getPropertyValue(this,'YLabel');
end
