function schema=rbXYPlotTabCB(fncname,cbinfo,eventData)


    fnc=str2func(fncname);

    if nargout(fnc)
        schema=fnc(cbinfo);
    else
        schema=[];
        if nargin==3
            fnc(cbinfo,eventData);
        else
            fnc(cbinfo);
        end
    end
end

function rbXYTickLabelColorCB(cbinfo)
    pref=get_param(cbinfo.uiObject.Handle,'PlotPreferences');
    pref.XY.TicksColor=utils.toolstrip.getColorAsMxArrayFromHexStr(cbinfo.EventData);
    set_param(cbinfo.uiObject.Handle,'PlotPreferences',pref);
end

function rbXYPlotAreaColorCB(cbinfo)
    pref=get_param(cbinfo.uiObject.Handle,'PlotPreferences');
    pref.XY.PlotColor=utils.toolstrip.getColorAsMxArrayFromHexStr(cbinfo.EventData);
    set_param(cbinfo.uiObject.Handle,'PlotPreferences',pref);
end

function rbXYGridColorCB(cbinfo)
    pref=get_param(cbinfo.uiObject.Handle,'PlotPreferences');
    pref.XY.GridColor=utils.toolstrip.getColorAsMxArrayFromHexStr(cbinfo.EventData);
    set_param(cbinfo.uiObject.Handle,'PlotPreferences',pref);
end

function rbXYLineActionCB(cbinfo)
    pref=get_param(cbinfo.uiObject.Handle,'PlotPreferences');
    if cbinfo.EventData
        pref.XY.Line=DAStudio.message('record_playback:params:Show');
    else
        pref.XY.Line=DAStudio.message('record_playback:params:Hide');
    end
    set_param(cbinfo.uiObject.Handle,'PlotPreferences',pref);
end

function rbXYLineColorBoxCB(cbinfo)
    pref=get_param(cbinfo.uiObject.Handle,'PlotPreferences');
    newColor=cbinfo.EventData;
    switch newColor
    case 'record_playback:toolstrip:XAxisColor'
        newColor=DAStudio.message('record_playback:params:XColor');
    case 'record_playback:toolstrip:YAxisColor'
        newColor=DAStudio.message('record_playback:params:YColor');
    case 'record_playback:toolstrip:XYColorCustom'
        customColors=get_param(cbinfo.uiObject.Handle,'CustomColors');
        newColor=customColors.XYLineColor;
    end
    pref.XY.LineColor=newColor;
    set_param(cbinfo.uiObject.Handle,'PlotPreferences',pref);
end

function rbXYLineColorCB(cbinfo)
    XYLineCustomColor=utils.toolstrip.getColorAsMxArrayFromHexStr(cbinfo.EventData);
    customColors=get_param(cbinfo.uiObject.Handle,'CustomColors');
    customColors.XYLineColor=XYLineCustomColor;
    set_param(cbinfo.uiObject.Handle,'CustomColors',customColors);
    pref=get_param(cbinfo.uiObject.Handle,'PlotPreferences');

    if~ischar(pref.XY.LineColor)
        pref.XY.LineColor=XYLineCustomColor;
        set_param(cbinfo.uiObject.Handle,'PlotPreferences',pref);
    end
end

function rbXYMarkersCB(cbinfo)
    pref=get_param(cbinfo.uiObject.Handle,'PlotPreferences');
    if cbinfo.EventData
        pref.XY.Markers=DAStudio.message('record_playback:params:Show');
    else
        pref.XY.Markers=DAStudio.message('record_playback:params:Hide');
    end
    set_param(cbinfo.uiObject.Handle,'PlotPreferences',pref);
end

function rbXYBorderColorBoxCB(cbinfo)
    pref=get_param(cbinfo.uiObject.Handle,'PlotPreferences');
    newColor=cbinfo.EventData;
    switch newColor
    case 'record_playback:toolstrip:XAxisColor'
        newColor=DAStudio.message('record_playback:params:XColor');
    case 'record_playback:toolstrip:YAxisColor'
        newColor=DAStudio.message('record_playback:params:YColor');
    case 'record_playback:toolstrip:XYColorCustom'
        customColors=get_param(cbinfo.uiObject.Handle,'CustomColors');
        newColor=customColors.XYMarkerBorderColor;
    end
    pref.XY.MarkerBorder=newColor;
    set_param(cbinfo.uiObject.Handle,'PlotPreferences',pref);
end

function rbXYBorderColorCB(cbinfo)
    XYMarkerBorderColor=utils.toolstrip.getColorAsMxArrayFromHexStr(cbinfo.EventData);
    customColors=get_param(cbinfo.uiObject.Handle,'CustomColors');
    customColors.XYMarkerBorderColor=XYMarkerBorderColor;
    set_param(cbinfo.uiObject.Handle,'CustomColors',customColors);
    pref=get_param(cbinfo.uiObject.Handle,'PlotPreferences');

    if~ischar(pref.XY.MarkerBorder)
        pref.XY.MarkerBorder=XYMarkerBorderColor;
        set_param(cbinfo.uiObject.Handle,'PlotPreferences',pref);
    end
end

function rbXYFillColorBoxCB(cbinfo)
    pref=get_param(cbinfo.uiObject.Handle,'PlotPreferences');
    newColor=cbinfo.EventData;
    switch newColor
    case 'record_playback:toolstrip:XAxisColor'
        newColor=DAStudio.message('record_playback:params:XColor');
    case 'record_playback:toolstrip:YAxisColor'
        newColor=DAStudio.message('record_playback:params:YColor');
    case 'record_playback:toolstrip:XYColorCustom'
        customColors=get_param(cbinfo.uiObject.Handle,'CustomColors');
        newColor=customColors.XYMarkerFillColor;
    end
    pref.XY.MarkerFill=newColor;
    set_param(cbinfo.uiObject.Handle,'PlotPreferences',pref);
end

function rbXYMarkerFillColorCB(cbinfo)
    XYMarkerFillColor=utils.toolstrip.getColorAsMxArrayFromHexStr(cbinfo.EventData);
    customColors=get_param(cbinfo.uiObject.Handle,'CustomColors');
    customColors.XYMarkerFillColor=XYMarkerFillColor;
    set_param(cbinfo.uiObject.Handle,'CustomColors',customColors);
    pref=get_param(cbinfo.uiObject.Handle,'PlotPreferences');

    if~ischar(pref.XY.MarkerFill)
        pref.XY.MarkerFill=XYMarkerFillColor;
        set_param(cbinfo.uiObject.Handle,'PlotPreferences',pref);
    end
end

function rbXYSizeCB(cbinfo)
    pref=get_param(cbinfo.uiObject.Handle,'PlotPreferences');
    pref.XY.MarkerSize=cbinfo.EventData;
    set_param(cbinfo.uiObject.Handle,'PlotPreferences',pref);
end

function rbTrendLineCB(cbinfo)
    pref=get_param(cbinfo.uiObject.Handle,'PlotPreferences');
    if cbinfo.EventData
        pref.XY.TrendLine=DAStudio.message('record_playback:params:Show');
    else
        pref.XY.TrendLine=DAStudio.message('record_playback:params:Hide');
    end
    set_param(cbinfo.uiObject.Handle,'PlotPreferences',pref);
end

function rbXYTrendLineTypeBoxCB(cbinfo)
    pref=get_param(cbinfo.uiObject.Handle,'PlotPreferences');
    lineType=cbinfo.EventData;
    switch lineType
    case 'record_playback:toolstrip:XYTrendLineLinear'
        lineType=DAStudio.message('record_playback:params:TrendLineLinear');
    case 'record_playback:toolstrip:XYTrendLineLogarithmic'
        lineType=DAStudio.message('record_playback:params:TrendLineLogarithmic');
    case 'record_playback:toolstrip:XYTrendLinePolynomial'
        lineType=DAStudio.message('record_playback:params:TrendLinePolynomial');
    case 'record_playback:toolstrip:XYTrendLineExponential'
        lineType=DAStudio.message('record_playback:params:TrendLineExponential');
    case 'record_playback:toolstrip:XYTrendLinePower'
        lineType=DAStudio.message('record_playback:params:TrendLinePower');
    end
    pref.XY.TrendLineType=lineType;
    set_param(cbinfo.uiObject.Handle,'PlotPreferences',pref);
end

function rbXYPolynomialOrderCB(cbinfo)
    pref=get_param(cbinfo.uiObject.Handle,'PlotPreferences');
    pref.XY.PolynomialOrder=str2double(cbinfo.EventData);
    set_param(cbinfo.uiObject.Handle,'PlotPreferences',pref);
end

function rbXYThicknessCB(cbinfo)
    pref=get_param(cbinfo.uiObject.Handle,'PlotPreferences');
    pref.XY.TrendLineWeight=cbinfo.EventData;
    set_param(cbinfo.uiObject.Handle,'PlotPreferences',pref);
end

function rbXYTrendLineColorCB(cbinfo)
    trendLineColor=utils.toolstrip.getColorAsMxArrayFromHexStr(cbinfo.EventData);
    pref=get_param(cbinfo.uiObject.Handle,'PlotPreferences');
    pref.XY.TrendLineColor=trendLineColor;
    set_param(cbinfo.uiObject.Handle,'PlotPreferences',pref);
end

function rbXYHorizontalCB(cbinfo)
    pref=get_param(cbinfo.uiObject.Handle,'PlotPreferences');
    enableHorizontalGrid=cbinfo.EventData;
    newGridDisplay=DAStudio.message('record_playback:params:Horizontal');
    currentDisplay=pref.XY.GridLines;
    if strcmp(currentDisplay,DAStudio.message('record_playback:params:On'))
        assert(~enableHorizontalGrid);
        newGridDisplay=DAStudio.message('record_playback:params:Vertical');
    elseif strcmp(currentDisplay,DAStudio.message('record_playback:params:Horizontal'))
        assert(~enableHorizontalGrid);
        newGridDisplay=DAStudio.message('record_playback:params:Off');
    elseif strcmp(currentDisplay,DAStudio.message('record_playback:params:Vertical'))
        assert(enableHorizontalGrid);
        newGridDisplay=DAStudio.message('record_playback:params:On');
    end

    pref.XY.GridLines=newGridDisplay;
    set_param(cbinfo.uiObject.Handle,'PlotPreferences',pref);
end

function rbXYVerticalCB(cbinfo)
    pref=get_param(cbinfo.uiObject.Handle,'PlotPreferences');
    enableVerticalGrid=cbinfo.EventData;
    newGridDisplay=DAStudio.message('record_playback:params:Vertical');
    currentDisplay=pref.XY.GridLines;
    if strcmp(currentDisplay,DAStudio.message('record_playback:params:On'))
        assert(~enableVerticalGrid);
        newGridDisplay=DAStudio.message('record_playback:params:Horizontal');
    elseif strcmp(currentDisplay,DAStudio.message('record_playback:params:Horizontal'))
        assert(enableVerticalGrid);
        newGridDisplay=DAStudio.message('record_playback:params:On');
    elseif strcmp(currentDisplay,DAStudio.message('record_playback:params:Vertical'))
        assert(~enableVerticalGrid);
        newGridDisplay=DAStudio.message('record_playback:params:Off');
    end

    pref.XY.GridLines=newGridDisplay;
    set_param(cbinfo.uiObject.Handle,'PlotPreferences',pref);
end


function selectedPlotID=getSelectedPlotID(blockHdl)
    view=get_param(blockHdl,'View');
    selectedPlotID=view.selectedPlotID;
end

function rbXYAutoLimitCB(cbinfo)
    pref=get_param(cbinfo.uiObject.Handle,'PlotPreferences');
    for idx=1:numel(pref.XY.LocalXYSettings)
        subplotID=pref.XY.LocalXYSettings(idx).SubPlotID;
        if subplotID==getSelectedPlotID(cbinfo.uiObject.Handle)
            pref.XY.LocalXYSettings(idx).isAutoLimits=cbinfo.EventData;
        end
    end

    set_param(cbinfo.uiObject.Handle,'PlotPreferences',pref);
end

function rbXYxMinCB(cbinfo)
    selectedPlotID=getSelectedPlotID(cbinfo.uiObject.Handle);
    localXYPrefs=Simulink.record.internal.getLocalXYSettings(cbinfo.uiObject.Handle,selectedPlotID);
    xMin=str2double(cbinfo.EventData);
    Simulink.record.internal.verifyAxisLimits(xMin,localXYPrefs.limits(2),cbinfo.uiObject.Handle,selectedPlotID);
    localXYPrefs.limits(1)=xMin;
    Simulink.record.internal.setXYPrefLocalSettings(cbinfo.uiObject.Handle,localXYPrefs);
end

function rbXYxMaxCB(cbinfo)
    selectedPlotID=getSelectedPlotID(cbinfo.uiObject.Handle);
    localXYPrefs=Simulink.record.internal.getLocalXYSettings(cbinfo.uiObject.Handle,selectedPlotID);
    xMax=str2double(cbinfo.EventData);
    Simulink.record.internal.verifyAxisLimits(localXYPrefs.limits(1),xMax,cbinfo.uiObject.Handle,selectedPlotID);
    localXYPrefs.limits(2)=xMax;
    Simulink.record.internal.setXYPrefLocalSettings(cbinfo.uiObject.Handle,localXYPrefs);
end

function rbXYyMinCB(cbinfo)
    selectedPlotID=getSelectedPlotID(cbinfo.uiObject.Handle);
    localXYPrefs=Simulink.record.internal.getLocalXYSettings(cbinfo.uiObject.Handle,selectedPlotID);
    yMin=str2double(cbinfo.EventData);
    Simulink.record.internal.verifyAxisLimits(yMin,localXYPrefs.limits(4),cbinfo.uiObject.Handle,selectedPlotID);
    localXYPrefs.limits(3)=yMin;
    Simulink.record.internal.setXYPrefLocalSettings(cbinfo.uiObject.Handle,localXYPrefs);
end

function rbXYyMaxCB(cbinfo)
    selectedPlotID=getSelectedPlotID(cbinfo.uiObject.Handle);
    localXYPrefs=Simulink.record.internal.getLocalXYSettings(cbinfo.uiObject.Handle,selectedPlotID);
    yMax=str2double(cbinfo.EventData);
    Simulink.record.internal.verifyAxisLimits(localXYPrefs.limits(3),yMax,cbinfo.uiObject.Handle,selectedPlotID);
    localXYPrefs.limits(4)=yMax;
    Simulink.record.internal.setXYPrefLocalSettings(cbinfo.uiObject.Handle,localXYPrefs);
end

