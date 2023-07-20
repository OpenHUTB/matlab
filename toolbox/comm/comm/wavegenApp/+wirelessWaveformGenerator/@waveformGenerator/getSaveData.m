function data=getSaveData(obj,~)




    v=ver('MATLAB');
    data.Release=v.Release;

    data.Waveform.Type=obj.pCurrentWaveformType;
    data.Waveform.Configuration=obj.pParameters.CurrentDialog.getConfigurationForSave();



    if~isempty(obj.pParameters.ImpairDialog)
        data.Impairments=obj.pParameters.ImpairDialog.getConfigurationForSave();
    end
    data.Impairments.Enabled=obj.pImpairBtn.Value;

    if~isempty(obj.pParameters.RadioDialog)
        data.HardwareConfig.TransmitterType=obj.pCurrentHWType;
        data.HardwareConfig.TransmitterTag=obj.pCurrentHWTag;
        data.HardwareConfig.Hardware=obj.pParameters.RadioDialog.getConfigurationForSave();
        data.HardwareConfig.TxProp=obj.pParameters.TxWaveformDialog.getConfigurationForSave();
    end

    data.Visualization.TimeScope=obj.pPlotTimeScope;
    data.Visualization.SpectrumAnalyzer=obj.pPlotSpectrum;
    data.Visualization.Constellation=obj.pPlotConstellation;
    data.Visualization.EyeDiagram=obj.pPlotEyeDiagram;
    data.Visualization.CCDF.Plot=obj.pPlotCCDF;
    data.Visualization.CCDF.BurstMode=obj.pCCDFBurstMode;

    if obj.pPlotCCDF
        cb=findobj(obj.pCCDFFig,'Style','checkbox');
        data.Visualization.CCDF.BurstMode=logical(cb.Value);
    end

    currDialog=obj.pParameters.CurrentDialog;
    for k=1:length(currDialog.visualNames)
        thisVis=currDialog.visualNames{k};
        data.Visualization.(currDialog.getFigureTag(thisVis))=currDialog.getVisualState(thisVis);
    end