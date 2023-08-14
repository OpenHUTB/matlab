function updatePlotter(this)






    set(this.Axes,'XScale','linear')
    updateFrequencySpan(this);
    updateTitle(this);
    updateYAxis(this);
    updateFrequencyScale(this);
    if isSpectrogramMode(this)||isCombinedViewMode(this)


        updateColorBar(this);
    else
        updateTitlePosition(this);
    end
end
