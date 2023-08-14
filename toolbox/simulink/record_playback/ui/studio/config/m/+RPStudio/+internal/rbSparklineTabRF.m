


function schema=rbSparklineTabRF(fncname,userData,cbinfo,eventData)

    fnc=str2func(fncname);
    if nargout(fnc)
        schema=fnc(cbinfo);
    else
        schema=[];
        if nargin==4
            fnc(userData,cbinfo,eventData);
        elseif nargin==3
            fnc(cbinfo,eventData);
        else
            fnc(cbinfo);
        end
    end
end

function rbSparklineSettingsRF(userData,cbinfo,action)
    view=get_param(cbinfo.uiObject.Handle,'View');
    sparklinePlotPrefs=Simulink.record.internal.getSparklineSettings(cbinfo.uiObject.Handle,view.selectedPlotID);
    if isempty(sparklinePlotPrefs)
        return;
    end

    switch userData
    case 'rbTickLabelColor'
        action.selectedColor=utils.toolstrip.getColorInHexString(sparklinePlotPrefs.TicksColor);
    case 'rbPlotAreaColor'
        action.selectedColor=utils.toolstrip.getColorInHexString(sparklinePlotPrefs.PlotColor);
    case 'rbGridColor'
        action.selectedColor=utils.toolstrip.getColorInHexString(sparklinePlotPrefs.GridColor);
    case 'rbSPLTickPosBox'
        action.selectedItem=utils.toolstrip.getTimePlotPreferenceEntries(sparklinePlotPrefs.TicksPosition);
    case 'rbSPLLabelBox'
        action.selectedItem=utils.toolstrip.getTimePlotPreferenceEntries(sparklinePlotPrefs.TickLabels);
    case 'rbSPLLegendBox'
        action.selectedItem=utils.toolstrip.getTimePlotPreferenceEntries(sparklinePlotPrefs.LegendPosition);
    case 'rbHorizontal'
        if strcmpi(sparklinePlotPrefs.GridLines,DAStudio.message('record_playback:params:All'))...
            ||strcmpi(sparklinePlotPrefs.GridLines,DAStudio.message('record_playback:params:Horizontal'))
            action.selected=1;
            action.icon='rbHorizontalGrid';
        else
            action.selected=0;
            action.icon='rbHorizontalGridOFF';
        end
    case 'rbVertical'
        if strcmpi(sparklinePlotPrefs.GridLines,DAStudio.message('record_playback:params:All'))...
            ||strcmp(sparklinePlotPrefs.GridLines,DAStudio.message('record_playback:params:Vertical'))
            action.selected=1;
            action.icon='rbVerticalGrid';
        else
            action.selected=0;
            action.icon='rbVerticalGridOFF';
        end
    case 'rbMarkers'
        if strcmpi(sparklinePlotPrefs.Markers,DAStudio.message('record_playback:params:Show'))
            action.selected=1;
            action.icon='rbToggleMarkersIcon';
        else
            action.selected=0;
            action.icon='rbToggleMarkersIconOFF';
        end
    case 'rbBorder'
        if strcmpi(sparklinePlotPrefs.PlotBorder,DAStudio.message('record_playback:params:Show'))
            action.selected=1;
            action.icon='rbToggleBorderIcon';
        else
            action.selected=0;
            action.icon='rbToggleBorderIconOFF';
        end
    case 'rbUpdateModeBox'
        action.selectedItem=utils.toolstrip.getTimePlotPreferenceEntries(sparklinePlotPrefs.UpdateMode);
    case 'rbTimeLabelsDisplay'
        action.selectedItem=utils.toolstrip.getTimeLabelDisplaysEntries(sparklinePlotPrefs.TimeLabelsDisplay);
    case 'TimeAxisMinValue'
        action.text=num2str(sparklinePlotPrefs.TLimits(1));
    case 'TimeAxisMaxValue'
        action.text=num2str(sparklinePlotPrefs.TLimits(2));
    case 'TimeSpan'
        timeSpan=sparklinePlotPrefs.TimeSpan;
        if isnumeric(timeSpan)
            timeSpan=num2str(timeSpan);
        end
        action.text=timeSpan;
    case 'rbSPLMinHeight'
        action.value=sparklinePlotPrefs.minHeight;
    end
end