


function schema=RecordBlockMenu(fncname,cbinfo,eventData)
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

function rbLayoutStackActionCB(cbinfo)
    if cbinfo.EventData
        set_param(cbinfo.uiObject.Handle,'Layout','auto');
    end
end

function rbLayoutSingleActionCB(cbinfo)
    if cbinfo.EventData
        set_param(cbinfo.uiObject.Handle,'Layout','[1 1]');
    end
end

function rbTwoHorizontalActionCB(cbinfo)
    if cbinfo.EventData
        set_param(cbinfo.uiObject.Handle,'Layout','[2 1]');
    end
end

function rbTwoVerticalActionCB(cbinfo)
    if cbinfo.EventData
        set_param(cbinfo.uiObject.Handle,'Layout','[1 2]');
    end
end

function rbFourSquareActionCB(cbinfo)
    if cbinfo.EventData
        set_param(cbinfo.uiObject.Handle,'Layout','[2 2]');
    end
end

function basicLayoutRowTopCB(cbinfo)
    if cbinfo.EventData
        set_param(cbinfo.uiObject.Handle,'Layout','rowTop');
    end
end

function basicLayoutRowRightCB(cbinfo)
    if cbinfo.EventData
        set_param(cbinfo.uiObject.Handle,'Layout','columnRight');
    end
end

function basicLayoutRowBottomCB(cbinfo)
    if cbinfo.EventData
        set_param(cbinfo.uiObject.Handle,'Layout','rowBottom');
    end
end

function basicLayoutRowLeftCB(cbinfo)
    if cbinfo.EventData
        set_param(cbinfo.uiObject.Handle,'Layout','columnLeft');
    end
end

function overlayTopCB(cbinfo)
    if cbinfo.EventData
        set_param(cbinfo.uiObject.Handle,'Layout','overlayTop');
    end
end

function overlayRightCB(cbinfo)
    if cbinfo.EventData
        set_param(cbinfo.uiObject.Handle,'Layout','overlayRight');
    end
end

function overlayBottomCB(cbinfo)
    if cbinfo.EventData
        set_param(cbinfo.uiObject.Handle,'Layout','overlayBottom');
    end
end

function overlayLeftCB(cbinfo)
    if cbinfo.EventData
        set_param(cbinfo.uiObject.Handle,'Layout','overlayLeft');
    end
end

function gridCB(cbinfo)
    if cbinfo.EventData
        modelName=SLStudio.Utils.getModelName(cbinfo);

        dlgHandle=Simulink.record.internal.getGridDialog(modelName,cbinfo.uiObject.Handle);
        dlgHandle.showGridDialog();
    end
end

function customGridCB(userdata,cbinfo)
    set_param(cbinfo.uiObject.Handle,'Layout',userdata);
end

function rbLayoutGridFieldActionCB(cbinfo)
    constant_value=cbinfo.EventData;
    if~isempty(constant_value)&&constant_value(1)=='['&&constant_value(5)==']'
        set_param(cbinfo.uiObject.Handle,'Layout',constant_value);
    end
end

function rbHideShowCursorOnPlot(cbinfo)
    set_param(cbinfo.uiObject.Handle,'ShowCursor',0);
end

function ShowOneCursorOnPlot(cbinfo)
    set_param(cbinfo.uiObject.Handle,'ShowCursor',1);
end

function ShowTwoCursorsOnPlot(cbinfo)
    set_param(cbinfo.uiObject.Handle,'ShowCursor',2);
end

function rbHideShowCursorRF(cbinfo,action)
    if~isempty(cbinfo.uiObject.Handle)&&isequal(cbinfo.uiObject.BlockType,'Record')
        cursorNumber=get_param(cbinfo.uiObject.Handle,'ShowCursor');
        if~cursorNumber
            action.selected=false;
        else
            action.selected=true;
        end
    end
end

function ClearSelectedSubplot(cbinfo)
    set_param(cbinfo.uiObject.Handle,'ClearPlot','selected');
end

function ClearAllSubplots(cbinfo)
    set_param(cbinfo.uiObject.Handle,'ClearPlot','all');
end

function ShowReplayControl(cbinfo)
    if(get_param(cbinfo.uiObject.Handle,'Replay')=='hide')
        set_param(cbinfo.uiObject.Handle,'Replay','show');
    else
        set_param(cbinfo.uiObject.Handle,'Replay','hide');
    end
end

function SetTimePlotTypeCB(~,cbinfo)
    if cbinfo.EventData
        set_param(cbinfo.uiObject.Handle,'PlotType',DAStudio.message('record_playback:params:TimePlot'));
    end
end

function SetXYPlotTypeCB(~,cbinfo)
    if cbinfo.EventData
        set_param(cbinfo.uiObject.Handle,'PlotType',DAStudio.message('record_playback:params:XY'));
    end
end

function SetMapPlotTypeCB(~,cbinfo)
    if cbinfo.EventData
        set_param(cbinfo.uiObject.Handle,'PlotType',DAStudio.message('record_playback:params:Map'));
    end
end

function SetTextEditorPlotTypeCB(~,cbinfo)
    if cbinfo.EventData
        set_param(cbinfo.uiObject.Handle,'PlotType',DAStudio.message('record_playback:params:TextEditor'));
    end
end

function SetSparklinePlotTypeCB(~,cbinfo)
    if cbinfo.EventData
        set_param(cbinfo.uiObject.Handle,'PlotType',DAStudio.message('record_playback:params:Sparkline'));
    end
end

function SetVideoPlotTypeCB(~,cbinfo)
    if cbinfo.EventData
        set_param(cbinfo.uiObject.Handle,'PlotType',DAStudio.message('record_playback:params:Video'));
    end
end

function OpenInNewWindow(cbinfo)
    open_system(cbinfo.uiObject.Handle,'window');
end

function TakeSnapshotCB(cbinfo)
    snapSettings=get_param(cbinfo.uiObject.Handle,'snapshot');

    area='opened';
    if isequal(snapSettings.area,RecordBlkView.SnapshotArea.SELECTED_PLOT)
        area='active';
    end

    sendTo='clipboard';
    path_FileName='plots.png';
    if isequal(snapSettings.sendTo,RecordBlkView.SnapshotSend.IMAGEFILE)
        sendTo='file';
        fileFilter='*.png';
        [filename,pathname]=uiputfile(fileFilter,'Save File');
        path_FileName=fullfile(pathname,filename);
    elseif isequal(snapSettings.sendTo,RecordBlkView.SnapshotSend.MATLABFIGURE)
        sendTo='figure';
    end

    Simulink.record.internal.snapshot('block',cbinfo.uiObject.Handle,'from',area,'to',sendTo,'filename',path_FileName);
end

function CaptureEntirePlotArea(cbinfo)
    snapshot=get_param(cbinfo.uiObject.Handle,'Snapshot');
    snapshot.area=RecordBlkView.SnapshotArea.ENTIRE_PLOT;
    set_param(cbinfo.uiObject.Handle,'Snapshot',snapshot);
end

function CaptureSelectedPlotArea(cbinfo)
    snapshot=get_param(cbinfo.uiObject.Handle,'Snapshot');
    snapshot.area=RecordBlkView.SnapshotArea.SELECTED_PLOT;
    set_param(cbinfo.uiObject.Handle,'Snapshot',snapshot);
end

function SendtoClipboard(cbinfo)
    snapshot=get_param(cbinfo.uiObject.Handle,'Snapshot');
    snapshot.sendTo=RecordBlkView.SnapshotSend.CLIPBOARD;
    set_param(cbinfo.uiObject.Handle,'Snapshot',snapshot);
end

function SendtoImageFile(cbinfo)
    snapshot=get_param(cbinfo.uiObject.Handle,'Snapshot');
    snapshot.sendTo=RecordBlkView.SnapshotSend.IMAGEFILE;
    set_param(cbinfo.uiObject.Handle,'Snapshot',snapshot);
end

function SendtoMATLABFigure(cbinfo)
    snapshot=get_param(cbinfo.uiObject.Handle,'Snapshot');
    snapshot.sendTo=RecordBlkView.SnapshotSend.MATLABFIGURE;
    set_param(cbinfo.uiObject.Handle,'Snapshot',snapshot);
end




function rbNormalizeCB(cbinfo)
    view=get_param(cbinfo.uiObject.Handle,'View');
    selectedSubPlot=view.selectedPlotID;
    Simulink.record.internal.normalize(cbinfo.uiObject.Handle,...
    selectedSubPlot,cbinfo.EventData);
end

function TimeAxisMinValueCB(cbinfo)
    blkPath=cbinfo.uiObject.Handle;
    preferences=get_param(blkPath,'PlotPreferences');
    tMin=str2double(cbinfo.EventData);
    viewInfo=get_param(blkPath,'View');
    Simulink.record.internal.verifyAxisLimits(tMin,preferences.Time.TLimits(2),...
    cbinfo.uiObject.Handle,viewInfo.selectedPlotID);
    preferences.Time.TLimits(1)=tMin;
    set_param(blkPath,'PlotPreferences',preferences);
end

function TimeAxisMaxValueCB(cbinfo)
    blkPath=cbinfo.uiObject.Handle;
    preferences=get_param(blkPath,'PlotPreferences');
    tMax=str2double(cbinfo.EventData);
    viewInfo=get_param(blkPath,'View');
    Simulink.record.internal.verifyAxisLimits(preferences.Time.TLimits(1),tMax,...
    cbinfo.uiObject.Handle,viewInfo.selectedPlotID);
    preferences.Time.TLimits(2)=tMax;
    set_param(blkPath,'PlotPreferences',preferences);
end

function YAxisMinValueCB(cbinfo)
    blkPath=cbinfo.uiObject.Handle;
    preferences=get_param(blkPath,'PlotPreferences');
    viewInfo=get_param(blkPath,'View');
    selectedSubplot=viewInfo.subplots.getByKey(viewInfo.selectedPlotID);
    yMin=str2double(cbinfo.EventData);
    Simulink.record.internal.verifyAxisLimits(yMin,preferences.Time.YLimits(2),...
    cbinfo.uiObject.Handle,viewInfo.selectedPlotID);
    if strcmp(selectedSubplot.visual.visualName,...
        DAStudio.message('record_playback:params:TimePlot'))
        selectedSubplot.visual.yAxisLimits.minimum=yMin;
    end
    preferences.Time.YLimits(1)=yMin;
    set_param(blkPath,'PlotPreferences',preferences);
end

function YAxisMaxValueCB(cbinfo)
    blkPath=cbinfo.uiObject.Handle;
    preferences=get_param(blkPath,'PlotPreferences');
    viewInfo=get_param(blkPath,'View');
    selectedSubplot=viewInfo.subplots.getByKey(viewInfo.selectedPlotID);
    yMax=str2double(cbinfo.EventData);
    Simulink.record.internal.verifyAxisLimits(preferences.Time.YLimits(1),yMax,...
    cbinfo.uiObject.Handle,viewInfo.selectedPlotID);
    if strcmp(selectedSubplot.visual.visualName,...
        DAStudio.message('record_playback:params:TimePlot'))
        selectedSubplot.visual.yAxisLimits.maximum=yMax;
    end

    preferences.Time.YLimits(2)=yMax;
    set_param(blkPath,'PlotPreferences',preferences);
end

function ScaleAtStopCB(cbinfo)
    blkPath=cbinfo.uiObject.Handle;
    preferences=get_param(blkPath,'PlotPreferences');
    preferences.Time.ScaleAtStop=cbinfo.EventData;
    set_param(blkPath,'PlotPreferences',preferences);
end

function TimeSpanCB(cbinfo)
    blkPath=cbinfo.uiObject.Handle;
    preferences=get_param(blkPath,'PlotPreferences');
    timeSpan=str2double(cbinfo.EventData);
    if isnan(timeSpan)
        timeSpan=cbinfo.EventData;
    end
    preferences.Time.TimeSpan=timeSpan;
    set_param(blkPath,'PlotPreferences',preferences);
end

function rbUpdateModeBoxCB(cbinfo)
    pref=get_param(cbinfo.uiObject.Handle,'PlotPreferences');
    newMode=DAStudio.message(cbinfo.EventData);
    switch newMode
    case DAStudio.message('record_playback:toolstrip:WrapMode')
        newMode=DAStudio.message('record_playback:params:Wrap');
    case DAStudio.message('record_playback:toolstrip:ScrollMode')
        newMode=DAStudio.message('record_playback:params:Scroll');
    end
    pref.Time.UpdateMode=newMode;
    set_param(cbinfo.uiObject.Handle,'PlotPreferences',pref);
end

function rbCanvasColorRefresher(cbinfo,action)
    if~isempty(cbinfo.uiObject.Handle)&&isequal(cbinfo.uiObject.BlockType,'Record')
        canvasColor=get_param(cbinfo.uiObject.Handle,'CanvasColor');
        action.selectedColor=utils.toolstrip.getColorInHexString(canvasColor);
    end
end

function rbCanvasColorCB(cbinfo)
    canvasColor=utils.toolstrip.getColorAsMxArrayFromHexStr(cbinfo.EventData);
    set_param(cbinfo.uiObject.Handle,'CanvasColor',canvasColor);
end

function rbTickLabelColorCB(cbinfo)
    pref=get_param(cbinfo.uiObject.Handle,'PlotPreferences');
    pref.Time.TicksColor=utils.toolstrip.getColorAsMxArrayFromHexStr(cbinfo.EventData);
    set_param(cbinfo.uiObject.Handle,'PlotPreferences',pref);
end

function rbPlotAreaColorCB(cbinfo)
    pref=get_param(cbinfo.uiObject.Handle,'PlotPreferences');
    pref.Time.PlotColor=utils.toolstrip.getColorAsMxArrayFromHexStr(cbinfo.EventData);
    set_param(cbinfo.uiObject.Handle,'PlotPreferences',pref);
end

function rbGridColorCB(cbinfo)
    pref=get_param(cbinfo.uiObject.Handle,'PlotPreferences');
    pref.Time.GridColor=utils.toolstrip.getColorAsMxArrayFromHexStr(cbinfo.EventData);
    set_param(cbinfo.uiObject.Handle,'PlotPreferences',pref);
end

function rbTimeTickLocationBoxCB(cbinfo)
    pref=get_param(cbinfo.uiObject.Handle,'PlotPreferences');
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
    pref.Time.TicksPosition=newLocation;
    set_param(cbinfo.uiObject.Handle,'PlotPreferences',pref);
end

function rbTimeLabelBoxCB(cbinfo)
    pref=get_param(cbinfo.uiObject.Handle,'PlotPreferences');
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
    pref.Time.TickLabels=newLabel;
    set_param(cbinfo.uiObject.Handle,'PlotPreferences',pref);
end

function rbTimeLegendBoxCB(cbinfo)
    pref=get_param(cbinfo.uiObject.Handle,'PlotPreferences');
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
    pref.Time.LegendPosition=newLegendPos;
    set_param(cbinfo.uiObject.Handle,'PlotPreferences',pref);
end

function rbHorizontalCB(cbinfo)
    pref=get_param(cbinfo.uiObject.Handle,'PlotPreferences');
    enableHorizontalGrid=cbinfo.EventData;
    newGridDisplay=DAStudio.message('record_playback:params:Horizontal');
    currentDisplay=pref.Time.GridLines;
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

    pref.Time.GridLines=newGridDisplay;
    set_param(cbinfo.uiObject.Handle,'PlotPreferences',pref);
end

function rbVerticalCB(cbinfo)
    pref=get_param(cbinfo.uiObject.Handle,'PlotPreferences');
    enableVerticalGrid=cbinfo.EventData;
    newGridDisplay=DAStudio.message('record_playback:params:Vertical');
    currentDisplay=pref.Time.GridLines;
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

    pref.Time.GridLines=newGridDisplay;

    blockHandle=get_param(cbinfo.uiObject.Handle,'Handle');
    subsystemPath=getfullname(cbinfo.uiObject.Handle);
    [editor,editorDomain]=utils.recordDialogUtils.getEditor(subsystemPath);

    if(~isempty(editorDomain))
        success=utils.recordDialogUtils.setParamWithUndo(editor,editorDomain,...
        @setPlotPrefsWithUndo,{blockHandle,pref,editorDomain});
    else
        locSetParam(cbinfo.uiObject.Handle,pref);
    end
end

function rbMarkersCB(cbinfo)
    pref=get_param(cbinfo.uiObject.Handle,'PlotPreferences');
    if(cbinfo.EventData)
        pref.Time.Markers=DAStudio.message('record_playback:params:Show');
    else
        pref.Time.Markers=DAStudio.message('record_playback:params:Hide');
    end
    set_param(cbinfo.uiObject.Handle,'PlotPreferences',pref);
end

function rbBorderCB(cbinfo)
    pref=get_param(cbinfo.uiObject.Handle,'PlotPreferences');
    if(cbinfo.EventData)
        pref.Time.PlotBorder=DAStudio.message('record_playback:params:Show');
    else
        pref.Time.PlotBorder=DAStudio.message('record_playback:params:Hide');
    end
    set_param(cbinfo.uiObject.Handle,'PlotPreferences',pref);
end

function rbStreetCB(cbinfo)
    pref=get_param(cbinfo.uiObject.Handle,'PlotPreferences');
    pref.Map.Type=DAStudio.message('record_playback:params:Street');
    set_param(cbinfo.uiObject.Handle,'PlotPreferences',pref);
end

function rbSateliteCB(cbinfo)
    pref=get_param(cbinfo.uiObject.Handle,'PlotPreferences');
    pref.Map.Type=DAStudio.message('record_playback:params:Satellite');
    set_param(cbinfo.uiObject.Handle,'PlotPreferences',pref);
end

function rbHelpCB(~)
    helpview('simulink','recordblock');
end

function rbExamplesCB(~)
    helpview('simulink','recordblock_example');
end

function[success,noop]=setPlotPrefsWithUndo(blockHandle,paramVal,editorDomain)
    success=true;
    noop=false;
    try
        editorDomain.paramChangesCommandAddObject(blockHandle);
        locSetParam(blockHandle,paramVal);
    catch
        success=false;
    end
end

function locSetParam(blockHandle,pref)
    set_param(blockHandle,'PlotPreferences',pref);
end


function[domain,modelName,clientID]=getRecordBlockDomain(cbinfo)
    editor=cbinfo.studio.App.getActiveEditor();
    path=Simulink.BlockPath(GLUE2.HierarchyService.getPaths(editor.getCurrentHierarchyId));
    instanceInfo=get_param(cbinfo.uiObject.Handle,'InstanceInfo');

    domain='';
    modelName='';
    clientID='';
    structLen=length(instanceInfo);
    for index=1:structLen
        sfullBlockPath=Simulink.BlockPath(instanceInfo(index).fullBlockPath);
        if sfullBlockPath.isequal(path)
            domain=instanceInfo(index).domain;
            modelName=instanceInfo(index).modelName;
            clientID=instanceInfo(index).clientID;
            break;
        end
    end
end

function rbExportButtonAction(cbinfo)
    [domain,modelName,clientID]=getRecordBlockDomain(cbinfo);
    s=struct('domain',domain,'modelName',modelName,'clientID',clientID);
    res=jsonencode(s);
    set_param(cbinfo.uiObject.Handle,'DisplayExportDialog',res);
end
