function out=getXYPrefLocalSettingsForBlk(blockHandle)
    import Simulink.record.internal.*;
    out=[];
    view=get_param(blockHandle,'View');
    for plotIdx=1:view.subplots.Size
        subPlot=view.subplots.getByKey(int32(plotIdx));
        if strcmp(subPlot.visual.visualName,DAStudio.message('record_playback:params:XY'))
            xyLocalDataModel=subPlot.visual.localSettings;
            out=[out;LocalXYSettings.createXYLocalSettingsFromDataModel(plotIdx,...
            xyLocalDataModel)];%#ok<AGROW>
        end
    end
end
