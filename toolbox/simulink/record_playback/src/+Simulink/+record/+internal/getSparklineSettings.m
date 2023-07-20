function out=getSparklineSettings(blockHandleOrPath,subPlotId)

    import Simulink.record.internal.*;
    blockHandle=blockHandleOrPath;
    if ischar(blockHandleOrPath)
        blockHandle=getSimulinkBlockHandle(blockHandleOrPath);
    end

    viewModel=get_param(blockHandle,'View');
    subPlotId=Simulink.record.internal.verifySubPlot(subPlotId);

    subPlot=viewModel.subplots.getByKey(subPlotId);

    if strcmp(subPlot.visual.visualName,DAStudio.message('record_playback:params:Sparkline'))
        sparklinesDataModel=subPlot.visual.localSettings;
        out=SparklinePlotPreferences.createSparklinePrefsFromDataModel(subPlotId,...
        sparklinesDataModel);
    else
        out=[];
    end
end
