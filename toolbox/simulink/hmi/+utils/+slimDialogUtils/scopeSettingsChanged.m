


function scopeSettingsChanged(dialog,obj,tag)
    if isa(dialog.getSource(),'hmiblockdlg.SDIScope')
        success=locLegacyScopeSettingsChanged(dialog,obj,tag);
    else
        success=locScopeSettingsChanged(dialog,obj,tag);
    end

    dialog.enableApplyButton(false,false);

    if success
        dialog.clearWidgetWithError('ScopeTimeSpan');
        dialog.clearWidgetWithError('yMinLabel');
        dialog.clearWidgetWithError('yMaxLabel');

        dialog.clearWidgetDirtyFlag('ScopeTimeSpan');
        dialog.clearWidgetDirtyFlag('ScopeUpdateMode');
        dialog.clearWidgetDirtyFlag('yMinLabel');
        dialog.clearWidgetDirtyFlag('yMaxLabel');
        dialog.clearWidgetDirtyFlag('ScopeNormalizeYAxis');
        dialog.clearWidgetDirtyFlag('FitToViewAtStop');
        dialog.clearWidgetDirtyFlag('ShowInstructionalText');
        dialog.clearWidgetDirtyFlag('ScopeTicksPosition');
        dialog.clearWidgetDirtyFlag('ScopeTickLabels');
        dialog.clearWidgetDirtyFlag('legendPosition');
        dialog.clearWidgetDirtyFlag('ScopeGrid');
        dialog.clearWidgetDirtyFlag('ScopeBorder');
        dialog.clearWidgetDirtyFlag('ScopeMarkers');
    end
end


function success=locScopeSettingsChanged(dlg,obj,tag)
    success=true;
    blockHandle=get(obj.getBlock(),'handle');

    switch tag
    case{'TimeSpan','yMinLabel','yMaxLabel'}
        timeSpan=strtrim(dlg.getWidgetValue('ScopeTimeSpan'));
        yMin=strtrim(dlg.getWidgetValue('yMinLabel'));
        yMax=strtrim(dlg.getWidgetValue('yMaxLabel'));
        success=hmiblockdlg.DashboardScope.validateAxisLimits(timeSpan,yMin,yMax,dlg,true);
        if~success
            return;
        end
        switch tag
        case 'TimeSpan'
            set_param(blockHandle,'TimeSpan',timeSpan);
        case 'yMinLabel'
            set_param(blockHandle,'Ymin',yMin);
        case 'yMaxLabel'
            set_param(blockHandle,'Ymax',yMax);
        end
    case 'updateMode'
        updateMode=simulink.hmi.getUpdateMode(dlg.getComboBoxText('ScopeUpdateMode'));
        set_param(blockHandle,'UpdateMode',updateMode);
    case 'normalizeYAxis'
        normalizeYAxis=dlg.getWidgetValue('ScopeNormalizeYAxis');
        set_param(blockHandle,'NormalizeYAxis',locLogicalToStr(normalizeYAxis));
    case 'FitToViewAtStop'
        fitToViewAtStop=dlg.getWidgetValue('FitToViewAtStop');
        set_param(blockHandle,'ScaleAtStop',locLogicalToStr(fitToViewAtStop));
    case 'ShowInstructionalText'
        showInitialText=dlg.getWidgetValue('ShowInstructionalText');
        set_param(blockHandle,'ShowInitialText',locLogicalToStr(showInitialText));
    case 'ticksPosition'
        ticksPosition=simulink.hmi.getTicksPosition(dlg.getComboBoxText('ScopeTicksPosition'));
        set_param(blockHandle,'TicksPosition',ticksPosition);
    case 'tickLabels'
        tickLabels=simulink.hmi.getTickLabels(dlg.getComboBoxText('ScopeTickLabels'));
        set_param(blockHandle,'TickLabels',tickLabels);
    case 'legendPosition'
        legendPosition=simulink.hmi.getLegendPosition(dlg.getComboBoxText('legendPosition'));
        set_param(blockHandle,'LegendPosition',legendPosition);
    case{'horizontalGrid','verticalGrid'}
        grid=simulink.hmi.getGrid(dlg.getWidgetValue('ScopeHorizontalGrid'),...
        dlg.getWidgetValue('ScopeVerticalGrid'));
        set_param(blockHandle,'Grid',grid);
    case 'border'
        border=dlg.getWidgetValue('ScopeBorder');
        set_param(blockHandle,'Border',locLogicalToStr(border));
    case 'markers'
        markers=dlg.getWidgetValue('ScopeMarkers');
        set_param(blockHandle,'Markers',locLogicalToStr(markers));
    end
end


function ret=locLogicalToStr(val)
    if val
        ret='on';
    else
        ret='off';
    end
end


function success=locLegacyScopeSettingsChanged(dialog,obj,tag)
    modelHandle=get_param(obj.parent,'Handle');
    mdl=get_param(bdroot(modelHandle),'Name');
    scopeWidget=utils.getWidget(mdl,obj.widgetId,obj.isLibWidget);
    success=false;

    ScopeSettingToUpdate={};


    yMin=dialog.getWidgetValue('yMinLabel');
    yMax=dialog.getWidgetValue('yMaxLabel');
    timeSpan=dialog.getWidgetValue('ScopeTimeSpan');
    fitToViewAtStop=dialog.getWidgetValue('FitToViewAtStop');
    showInitialText=dialog.getWidgetValue('ShowInstructionalText');

    ScopeSettingToUpdate{1}=yMin;
    ScopeSettingToUpdate{2}=yMax;
    ScopeSettingToUpdate{3}=timeSpan;
    ScopeSettingToUpdate{4}=fitToViewAtStop;
    ScopeSettingToUpdate{5}=showInitialText;

    if isequal(tag,'ScopeTimeSpan')||isequal(tag,'yMinLabel')||...
        isequal(tag,'yMaxLabel')
        [success,~]=...
        hmiblockdlg.SDIScope.validateAxisLimits(timeSpan,yMin,yMax,...
        dialog,true);

        if~success
            return;
        end

        if strcmpi(timeSpan,'auto')
            isTimeSpanAuto=true;
            mdlStopTime=get_param(mdl,'StopTime');
            timeSpanStoredInWidget=-1;
            if isvarname(mdlStopTime)||isinf(str2double(mdlStopTime))
                timeSpan=10;
            else
                timeSpan=eval(mdlStopTime);
            end
        else
            isTimeSpanAuto=false;
            timeSpan=eval(timeSpan);
            timeSpanStoredInWidget=timeSpan;
        end
        yMin=eval(yMin);
        yMax=eval(yMax);

        scopeWidget.TimeSpan=timeSpanStoredInWidget;
        scopeWidget.YAxisLimits=[yMin,yMax];

        clientIDs=scopeWidget.ClientID;
        for clientIdx=1:length(clientIDs)
            clientID=clientIDs{clientIdx};
            Simulink.HMI.updateWebClientProperties(clientID,...
            yMin,yMax,isTimeSpanAuto,timeSpan);
        end
    end

    if isequal(tag,'FitToViewAtStop')
        scopeWidget.FitToViewAtStop=fitToViewAtStop;
    end

    if~Simulink.HMI.WebHMI.isBound(get_param(mdl,'Handle'),obj.widgetId,obj.isLibWidget)
        Simulink.HMI.WebHMI.showInitialText(...
        get_param(mdl,'Handle'),obj.widgetId,showInitialText,obj.isLibWidget);
        dialog.setEnabled('ShowInstructionalText',1);
        bShowInitialTextEnabled=true;
    else
        dialog.setEnabled('ShowInstructionalText',0);
        bShowInitialTextEnabled=false;
    end



    ScopeSettingToUpdate{6}=bShowInitialTextEnabled;

    set_param(mdl,'Dirty','on');


    scopeDlgs=obj.getOpenDialogs(true);
    for j=1:length(scopeDlgs)
        if~isequal(dialog,scopeDlgs{j})
            utils.updateScopeSettings(scopeDlgs{j},ScopeSettingToUpdate);
        end
    end
end
