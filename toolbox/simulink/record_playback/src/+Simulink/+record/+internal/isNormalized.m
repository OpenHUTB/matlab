function out=isNormalized(blockHandleOrPath,subPlotId)


    blockHandle=blockHandleOrPath;
    if ischar(blockHandleOrPath)
        blockHandle=getSimulinkBlockHandle(blockHandleOrPath);
    end

    viewModel=get_param(blockHandle,'View');
    subPlotId=Simulink.record.internal.verifySubPlot(subPlotId);

    subPlot=viewModel.subplots.getByKey(subPlotId);

    if strcmp(subPlot.visual.visualName,DAStudio.message('record_playback:params:TimePlot'))
        out=subPlot.visual.normalize;
    else
        out=false;
    end

end

