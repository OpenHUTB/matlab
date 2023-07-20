function visualChanged(obj,item)




    obj.pNewSessionBtn.Enabled=true;

    switch item.Tag
    case 'timeScope'
        obj.pPlotTimeScope=item.Value;
    case 'spectrumAnalyzer'
        obj.pPlotSpectrum=item.Value;
    case 'constellation'
        obj.pPlotConstellation=item.Value;
    case 'eyediagram'
        obj.pPlotEyeDiagram=item.Value;
    case 'CCDF'
        obj.pPlotCCDF=item.Value;
    otherwise
        obj.pParameters.CurrentDialog.setVisualState(item.Text,item.Value);
    end

    obj.setScopeLayout();