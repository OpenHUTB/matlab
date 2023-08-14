function setSparklineSettings(blockHandleOrPath,sparklinePrefs)


    if~isempty(sparklinePrefs)
        validateattributes(sparklinePrefs,...
        {'Simulink.record.internal.SparklinePlotPreferences'},{})
    else
        return;
    end


    blockHandle=blockHandleOrPath;
    if ischar(blockHandleOrPath)
        blockHandle=getSimulinkBlockHandle(blockHandleOrPath);
    end

    viewModel=get_param(blockHandle,'View');

    for idx=1:numel(sparklinePrefs)

        subPlotId=sparklinePrefs(idx).SubPlotID;
        subPlotId=Simulink.record.internal.verifySubPlot(subPlotId);

        subPlot=viewModel.subplots.getByKey(subPlotId);

        model=mf.zero.getModel(viewModel);
        tx=model.beginTransaction();

        if~strcmp(subPlot.visual.visualName,...
            DAStudio.message('record_playback:params:Sparkline'))
            subPlot.visual=SdiVisual.Sparkline(model);
            subPlot.visual.localSettings=SdiVisual.SparklineSettings(model);
        end

        sparklinesDataModel=subPlot.visual.localSettings;
        sparklinesDataModel.axisColor=utils.toolstrip.getColorInHexString(sparklinePrefs(idx).TicksColor);
        sparklinesDataModel.plotAreaColor=utils.toolstrip.getColorInHexString(sparklinePrefs(idx).PlotColor);
        sparklinesDataModel.gridColor=utils.toolstrip.getColorInHexString(sparklinePrefs(idx).GridColor);
        sparklinesDataModel.tickPos=utils.preferenceUtils.getTickPositionFromStr(sparklinePrefs(idx).TicksPosition);
        sparklinesDataModel.timeLabelsDisplay=utils.preferenceUtils.getTimeLabelsDisplayFromStr(sparklinePrefs(idx).TimeLabelsDisplay);
        sparklinesDataModel.Ticklabels=utils.preferenceUtils.getTickLabelFromStr(sparklinePrefs(idx).TickLabels);
        sparklinesDataModel.legendPos=utils.preferenceUtils.getLegendPositionFromStr(sparklinePrefs(idx).LegendPosition);
        sparklinesDataModel.markers=utils.preferenceUtils.getVisibilityFromStr(sparklinePrefs(idx).Markers);
        sparklinesDataModel.gridDisplay=utils.preferenceUtils.getGridDisplayFromStr(sparklinePrefs(idx).GridLines);
        sparklinesDataModel.axisBorder=utils.preferenceUtils.getVisibilityFromStr(sparklinePrefs(idx).PlotBorder);
        sparklinesDataModel.updateMode=utils.preferenceUtils.getUpdateModeFromStr(sparklinePrefs(idx).UpdateMode);
        tAxesLimits=sparklinePrefs(idx).TLimits;
        if strcmpi(sparklinePrefs(idx).TimeSpan,...
            DAStudio.message('record_playback:params:Auto'))
            sparklinesDataModel.xAxisLimits.mode=SdiVisual.ScalingMode.AUTO;
        else
            timeSpan=sparklinePrefs(idx).TimeSpan;
            sparklinesDataModel.xAxisLimits.mode=SdiVisual.ScalingMode.MANUAL;
            currentXLimits=sparklinesDataModel.xAxisLimits;

            if~(currentXLimits.minimum~=tAxesLimits(1)||...
                currentXLimits.maximum~=tAxesLimits(2))
                tAxesLimits(1)=currentXLimits.minimum;
                tAxesLimits(2)=currentXLimits.minimum+timeSpan;
            end
        end
        sparklinesDataModel.xAxisLimits.minimum=tAxesLimits(1);
        sparklinesDataModel.xAxisLimits.maximum=tAxesLimits(2);
        sparklinesDataModel.minHeight=sparklinePrefs(idx).minHeight;

        tx.commit();
    end
end