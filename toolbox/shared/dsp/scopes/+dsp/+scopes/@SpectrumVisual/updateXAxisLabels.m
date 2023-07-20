function updateXAxisLabels(this)




    if isCCDFMode(this)
        updateXAxisLabels(this.Plotter,true)
    else
        updateXAxisLabels(this.Plotter,getPropertyValue(this,'FrequencyAxisLabel'))
    end
end
