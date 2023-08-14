function out=getSparklineSettingsForBlk(blockHandle)
    import Simulink.record.internal.*;
    out=[];
    view=get_param(blockHandle,'View');
    for plotIdx=1:view.subplots.Size
        subPlot=view.subplots.getByKey(int32(plotIdx));
        if strcmp(subPlot.visual.visualName,DAStudio.message('record_playback:params:Sparkline'))
            sparklinesDataModel=subPlot.visual.localSettings;
            out=[out;SparklinePlotPreferences.createSparklinePrefsFromDataModel(plotIdx,...
            sparklinesDataModel)];%#ok<AGROW>
        end
    end

end


