function updateColorBar(this)




    if this.IsVisualStartingUp||~(isSpectrogramMode(this)||isCombinedViewMode(this))
        return
    end
    hPlotter=this.Plotter;
    if~isempty(hPlotter)
        updateColorBar(hPlotter)
        if getPropertyValue(this,'IsCorrectionMode')
            uistack(hPlotter.hColorBar,'bottom')
        else
            uistack(hPlotter.hColorBar,'top')
        end
    end
end
