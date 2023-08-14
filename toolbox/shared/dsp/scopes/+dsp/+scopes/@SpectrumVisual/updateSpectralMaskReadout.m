function updateSpectralMaskReadout(this)




    hPlotter=this.Plotter;
    if~strcmp(hPlotter.SpectralMaskVisibility,'None')


        if~(this.SpectralMaskDialogEnabled)&&isempty(getSpectralMaskDialog(this))
            toggleSpectralMaskDialog(this);
        end
        dlg=getSpectralMaskDialog(this);
        if~isempty(dlg)
            updateSpectralMaskMeasurements(dlg);
        else
            hPlotter.SpectralMaskVisibility='None';
        end
    end
