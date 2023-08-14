



function dlg=getSlimDialogSchema(obj,~)
    blockHandle=get(obj.getBlock(),'handle');
    mdl=get_param(bdroot(blockHandle),'Name');
    modelHandle=get_param(mdl,'Handle');
    ss=get_param(mdl,'SimulationStatus');


    readOnlyDuringSim=false;
    if strcmpi(ss,'external')
        readOnlyDuringSim=true;
    end


    if isempty(obj.getOpenDialogs(true))
        obj.SelectedSignals={};
    end


    updateModeValue=get_param(blockHandle,'UpdateMode');
    switch updateModeValue
    case{DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogUpdateModeWrap'),'Wrap'}
        updateModeValue=0;
    case{DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogUpdateModeScroll'),'Scroll'}
        updateModeValue=1;
    otherwise
        updateModeValue=0;
    end

    ticksPositionValue=get_param(blockHandle,'TicksPosition');
    switch ticksPositionValue
    case 'Outside'
        ticksPositionValue=0;
    case 'Inside'
        ticksPositionValue=1;
    case 'None'
        ticksPositionValue=2;
    end

    tickLabelsValue=get_param(blockHandle,'TickLabels');
    switch tickLabelsValue
    case 'All'
        tickLabelsValue=0;
    case 'T-Axis'
        tickLabelsValue=1;
    case 'Y-Axis'
        tickLabelsValue=2;
    case 'None'
        tickLabelsValue=3;
    end

    legendPositionValue=get_param(blockHandle,'LegendPosition');
    switch legendPositionValue
    case 'Top'
        legendPositionValue=0;
    case 'Right'
        legendPositionValue=1;
    case 'InsideTop'
        legendPositionValue=2;
    case 'InsideRight'
        legendPositionValue=3;
    otherwise
        legendPositionValue=4;
    end

    bgfgColorJSON=get_param(blockHandle,'BackgroundForegroundColor');
    [obj.BackgroundColor,obj.ForegroundColor]=hmiblockdlg.formatColorStrings(bgfgColorJSON);
    fontColor=get_param(blockHandle,'FontColor');
    obj.FontColor="["+fontColor(1)+","+fontColor(2)+","+fontColor(3)+"]";

    isBound=false;
    enabled=true;
    isLibWidget=Simulink.HMI.isLibrary(mdl);
    if isLibWidget||utils.isLockedLibrary(mdl)||readOnlyDuringSim
        enabled=false;
    end


    bindingTableCol.Type='hyperlink';
    bindingTableCol.Tag='bindingTableCol';
    bindingTableCol.RowSpan=[1,1];
    bindingTableCol.ColSpan=[1,5];
    bindingTableCol.MatlabMethod='utils.showBindingUI';
    bindingTableCol.MatlabArgs={blockHandle};
    bindingTableCol.Name=['(',DAStudio.message('SimulinkHMI:dialogs:BindingConnectLinkString'),')'];

    webbrowser.Type='webbrowser';
    webbrowser.Tag='scope_dialog';
    url=[...
'toolbox/simulink/hmi/web/Dialogs/ScopeDialog/hmi_scope_dialog.html'...
    ,'?DialogId=',Simulink.HMI.Utils.getAsString(blockHandle)...
    ,'&Model=',Simulink.HMI.Utils.getAsString(modelHandle)...
    ,'&Enabled=',num2str(enabled)...
    ,'&isLibWidget=',num2str(isLibWidget)...
    ,'&isCoreBlock=1'...
    ,'&isSlimDialog=1'];
    webbrowser.Url=Simulink.HMI.ConnectorAPI.getAPI().getURL(url);
    webbrowser.DisableContextMenu=true;
    webbrowser.MatlabMethod='slDialogUtil';
    webbrowser.MatlabArgs={obj,'sync','%dialog','webbrowser','%tag'};
    webbrowser.RowSpan=[2,2];
    webbrowser.ColSpan=[1,5];
    webbrowser.Enabled=enabled;
    webbrowser.MinimumSize=[250,215];

    bindingPanel.Type='togglepanel';
    bindingPanel.Name=DAStudio.message('SimulinkHMI:dialogs:HMIScopeBindingTableTitle');
    bindingPanel.Items={bindingTableCol,webbrowser};
    bindingPanel.LayoutGrid=[2,5];
    bindingPanel.RowSpan=[1,1];
    bindingPanel.ColSpan=[1,5];
    bindingPanel.Expand=true;


    timeSpan.Type='edit';
    timeSpan.Tag='ScopeTimeSpan';
    timeSpan.Name=DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogTimeSpan');
    timeSpan.MatlabMethod='utils.slimDialogUtils.scopeSettingsChanged';
    timeSpan.MatlabArgs={'%dialog',obj,'TimeSpan'};
    timeSpan.Value=get_param(blockHandle,'TimeSpan');
    timeSpan.RowSpan=[1,1];
    timeSpan.ColSpan=[1,5];


    updateMode.Type='combobox';
    updateMode.Tag='ScopeUpdateMode';
    updateMode.Name=...
    DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogUpdateMode');
    updateMode.MatlabMethod='utils.slimDialogUtils.scopeSettingsChanged';
    updateMode.MatlabArgs={'%dialog',obj,'updateMode'};
    updateMode.Entries={...
    DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogUpdateModeWrap'),...
    DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogUpdateModeScroll')
    };
    updateMode.Value=updateModeValue;
    updateMode.RowSpan=[2,1];
    updateMode.ColSpan=[1,5];


    yLimitsText.Type='text';
    yLimitsText.Name=DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogTickLabelsYAxis');
    yLimitsText.RowSpan=[1,1];
    yLimitsText.ColSpan=[1,1];

    yMinLabel.Type='edit';
    yMinLabel.Tag='yMinLabel';
    yMinLabel.Name=DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogMin');
    yMinLabel.MatlabMethod='utils.slimDialogUtils.scopeSettingsChanged';
    yMinLabel.MatlabArgs={'%dialog',obj,'yMinLabel'};
    yMinLabel.Value=get_param(blockHandle,'Ymin');
    yMinLabel.RowSpan=[1,1];
    yMinLabel.ColSpan=[2,2];

    yMaxLabel.Type='edit';
    yMaxLabel.Tag='yMaxLabel';
    yMaxLabel.Name=DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogMax');
    yMaxLabel.MatlabMethod='utils.slimDialogUtils.scopeSettingsChanged';
    yMaxLabel.MatlabArgs={'%dialog',obj,'yMaxLabel'};
    yMaxLabel.Value=get_param(blockHandle,'Ymax');
    yMaxLabel.RowSpan=[1,1];
    yMaxLabel.ColSpan=[3,3];

    yAxisLimits.Type='panel';
    yAxisLimits.Items={yLimitsText,yMinLabel,yMaxLabel};
    yAxisLimits.RowSpan=[4,1];
    yAxisLimits.ColSpan=[1,5];
    yAxisLimits.LayoutGrid=[1,3];
    yAxisLimits.ColStretch=[0,0,1];


    normalizeYAxisLimits.Type='checkbox';
    normalizeYAxisLimits.Tag='ScopeNormalizeYAxis';
    normalizeYAxisLimits.Name=DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogNormalizeYAxisLimits');
    normalizeYAxisLimits.MatlabMethod='utils.slimDialogUtils.scopeSettingsChanged';
    normalizeYAxisLimits.MatlabArgs={'%dialog',obj,'normalizeYAxis'};
    normalizeYAxisLimits.Value=strcmpi(get_param(blockHandle,'NormalizeYAxis'),'on');
    normalizeYAxisLimits.RowSpan=[5,1];
    normalizeYAxisLimits.ColSpan=[1,5];


    fitToViewAtStop.Type='checkbox';
    fitToViewAtStop.Tag='FitToViewAtStop';
    fitToViewAtStop.Name=DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogFitAtStop');
    fitToViewAtStop.MatlabMethod='utils.slimDialogUtils.scopeSettingsChanged';
    fitToViewAtStop.MatlabArgs={'%dialog',obj,'FitToViewAtStop'};
    fitToViewAtStop.Value=strcmpi(get_param(blockHandle,'ScaleAtStop'),'on');
    fitToViewAtStop.RowSpan=[6,1];
    fitToViewAtStop.ColSpan=[1,5];


    showInstructionalText.Type='checkbox';
    showInstructionalText.Tag='ShowInstructionalText';
    initialMsg=DAStudio.message('SimulinkHMI:errors:UnboundWidget');
    showInstructionalText.Name=DAStudio.message('SimulinkHMI:dialogs:HMIShowInstructionalText',initialMsg);
    showInstructionalText.MatlabMethod='utils.slimDialogUtils.scopeSettingsChanged';
    showInstructionalText.MatlabArgs={'%dialog',obj,'ShowInstructionalText'};
    showInstructionalText.Value=strcmpi(get_param(blockHandle,'ShowInitialText'),'on');
    showInstructionalText.RowSpan=[7,1];
    showInstructionalText.ColSpan=[1,5];
    showInstructionalText.Enabled=~isBound;


    mainGroup.Type='togglepanel';
    mainGroup.Name=DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogMain');
    mainGroup.Items={timeSpan,updateMode,yAxisLimits,...
    normalizeYAxisLimits,fitToViewAtStop,showInstructionalText};
    mainGroup.RowSpan=[2,2];
    mainGroup.ColSpan=[1,5];
    mainGroup.Expand=true;


    ticksPosition.Type='combobox';
    ticksPosition.Tag='ScopeTicksPosition';
    ticksPosition.Name=DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogTicks');
    ticksPosition.MatlabMethod='utils.slimDialogUtils.scopeSettingsChanged';
    ticksPosition.MatlabArgs={'%dialog',obj,'ticksPosition'};
    ticksPosition.Entries={...
    DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogTicksPositionOutside'),...
    DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogTicksPositionInside'),...
    DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogTicksPositionNone')
    };
    ticksPosition.Value=ticksPositionValue;
    ticksPosition.RowSpan=[1,1];
    ticksPosition.ColSpan=[1,5];


    tickLabels.Type='combobox';
    tickLabels.Tag='ScopeTickLabels';
    tickLabels.Name=DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogTickLabels');
    tickLabels.MatlabMethod='utils.slimDialogUtils.scopeSettingsChanged';
    tickLabels.MatlabArgs={'%dialog',obj,'tickLabels'};
    tickLabels.Entries={...
    DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogTickLabelsAll'),...
    DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogTickLabelsTAxis'),...
    DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogTickLabelsYAxis'),...
    DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogTickLabelsNone')
    };
    tickLabels.Value=tickLabelsValue;
    tickLabels.RowSpan=[2,1];
    tickLabels.ColSpan=[1,5];


    legendPosition.Type='combobox';
    legendPosition.Tag='legendPosition';
    legendPosition.Name=...
    DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogLegend');
    legendPosition.MatlabMethod='utils.slimDialogUtils.scopeSettingsChanged';
    legendPosition.MatlabArgs={'%dialog',obj,'legendPosition'};
    legendPosition.Entries={...
    DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogLabelPositionTop'),...
    DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogLabelPositionRight'),...
    DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogLabelPositionInsideTopLegend'),...
    DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogLabelPositionInsideRightLegend'),...
    DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogLabelPositionHide')
    };
    legendPosition.Value=legendPositionValue;
    legendPosition.RowSpan=[3,1];
    legendPosition.ColSpan=[1,5];


    gridText.Type='text';
    gridText.Name=DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogGrid');
    gridText.RowSpan=[1,1];
    gridText.ColSpan=[1,1];

    horizontalGrid.Type='checkbox';
    horizontalGrid.Tag='ScopeHorizontalGrid';
    horizontalGrid.MatlabMethod='utils.slimDialogUtils.scopeSettingsChanged';
    horizontalGrid.MatlabArgs={'%dialog',obj,'horizontalGrid'};
    horizontalGrid.Name=DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogGridHorizontal');
    horizontalGrid.Value=strcmpi(get_param(blockHandle,'Grid'),'Horizontal')||...
    strcmpi(get_param(blockHandle,'Grid'),'All');
    horizontalGrid.RowSpan=[1,1];
    horizontalGrid.ColSpan=[2,2];

    verticalGrid.Type='checkbox';
    verticalGrid.Tag='ScopeVerticalGrid';
    verticalGrid.MatlabMethod='utils.slimDialogUtils.scopeSettingsChanged';
    verticalGrid.MatlabArgs={'%dialog',obj,'verticalGrid'};
    verticalGrid.Name=DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogGridVertical');
    verticalGrid.Value=strcmpi(get_param(blockHandle,'Grid'),'Vertical')||...
    strcmpi(get_param(blockHandle,'Grid'),'All');
    verticalGrid.RowSpan=[1,1];
    verticalGrid.ColSpan=[3,3];

    grid.Type='panel';
    grid.Items={gridText,horizontalGrid,verticalGrid};
    grid.RowSpan=[4,1];
    grid.ColSpan=[1,5];
    grid.LayoutGrid=[1,3];
    grid.ColStretch=[0,0,1];


    border.Type='checkbox';
    border.Tag='ScopeBorder';
    border.Name=DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogBorder');
    border.MatlabMethod='utils.slimDialogUtils.scopeSettingsChanged';
    border.MatlabArgs={'%dialog',obj,'border'};
    border.Value=strcmpi(get_param(blockHandle,'Border'),'on');
    border.RowSpan=[5,1];
    border.ColSpan=[1,5];


    markers.Type='checkbox';
    markers.Tag='ScopeMarkers';
    markers.Name=DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogMarkers');
    markers.MatlabMethod='utils.slimDialogUtils.scopeSettingsChanged';
    markers.MatlabArgs={'%dialog',obj,'markers'};
    markers.Value=strcmpi(get_param(blockHandle,'Markers'),'on');
    markers.RowSpan=[6,1];
    markers.ColSpan=[1,5];


    displayGroup.Type='togglepanel';
    displayGroup.Name=DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogDisplay');
    displayGroup.Items={ticksPosition,tickLabels,legendPosition,grid,border,markers};
    displayGroup.RowSpan=[3,3];
    displayGroup.ColSpan=[1,5];
    displayGroup.Expand=true;


    colorsHTMLPath='toolbox/simulink/hmi/web/Dialogs/ScopeDialog/DashboardScopeBlockColors.html';
    colorsWebBrowser=hmiblockdlg.createColorBrowserStructure(obj,colorsHTMLPath,true);
    colorsWebBrowser.PreferredSize=[100,200];
    colorsWebBrowser.RowSpan=[1,1];
    colorsWebBrowser.ColSpan=[1,1];


    styleGroup.Type='togglepanel';
    styleGroup.Name=DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogStyle');
    styleGroup.Items={colorsWebBrowser};
    styleGroup.RowSpan=[4,4];
    styleGroup.ColSpan=[1,5];
    styleGroup.Expand=true;


    dlg.Items={bindingPanel,mainGroup,displayGroup,styleGroup};
    dlg.DialogTitle='';
    dlg.DialogMode='Slim';
    dlg.DialogRefresh=false;
    dlg.StandaloneButtonSet={''};
    dlg.EmbeddedButtonSet={''};
    dlg.LayoutGrid=[7,5];
    dlg.RowStretch=[0,0,0,0,0,0,1];
    dlg.ColStretch=[0,0,0,0,1];

    dlg.CloseMethod='closeDialogCB';
    dlg.CloseMethodArgs={'%dialog','%closeaction'};
    dlg.CloseMethodArgsDT={'handle','string'};
end
