function rbXYPlotTabRefresher(userData,cbinfo,action)

    if~strcmp(class(cbinfo.uiObject),"Simulink.Record")
        return;
    end

    view=get_param(cbinfo.uiObject.Handle,'View');
    selectedSubPlot=view.subplots.getByKey(view.selectedPlotID);
    if~strcmp(selectedSubPlot.visual.visualName,DAStudio.message('record_playback:params:XY'))
        return;
    end

    globalSettings=selectedSubPlot.visual.globalSettings;

    if isempty(globalSettings)
        return;
    end

    enableLineSettings=0;
    if strcmpi(globalSettings.line.lineVisibility,DAStudio.message('record_playback:params:Show'))
        enableLineSettings=1;
    end

    enableMarkerSettings=0;
    if strcmpi(globalSettings.markers.markerVisibility,DAStudio.message('record_playback:params:Show'))
        enableMarkerSettings=1;
    end

    enableTrendlineSettings=0;
    if strcmpi(globalSettings.trendLine.trendLineVisibility,DAStudio.message('record_playback:params:Show'))
        enableTrendlineSettings=1;
    end

    localXYPref=Simulink.record.internal.getLocalXYSettings(cbinfo.uiObject.Handle,view.selectedPlotID);
    customColors=get_param(cbinfo.uiObject.Handle,'CustomColors');

    switch userData
    case 'rbXYTickLabelColor'
        action.selectedColor=globalSettings.axisColor;
    case 'rbXYPlotAreaColor'
        action.selectedColor=globalSettings.plotAreaColor;
    case 'rbXYGridColor'
        action.selectedColor=globalSettings.gridColor;
    case 'rbXYLineEnable'
        action.selected=enableLineSettings;
        if enableLineSettings
            action.icon='rbToggleLine';
        else
            action.icon='rbToggleLineOFF';
        end
    case 'rbXYLineColorLabel'
        action.enabled=enableLineSettings;
    case 'rbXYLineColorBox'
        action.enabled=enableLineSettings;
        if~isempty(globalSettings.line.lineColor)
            action.selectedItem='record_playback:toolstrip:XYColorCustom';
        else
            action.selectedItem=utils.toolstrip.getXYPlotPreferenceEntries(globalSettings.line.axisColorOrigin);
        end
    case 'rbXYLineColorButton'
        action.enabled=enableLineSettings&&~isempty(globalSettings.line.lineColor);
        action.selectedColor=globalSettings.line.lineColor;
    case 'rbXYMarkersEnable'
        action.selected=enableMarkerSettings;
        if enableMarkerSettings
            action.icon='rbToggleMarkersIcon';
        else
            action.icon='rbToggleMarkersIconOFF';
        end
    case 'rbXYFillColorLabel'
        action.enabled=enableMarkerSettings;
    case 'rbXYFillColorBox'
        action.enabled=enableMarkerSettings;
        if~isempty(globalSettings.markers.fillColor)
            action.selectedItem='record_playback:toolstrip:XYColorCustom';
        else
            action.selectedItem=utils.toolstrip.getXYPlotPreferenceEntries(globalSettings.markers.fillColorOrigin);
        end
    case 'rbXYBorderColorLabel'
        action.enabled=enableMarkerSettings;
    case 'rbXYBorderColorBox'
        action.enabled=enableMarkerSettings;
        if~isempty(globalSettings.markers.borderColor)
            action.selectedItem='record_playback:toolstrip:XYColorCustom';
        else
            action.selectedItem=utils.toolstrip.getXYPlotPreferenceEntries(globalSettings.markers.borderColorOrigin);
        end
    case 'rbXYSizeLabel'
        action.enabled=enableMarkerSettings;
    case 'rbXYMarkerSize'
        action.enabled=enableMarkerSettings;
        action.value=globalSettings.markers.markerSizeInPixels;
    case 'rbXYMarkerFillColor'
        action.enabled=enableMarkerSettings&&~isempty(globalSettings.markers.fillColor);
        action.selectedColor=utils.toolstrip.getColorInHexString(customColors.XYMarkerFillColor);
    case 'rbXYBorderColor'
        action.enabled=enableMarkerSettings&&~isempty(globalSettings.markers.borderColor);
        action.selectedColor=utils.toolstrip.getColorInHexString(customColors.XYMarkerBorderColor);
    case 'rbTrendLineEnable'
        action.selected=enableTrendlineSettings;
        if enableTrendlineSettings
            action.icon='rbToggleTrendLine';
        else
            action.icon='rbToggleTrendLineOFF';
        end
    case 'rbXYTrendLineColorLabel'
        action.enabled=enableTrendlineSettings;
    case 'rbXYTrendlineTypeLabel'
        action.enabled=enableTrendlineSettings;
    case 'rbXYTrendLineType'
        action.enabled=enableTrendlineSettings;
        action.selectedItem=utils.toolstrip.getXYPlotPreferenceEntries(globalSettings.trendLine.trendType);
    case 'rbXYPolynomialOrder'
        enablePolynomialOrder=strcmpi(globalSettings.trendLine.trendType,DAStudio.message('record_playback:params:TrendLinePolynomialModelDef'));
        action.enabled=enablePolynomialOrder;
        action.selectedItem=num2str(globalSettings.trendLine.polynomialOrder);
    case 'rbXYTrendLineColor'
        action.enabled=enableTrendlineSettings;
        action.selectedColor=globalSettings.trendLine.lineColor;
    case 'rbXYThicknessLabel'
        action.enabled=enableTrendlineSettings;
    case 'rbXYThickness'
        action.enabled=enableTrendlineSettings;
        action.value=globalSettings.trendLine.thicknessInPixels;
    case 'rbXYHorizontal'
        if strcmpi(globalSettings.gridDisplay,DAStudio.message('record_playback:params:ShowModelDef'))...
            ||strcmp(globalSettings.gridDisplay,DAStudio.message('record_playback:params:HorizontalModelDef'))
            action.selected=1;
            action.icon='rbHorizontalGrid';
        else
            action.selected=0;
            action.icon='rbHorizontalGridOFF';
        end
    case 'rbXYVertical'
        if strcmpi(globalSettings.gridDisplay,DAStudio.message('record_playback:params:ShowModelDef'))...
            ||strcmp(globalSettings.gridDisplay,DAStudio.message('record_playback:params:VerticalModelDef'))
            action.selected=1;
            action.icon='rbVerticalGrid';
        else
            action.selected=0;
            action.icon='rbVerticalGridOFF';
        end
    case 'rbXYAutoLimit'
        if~isempty(localXYPref)
            action.selected=localXYPref.isAutoLimits;
        end
    case 'rbXYxMin'
        if~isempty(localXYPref)
            if localXYPref.isAutoLimits
                action.enabled=false;
            else
                action.enabled=true;
            end

            action.text=num2str(localXYPref.limits(1));
        end
    case 'rbXYxMax'
        if~isempty(localXYPref)
            if localXYPref.isAutoLimits
                action.enabled=false;
            else
                action.enabled=true;
            end

            action.text=num2str(localXYPref.limits(2));
        end
    case 'rbXYyMin'
        if~isempty(localXYPref)
            if localXYPref.isAutoLimits
                action.enabled=false;
            else
                action.enabled=true;
            end

            action.text=num2str(localXYPref.limits(3));
        end
    case 'rbXYyMax'
        if~isempty(localXYPref)
            if localXYPref.isAutoLimits
                action.enabled=false;
            else
                action.enabled=true;
            end

            action.text=num2str(localXYPref.limits(4));
        end
    otherwise
    end
end
