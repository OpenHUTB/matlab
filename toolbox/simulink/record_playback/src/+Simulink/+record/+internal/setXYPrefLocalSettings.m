function setXYPrefLocalSettings(blockHandleOrPath,localXYSettings)


    if~isempty(localXYSettings)
        validateattributes(localXYSettings,...
        {'Simulink.record.internal.LocalXYSettings'},{})
    else
        return;
    end


    blockHandle=blockHandleOrPath;
    if ischar(blockHandleOrPath)
        blockHandle=getSimulinkBlockHandle(blockHandleOrPath);
    end

    viewModel=get_param(blockHandle,'View');

    for idx=1:numel(localXYSettings)

        subPlotId=localXYSettings(idx).SubPlotID;
        subPlotId=Simulink.record.internal.verifySubPlot(subPlotId);

        subPlot=viewModel.subplots.getByKey(subPlotId);

        model=mf.zero.getModel(viewModel);
        tx=model.beginTransaction();

        if~strcmp(subPlot.visual.visualName,...
            DAStudio.message('record_playback:params:XY'))
            subPlot.visual=SdiVisual.XY(model);
            subPlot.visual.localSettings=SdiVisual.LocalXYSettings(model);

            subPlot.visual.localSettings.limits.xMin=0;
            subPlot.visual.localSettings.limits.xMax=10;
            subPlot.visual.localSettings.limits.yMin=-5;
            subPlot.visual.localSettings.limits.yMax=5;
        end

        localXYSettingsDataModel=subPlot.visual.localSettings;
        localXYSettingsDataModel.autoLimits=localXYSettings(idx).isAutoLimits;
        XYLimits=localXYSettings(idx).limits;

        if XYLimits(1)<XYLimits(2)||XYLimits(3)<XYLimits(4)
            localXYSettingsDataModel.limits.xMin=XYLimits(1);
            localXYSettingsDataModel.limits.xMax=XYLimits(2);
            localXYSettingsDataModel.limits.yMin=XYLimits(3);
            localXYSettingsDataModel.limits.yMax=XYLimits(4);
        end

        tx.commit();

        if subPlotId==viewModel.selectedPlotID&&~localXYSettingsDataModel.autoLimits
            set_param(blockHandle,'xmin',string(XYLimits(1)));
            set_param(blockHandle,'xmax',string(XYLimits(2)));
            set_param(blockHandle,'ymin',string(XYLimits(3)));
            set_param(blockHandle,'ymax',string(XYLimits(4)));
        end
    end
end