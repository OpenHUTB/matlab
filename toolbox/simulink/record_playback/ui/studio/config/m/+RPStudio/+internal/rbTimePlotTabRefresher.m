
function rbTimePlotTabRefresher(userData,cbinfo,action)


    if~strcmp(class(cbinfo.uiObject),"Simulink.Record")
        return;
    end

    viewInfo=get_param(cbinfo.uiObject.Handle,'View');
    selectedSubPlot=viewInfo.subplots.getByKey(viewInfo.selectedPlotID);
    if~strcmp(selectedSubPlot.visual.visualName,'timeplotplugin')
        return;
    end

    plotPrefs=get_param(cbinfo.uiObject.Handle,'PlotPreferences');
    timePlotPrefs=plotPrefs.Time;

    switch userData
    case 'rbTickLabelColor'
        action.selectedColor=utils.toolstrip.getColorInHexString(timePlotPrefs.TicksColor);
    case 'rbPlotAreaColor'
        action.selectedColor=utils.toolstrip.getColorInHexString(timePlotPrefs.PlotColor);
    case 'rbGridColor'
        action.selectedColor=utils.toolstrip.getColorInHexString(timePlotPrefs.GridColor);
    case 'rbTimeLocationBox'
        action.selectedItem=utils.toolstrip.getTimePlotPreferenceEntries(timePlotPrefs.TicksPosition);
    case 'rbTimeLabelBox'
        action.selectedItem=utils.toolstrip.getTimePlotPreferenceEntries(timePlotPrefs.TickLabels);
    case 'rbTimeLegendBox'
        action.selectedItem=utils.toolstrip.getTimePlotPreferenceEntries(timePlotPrefs.LegendPosition);
    case 'rbHorizontal'
        if strcmpi(timePlotPrefs.GridLines,DAStudio.message('record_playback:params:All'))...
            ||strcmpi(timePlotPrefs.GridLines,DAStudio.message('record_playback:params:Horizontal'))
            action.selected=1;
            action.icon='rbHorizontalGrid';
        else
            action.selected=0;
            action.icon='rbHorizontalGridOFF';
        end
    case 'rbVertical'
        if strcmpi(timePlotPrefs.GridLines,DAStudio.message('record_playback:params:All'))...
            ||strcmp(timePlotPrefs.GridLines,DAStudio.message('record_playback:params:Vertical'))
            action.selected=1;
            action.icon='rbVerticalGrid';
        else
            action.selected=0;
            action.icon='rbVerticalGridOFF';
        end
    case 'rbMarkers'
        if strcmpi(timePlotPrefs.Markers,DAStudio.message('record_playback:params:Show'))
            action.selected=1;
            action.icon='rbToggleMarkersIcon';
        else
            action.selected=0;
            action.icon='rbToggleMarkersIconOFF';
        end
    case 'rbBorder'
        if strcmpi(timePlotPrefs.PlotBorder,DAStudio.message('record_playback:params:Show'))
            action.selected=1;
            action.icon='rbToggleBorderIcon';
        else
            action.selected=0;
            action.icon='rbToggleBorderIconOFF';
        end
    case 'rbUpdateModeBox'
        action.selectedItem=utils.toolstrip.getTimePlotPreferenceEntries(timePlotPrefs.UpdateMode);
    case 'TimeAxisMinValue'
        action.text=num2str(timePlotPrefs.TLimits(1));
    case 'TimeAxisMaxValue'
        action.text=num2str(timePlotPrefs.TLimits(2));
    case 'YAxisMinValue'
        yMin=selectedSubPlot.visual.yAxisLimits.minimum;
        action.text=num2str(yMin);
    case 'YAxisMaxValue'
        yMax=selectedSubPlot.visual.yAxisLimits.maximum;
        action.text=num2str(yMax);
    case 'TimeSpan'
        timeSpan=timePlotPrefs.TimeSpan;
        if isnumeric(timeSpan)
            timeSpan=num2str(timeSpan);
        end
        action.text=timeSpan;
    case 'ScaleAtStop'
        action.selected=timePlotPrefs.ScaleAtStop;
    case 'Normalize'
        view=get_param(cbinfo.uiObject.Handle,'View');
        selectedPlotId=view.selectedPlotID;
        action.selected=Simulink.record.internal.isNormalized(gcb,selectedPlotId);
    end

end


