function redoMaskTest(this)





    redoMaskTest(this.MaskTesterObject);


    hPlotter=this.Plotter;
    if~isempty(hPlotter)&&~isempty(hPlotter.MaskPlotter)
        drawSpectralMask(hPlotter);
        updateSpectralMaskReadout(this);
    end