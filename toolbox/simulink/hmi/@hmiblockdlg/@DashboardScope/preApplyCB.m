


function[success,errormsg]=preApplyCB(obj,dlg)
    success=true;
    errormsg='';

    blockHandle=get(obj.getBlock(),'handle');
    mdl=get_param(bdroot(blockHandle),'Name');
    if Simulink.HMI.isLibrary(mdl)
        return
    end


    timeSpan=strtrim(dlg.getWidgetValue('ScopeTimeSpan'));
    updateMode=simulink.hmi.getUpdateMode(dlg.getComboBoxText('ScopeUpdateMode'));
    yMin=strtrim(dlg.getWidgetValue('yMinLabel'));
    yMax=strtrim(dlg.getWidgetValue('yMaxLabel'));
    normalizeYAxis=dlg.getWidgetValue('ScopeNormalizeYAxis');
    fitToViewAtStop=dlg.getWidgetValue('FitToViewAtStop');
    showInitialText=dlg.getWidgetValue('ShowInstructionalText');
    ticksPosition=simulink.hmi.getTicksPosition(dlg.getComboBoxText('ScopeTicksPosition'));
    tickLabels=simulink.hmi.getTickLabels(dlg.getComboBoxText('ScopeTickLabels'));
    legendPosition=simulink.hmi.getLegendPosition(dlg.getComboBoxText('legendPosition'));
    grid=simulink.hmi.getGrid(dlg.getWidgetValue('ScopeHorizontalGrid'),...
    dlg.getWidgetValue('ScopeVerticalGrid'));
    border=dlg.getWidgetValue('ScopeBorder');
    markers=dlg.getWidgetValue('ScopeMarkers');
    foregroundColor=obj.ForegroundColor;
    backgroundColor=obj.BackgroundColor;
    fontColor=obj.FontColor;

    [success,errormsg]=...
    hmiblockdlg.DashboardScope.validateAxisLimits(timeSpan,yMin,yMax,dlg,false);
    if~success
        return;
    end


    set_param(blockHandle,'TimeSpan',timeSpan);
    set_param(blockHandle,'UpdateMode',updateMode);
    set_param(blockHandle,'Ymin',yMin);
    set_param(blockHandle,'Ymax',yMax);
    set_param(blockHandle,'NormalizeYAxis',locLogicalToStr(normalizeYAxis));
    set_param(blockHandle,'ScaleAtStop',locLogicalToStr(fitToViewAtStop));
    set_param(blockHandle,'ShowInitialText',locLogicalToStr(showInitialText));
    set_param(blockHandle,'TicksPosition',ticksPosition);
    set_param(blockHandle,'TickLabels',tickLabels);
    set_param(blockHandle,'LegendPosition',legendPosition);
    set_param(blockHandle,'Grid',grid);
    set_param(blockHandle,'Border',locLogicalToStr(border));
    set_param(blockHandle,'Markers',locLogicalToStr(markers));
    set_param(blockHandle,'ForegroundColor',foregroundColor);
    set_param(blockHandle,'BackgroundColor',backgroundColor);
    set_param(blockHandle,'FontColor',jsondecode(fontColor));


    obj.applyBindingChanges();



    scChannel='/dashboardscopeblockColors/';
    signalDlgs=obj.getOpenDialogs(true);
    for j=1:length(signalDlgs)
        signalDlgs{j}.enableApplyButton(false,false);

        if~isequal(dlg,signalDlgs{j})
            message.publish([scChannel,'updateColors'],...
            {false,obj.widgetId,mdl,backgroundColor,foregroundColor,fontColor});
        end
    end
end


function ret=locLogicalToStr(val)
    if val
        ret='on';
    else
        ret='off';
    end
end
