function updateText(this)




    hPlotter=this.Plotter;
    if~isempty(hPlotter)&&~strcmp(hPlotter.SpectralMaskVisibility,'None')
        updateSpectralMaskReadout(this);
    end
