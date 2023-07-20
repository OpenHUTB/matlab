function postUpdate(this)








    hMaskTester=this.MaskTesterObject;
    if~strcmp(this.Plotter.SpectralMaskVisibility,'None')&&~hMaskTester.IsCurrentlyPassing

        notify(this.MaskSpecificationObject,'MaskTestFailed',...
        dsp.scopes.SpectralMaskTestInfo(getMaskStatus(hMaskTester)));
    end