function defaultLayout(obj,~)




    currDialog=obj.pParameters.CurrentDialog;
    obj.pPlotTimeScope=currDialog.timeScopeEnabled();
    obj.pPlotSpectrum=currDialog.spectrumEnabled();
    obj.pPlotConstellation=currDialog.constellationEnabled();
    obj.pPlotEyeDiagram=currDialog.offersEyeDiagram()&&currDialog.eyeEnabled();
    obj.pPlotCCDF=currDialog.offersCCDF()&&currDialog.ccdfEnabled();
    currDialog.defaultVisualLayout();

    obj.setScopeLayout();

    if obj.useAppContainer

        obj.AppContainer.LeftCollapsed=false;
    end