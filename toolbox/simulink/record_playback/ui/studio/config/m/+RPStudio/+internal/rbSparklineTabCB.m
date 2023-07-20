function schema=rbSparklineTabCB(fncname,cbinfo,eventData)


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

function selectedPlotID=getSelectedPlotID(blockHdl)
    view=get_param(blockHdl,'View');
    selectedPlotID=view.selectedPlotID;
end

function rbUpdateModeBoxCB(cbinfo)
    sparklinePlotPrefs=Simulink.record.internal.getSparklineSettings(cbinfo.uiObject.Handle,getSelectedPlotID(cbinfo.uiObject.Handle));
    newMode=DAStudio.message(cbinfo.EventData);
    switch newMode
    case DAStudio.message('record_playback:toolstrip:WrapMode')
        newMode=DAStudio.message('record_playback:params:Wrap');
    case DAStudio.message('record_playback:toolstrip:ScrollMode')
        newMode=DAStudio.message('record_playback:params:Scroll');
    end
    sparklinePlotPrefs.UpdateMode=newMode;
    Simulink.record.internal.setSparklineSettings(cbinfo.uiObject.Handle,sparklinePlotPrefs);
end

function rbSPLMinHeightCB(cbinfo)
    sparklinePlotPrefs=Simulink.record.internal.getSparklineSettings(cbinfo.uiObject.Handle,getSelectedPlotID(cbinfo.uiObject.Handle));
    minHeight=cbinfo.EventData;
    sparklinePlotPrefs.minHeight=minHeight;
    Simulink.record.internal.setSparklineSettings(cbinfo.uiObject.Handle,sparklinePlotPrefs);
end

function rbTimeLabelsDisplayCB(cbinfo)
    sparklinePlotPrefs=Simulink.record.internal.getSparklineSettings(cbinfo.uiObject.Handle,getSelectedPlotID(cbinfo.uiObject.Handle));
    labelDisplay=DAStudio.message(cbinfo.EventData);
    switch labelDisplay
    case DAStudio.message('record_playback:toolstrip:SparklineLastLabel')
        labelDisplay=DAStudio.message('record_playback:params:ShowLastSparkline');
    case DAStudio.message('record_playback:toolstrip:SparklineAllLabels')
        labelDisplay=DAStudio.message('record_playback:params:ShowAllSparklines');
    end
    sparklinePlotPrefs.TimeLabelsDisplay=labelDisplay;
    Simulink.record.internal.setSparklineSettings(cbinfo.uiObject.Handle,sparklinePlotPrefs);
end

function rbTickLabelColorCB(cbinfo)
    sparklinePlotPrefs=Simulink.record.internal.getSparklineSettings(cbinfo.uiObject.Handle,getSelectedPlotID(cbinfo.uiObject.Handle));
    sparklinePlotPrefs.TicksColor=utils.toolstrip.getColorAsMxArrayFromHexStr(cbinfo.EventData);
    Simulink.record.internal.setSparklineSettings(cbinfo.uiObject.Handle,sparklinePlotPrefs);
end

function rbPlotAreaColorCB(cbinfo)
    sparklinePlotPrefs=Simulink.record.internal.getSparklineSettings(cbinfo.uiObject.Handle,getSelectedPlotID(cbinfo.uiObject.Handle));
    sparklinePlotPrefs.PlotColor=utils.toolstrip.getColorAsMxArrayFromHexStr(cbinfo.EventData);
    Simulink.record.internal.setSparklineSettings(cbinfo.uiObject.Handle,sparklinePlotPrefs);
end

function rbGridColorCB(cbinfo)
    sparklinePlotPrefs=Simulink.record.internal.getSparklineSettings(cbinfo.uiObject.Handle,getSelectedPlotID(cbinfo.uiObject.Handle));
    sparklinePlotPrefs.GridColor=utils.toolstrip.getColorAsMxArrayFromHexStr(cbinfo.EventData);
    Simulink.record.internal.setSparklineSettings(cbinfo.uiObject.Handle,sparklinePlotPrefs);
end

function rbSPLTickPosBoxCB(cbinfo)
    sparklinePlotPrefs=Simulink.record.internal.getSparklineSettings(cbinfo.uiObject.Handle,getSelectedPlotID(cbinfo.uiObject.Handle));
    newLocation=DAStudio.message(cbinfo.EventData);
    if strcmp(newLocation,DAStudio.message('record_playback:toolstrip:None'))
        newLocation=DAStudio.message('record_playback:params:Hide');
    end

    switch newLocation
    case DAStudio.message('record_playback:toolstrip:TicksOutside')
        newLocation=DAStudio.message('record_playback:params:TickOutside');
    case DAStudio.message('record_playback:toolstrip:TicksInside')
        newLocation=DAStudio.message('record_playback:params:TickInside');
    end
    sparklinePlotPrefs.TicksPosition=newLocation;
    Simulink.record.internal.setSparklineSettings(cbinfo.uiObject.Handle,sparklinePlotPrefs);
end

function rbSPLTimeLabelBoxCB(cbinfo)
    sparklinePlotPrefs=Simulink.record.internal.getSparklineSettings(cbinfo.uiObject.Handle,getSelectedPlotID(cbinfo.uiObject.Handle));
    newLabel=DAStudio.message(cbinfo.EventData);
    switch newLabel
    case DAStudio.message('record_playback:toolstrip:TickLabelsAll')
        newLabel=DAStudio.message('record_playback:params:All');
    case DAStudio.message('record_playback:toolstrip:TickLabelsYAxis')
        newLabel=DAStudio.message('record_playback:params:YAxis');
    case DAStudio.message('record_playback:toolstrip:TimeAxis')
        newLabel=DAStudio.message('record_playback:params:TimeAxis');
    case DAStudio.message('record_playback:toolstrip:None')
        newLabel=DAStudio.message('record_playback:params:None');
    end
    sparklinePlotPrefs.TickLabels=newLabel;
    Simulink.record.internal.setSparklineSettings(cbinfo.uiObject.Handle,sparklinePlotPrefs);
end

function rbTimeLegendBoxCB(cbinfo)
    sparklinePlotPrefs=Simulink.record.internal.getSparklineSettings(cbinfo.uiObject.Handle,getSelectedPlotID(cbinfo.uiObject.Handle));
    newLegendPos=DAStudio.message(cbinfo.EventData);
    switch newLegendPos
    case DAStudio.message('record_playback:toolstrip:TicksLegendOutsideTop')
        newLegendPos=DAStudio.message('record_playback:params:LegendTopLeft');
    case DAStudio.message('record_playback:toolstrip:TicksLegendOutsideRight')
        newLegendPos=DAStudio.message('record_playback:params:LegendOutsideRight');
    case DAStudio.message('record_playback:toolstrip:TicksLegendInsideTop')
        newLegendPos=DAStudio.message('record_playback:params:LegendInsideLeft');
    case DAStudio.message('record_playback:toolstrip:TicksLegendInsideRight')
        newLegendPos=DAStudio.message('record_playback:params:LegendInsideRight');
    case DAStudio.message('record_playback:toolstrip:None')
        newLegendPos=DAStudio.message('record_playback:params:None');
    end
    sparklinePlotPrefs.LegendPosition=newLegendPos;
    Simulink.record.internal.setSparklineSettings(cbinfo.uiObject.Handle,sparklinePlotPrefs);
end

function rbHorizontalCB(cbinfo)
    sparklinePlotPrefs=Simulink.record.internal.getSparklineSettings(cbinfo.uiObject.Handle,getSelectedPlotID(cbinfo.uiObject.Handle));
    enableHorizontalGrid=cbinfo.EventData;
    newGridDisplay=DAStudio.message('record_playback:params:Horizontal');
    currentDisplay=sparklinePlotPrefs.GridLines;
    if strcmp(currentDisplay,DAStudio.message('record_playback:params:All'))
        assert(~enableHorizontalGrid);
        newGridDisplay=DAStudio.message('record_playback:params:Vertical');
    elseif strcmp(currentDisplay,DAStudio.message('record_playback:params:Horizontal'))
        assert(~enableHorizontalGrid);
        newGridDisplay=DAStudio.message('record_playback:params:None');
    elseif strcmp(currentDisplay,DAStudio.message('record_playback:params:Vertical'))
        assert(enableHorizontalGrid);
        newGridDisplay=DAStudio.message('record_playback:params:All');
    end
    sparklinePlotPrefs.GridLines=newGridDisplay;
    Simulink.record.internal.setSparklineSettings(cbinfo.uiObject.Handle,sparklinePlotPrefs);
end

function rbVerticalCB(cbinfo)
    sparklinePlotPrefs=Simulink.record.internal.getSparklineSettings(cbinfo.uiObject.Handle,getSelectedPlotID(cbinfo.uiObject.Handle));
    enableVerticalGrid=cbinfo.EventData;
    newGridDisplay=DAStudio.message('record_playback:params:Vertical');
    currentDisplay=sparklinePlotPrefs.GridLines;
    if strcmp(currentDisplay,DAStudio.message('record_playback:params:All'))
        assert(~enableVerticalGrid);
        newGridDisplay=DAStudio.message('record_playback:params:Horizontal');
    elseif strcmp(currentDisplay,DAStudio.message('record_playback:params:Horizontal'))
        assert(enableVerticalGrid);
        newGridDisplay=DAStudio.message('record_playback:params:All');
    elseif strcmp(currentDisplay,DAStudio.message('record_playback:params:Vertical'))
        assert(~enableVerticalGrid);
        newGridDisplay=DAStudio.message('record_playback:params:None');
    end
    sparklinePlotPrefs.GridLines=newGridDisplay;
    Simulink.record.internal.setSparklineSettings(cbinfo.uiObject.Handle,sparklinePlotPrefs);
end

function rbMarkersCB(cbinfo)
    sparklinePlotPrefs=Simulink.record.internal.getSparklineSettings(cbinfo.uiObject.Handle,getSelectedPlotID(cbinfo.uiObject.Handle));
    if(cbinfo.EventData)
        sparklinePlotPrefs.Markers=DAStudio.message('record_playback:params:Show');
    else
        sparklinePlotPrefs.Markers=DAStudio.message('record_playback:params:Hide');
    end
    Simulink.record.internal.setSparklineSettings(cbinfo.uiObject.Handle,sparklinePlotPrefs);
end

function rbBorderCB(cbinfo)
    sparklinePlotPrefs=Simulink.record.internal.getSparklineSettings(cbinfo.uiObject.Handle,getSelectedPlotID(cbinfo.uiObject.Handle));
    if(cbinfo.EventData)
        sparklinePlotPrefs.PlotBorder=DAStudio.message('record_playback:params:Show');
    else
        sparklinePlotPrefs.PlotBorder=DAStudio.message('record_playback:params:Hide');
    end
    Simulink.record.internal.setSparklineSettings(cbinfo.uiObject.Handle,sparklinePlotPrefs);
end

function TimeSpanCB(cbinfo)
    sparklinePlotPrefs=Simulink.record.internal.getSparklineSettings(cbinfo.uiObject.Handle,getSelectedPlotID(cbinfo.uiObject.Handle));
    timeSpan=str2double(cbinfo.EventData);
    if isnan(timeSpan)
        timeSpan=cbinfo.EventData;
    end
    sparklinePlotPrefs.TimeSpan=timeSpan;
    Simulink.record.internal.setSparklineSettings(cbinfo.uiObject.Handle,sparklinePlotPrefs);

    triggerRefresher(cbinfo.uiObject.Handle,sparklinePlotPrefs);
end

function TimeAxisMinValueCB(cbinfo)
    selectedPlotID=getSelectedPlotID(cbinfo.uiObject.Handle);
    sparklinePlotPrefs=Simulink.record.internal.getSparklineSettings(cbinfo.uiObject.Handle,selectedPlotID);
    tMin=str2double(cbinfo.EventData);
    Simulink.record.internal.verifyAxisLimits(tMin,sparklinePlotPrefs.TLimits(2),cbinfo.uiObject.Handle,selectedPlotID);
    sparklinePlotPrefs.TLimits(1)=tMin;
    Simulink.record.internal.setSparklineSettings(cbinfo.uiObject.Handle,sparklinePlotPrefs);
    triggerRefresher(cbinfo.uiObject.Handle,sparklinePlotPrefs);
end

function TimeAxisMaxValueCB(cbinfo)
    selectedPlotID=getSelectedPlotID(cbinfo.uiObject.Handle);
    sparklinePlotPrefs=Simulink.record.internal.getSparklineSettings(cbinfo.uiObject.Handle,selectedPlotID);
    tMax=str2double(cbinfo.EventData);
    Simulink.record.internal.verifyAxisLimits(sparklinePlotPrefs.TLimits(1),tMax,cbinfo.uiObject.Handle,selectedPlotID);
    sparklinePlotPrefs.TLimits(2)=tMax;
    Simulink.record.internal.setSparklineSettings(cbinfo.uiObject.Handle,sparklinePlotPrefs);
    triggerRefresher(cbinfo.uiObject.Handle,sparklinePlotPrefs);
end

function triggerRefresher(blkHdl,sparklinePlotPrefs)
    viewModel=get_param(blkHdl,'View');
    subPlot=viewModel.subplots.getByKey(sparklinePlotPrefs.SubPlotID);
    subPlot.axesLimitsChanged=subPlot.axesLimitsChanged+1;
end