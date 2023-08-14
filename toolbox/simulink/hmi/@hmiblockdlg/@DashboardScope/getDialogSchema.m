


function dlg=getDialogSchema(obj,~)
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


    obj.PreviousBinding=get(obj.getBlock(),'Binding');


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


    if enabled
        L(1)=Simulink.listener(...
        get_param(mdl,'Object'),...
        'SelectionChangeEvent',...
        @(bd,lo)handleSelectionChange(obj));
        obj.Listeners=L;
    else
        for idx=1:length(obj.listeners)
            delete(obj.listeners(idx));
        end
        obj.listeners=[];
    end


    text.Type='text';
    text.WordWrap=true;
    text.Name=[...
    DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogDesc'),' ',...
    DAStudio.message('SimulinkHMI:dialogs:HMIScopeSelectionInfo')];
    descgroup.Type='group';
    descgroup.Name=DAStudio.message('SimulinkHMI:dialogs:HMIScope');
    descgroup.Items={text};
    descgroup.RowSpan=[1,1];
    descgroup.ColSpan=[1,3];


    webbrowser.Type='webbrowser';
    webbrowser.Tag='scope_dialog';
    url=[...
'toolbox/simulink/hmi/web/Dialogs/ScopeDialog/hmi_scope_dialog.html'...
    ,'?DialogId=',Simulink.HMI.Utils.getAsString(blockHandle)...
    ,'&Model=',Simulink.HMI.Utils.getAsString(modelHandle)...
    ,'&Enabled=',num2str(enabled)...
    ,'&isLibWidedget=',num2str(isLibWidget)...
    ,'&isCoreBlock=1'...
    ,'&isSlimDialog=0'];
    webbrowser.Url=Simulink.HMI.ConnectorAPI.getAPI().getURL(url);
    webbrowser.DisableContextMenu=true;
    webbrowser.MatlabMethod='slDialogUtil';
    webbrowser.MatlabArgs={obj,'sync','%dialog','webbrowser','%tag'};
    webbrowser.RowSpan=[1,1];
    webbrowser.ColSpan=[1,3];
    webbrowser.Enabled=enabled;
    webbrowser.MinimumSize=[250,215];


    timeSpan.Type='edit';
    timeSpan.Tag='ScopeTimeSpan';
    timeSpan.Name=DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogTimeSpan');
    timeSpan.Value=get_param(blockHandle,'TimeSpan');
    timeSpan.RowSpan=[1,1];
    timeSpan.ColSpan=[1,3];


    updateMode.Type='combobox';
    updateMode.Tag='ScopeUpdateMode';
    updateMode.Name=...
    DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogUpdateMode');
    updateMode.Entries={...
    DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogUpdateModeWrap'),...
    DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogUpdateModeScroll')
    };
    updateMode.Value=updateModeValue;
    updateMode.RowSpan=[2,2];
    updateMode.ColSpan=[1,3];


    yLimitsText.Type='text';
    yLimitsText.Name=DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogTickLabelsYAxis');
    yLimitsText.RowSpan=[1,1];
    yLimitsText.ColSpan=[1,1];

    yMinLabel.Type='edit';
    yMinLabel.Tag='yMinLabel';
    yMinLabel.Name=DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogMin');
    yMinLabel.Value=get_param(blockHandle,'Ymin');
    yMinLabel.RowSpan=[1,1];
    yMinLabel.ColSpan=[2,2];

    yMaxLabel.Type='edit';
    yMaxLabel.Tag='yMaxLabel';
    yMaxLabel.Name=DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogMax');
    yMaxLabel.Value=get_param(blockHandle,'Ymax');
    yMaxLabel.RowSpan=[1,1];
    yMaxLabel.ColSpan=[3,3];

    yAxisLimits.Type='panel';
    yAxisLimits.Items={yLimitsText,yMinLabel,yMaxLabel};
    yAxisLimits.RowSpan=[3,3];
    yAxisLimits.ColSpan=[1,3];
    yAxisLimits.LayoutGrid=[1,1];
    yAxisLimits.ColStretch=[0,1];


    normalizeYAxisLimits.Type='checkbox';
    normalizeYAxisLimits.Tag='ScopeNormalizeYAxis';
    normalizeYAxisLimits.Name=DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogNormalizeYAxisLimits');
    normalizeYAxisLimits.Value=strcmpi(get_param(blockHandle,'NormalizeYAxis'),'on');
    normalizeYAxisLimits.RowSpan=[4,4];
    normalizeYAxisLimits.ColSpan=[1,3];


    fitToViewAtStop.Type='checkbox';
    fitToViewAtStop.Tag='FitToViewAtStop';
    fitToViewAtStop.Name=DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogFitAtStop');
    fitToViewAtStop.Value=strcmpi(get_param(blockHandle,'ScaleAtStop'),'on');
    fitToViewAtStop.RowSpan=[5,5];
    fitToViewAtStop.ColSpan=[1,3];


    showInstructionalText.Type='checkbox';
    showInstructionalText.Tag='ShowInstructionalText';
    initialMsg=DAStudio.message('SimulinkHMI:errors:UnboundWidget');
    showInstructionalText.Name=DAStudio.message('SimulinkHMI:dialogs:HMIShowInstructionalText',initialMsg);
    showInstructionalText.Value=strcmpi(get_param(blockHandle,'ShowInitialText'),'on');
    showInstructionalText.RowSpan=[6,6];
    showInstructionalText.ColSpan=[1,3];
    showInstructionalText.Enabled=~isBound;


    mainGroup.Type='group';
    mainGroup.Items={timeSpan,updateMode,yAxisLimits,normalizeYAxisLimits,...
    fitToViewAtStop,showInstructionalText};
    mainGroup.LayoutGrid=[7,1];
    mainGroup.RowStretch=[0,0,0,0,0,0,1];
    mainGroup.ColStretch=[0,1];


    mainTab.Name=DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogMain');
    mainTab.Items={mainGroup};


    ticksPosition.Type='combobox';
    ticksPosition.Tag='ScopeTicksPosition';
    ticksPosition.Name=DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogTicks');
    ticksPosition.Entries={...
    DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogTicksPositionOutside'),...
    DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogTicksPositionInside'),...
    DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogTicksPositionNone')
    };
    ticksPosition.Value=ticksPositionValue;
    ticksPosition.RowSpan=[1,1];
    ticksPosition.ColSpan=[1,3];


    tickLabels.Type='combobox';
    tickLabels.Tag='ScopeTickLabels';
    tickLabels.Name=DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogTickLabels');
    tickLabels.Entries={...
    DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogTickLabelsAll'),...
    DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogTickLabelsTAxis'),...
    DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogTickLabelsYAxis'),...
    DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogTickLabelsNone')
    };
    tickLabels.Value=tickLabelsValue;
    tickLabels.RowSpan=[2,2];
    tickLabels.ColSpan=[1,3];


    legendPosition.Type='combobox';
    legendPosition.Tag='legendPosition';
    legendPosition.Name=...
    DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogLegend');
    legendPosition.Entries={...
    DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogLabelPositionTop'),...
    DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogLabelPositionRight'),...
    DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogLabelPositionInsideTopLegend'),...
    DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogLabelPositionInsideRightLegend'),...
    DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogLabelPositionHide')
    };
    legendPosition.Value=legendPositionValue;
    legendPosition.RowSpan=[3,3];
    legendPosition.ColSpan=[1,3];


    gridText.Type='text';
    gridText.Name=DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogGrid');
    gridText.RowSpan=[1,1];
    gridText.ColSpan=[1,1];

    horizontalGrid.Type='checkbox';
    horizontalGrid.Tag='ScopeHorizontalGrid';
    horizontalGrid.Name=DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogGridHorizontal');
    horizontalGrid.Value=strcmpi(get_param(blockHandle,'Grid'),'Horizontal')||...
    strcmpi(get_param(blockHandle,'Grid'),'All');
    horizontalGrid.RowSpan=[1,1];
    horizontalGrid.ColSpan=[2,2];

    verticalGrid.Type='checkbox';
    verticalGrid.Tag='ScopeVerticalGrid';
    verticalGrid.Name=DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogGridVertical');
    verticalGrid.Value=strcmpi(get_param(blockHandle,'Grid'),'Vertical')||...
    strcmpi(get_param(blockHandle,'Grid'),'All');
    verticalGrid.RowSpan=[1,1];
    verticalGrid.ColSpan=[3,3];

    grid.Type='panel';
    grid.Items={gridText,horizontalGrid,verticalGrid};
    grid.RowSpan=[4,4];
    grid.ColSpan=[1,1];
    grid.LayoutGrid=[1,1];
    grid.ColStretch=[1,1];


    border.Type='checkbox';
    border.Tag='ScopeBorder';
    border.Name=DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogBorder');
    border.Value=strcmpi(get_param(blockHandle,'Border'),'on');
    border.RowSpan=[5,5];
    border.ColSpan=[1,3];


    markers.Type='checkbox';
    markers.Tag='ScopeMarkers';
    markers.Name=DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogMarkers');
    markers.Value=strcmpi(get_param(blockHandle,'Markers'),'on');
    markers.RowSpan=[6,6];
    markers.ColSpan=[1,3];


    displayGroup.Type='group';
    displayGroup.Items={ticksPosition,tickLabels,legendPosition,...
    grid,border,markers};
    displayGroup.LayoutGrid=[7,1];
    displayGroup.RowStretch=[0,0,0,0,0,0,1];
    displayGroup.ColStretch=[0,1];


    displayTab.Name=DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogDisplay');
    displayTab.Items={displayGroup};


    colorsHTMLPath='toolbox/simulink/hmi/web/Dialogs/ScopeDialog/DashboardScopeBlockColors.html';
    colorsWebBrowser=hmiblockdlg.createColorBrowserStructure(obj,colorsHTMLPath,false);
    colorsWebBrowser.PreferredSize=[100,200];
    colorsWebBrowser.RowSpan=[1,1];
    colorsWebBrowser.ColSpan=[1,3];


    styleGroup.Type='group';
    styleGroup.Items={colorsWebBrowser};
    styleGroup.LayoutGrid=[2,1];
    styleGroup.RowStretch=[0,1];
    styleGroup.ColStretch=[0,1];


    styleTab.Name=DAStudio.message('SimulinkHMI:dialogs:HMIScopeDialogStyle');
    styleTab.Items={styleGroup};


    tabContainer.Type='tab';
    tabContainer.Name='tabContainer';
    tabContainer.Tabs={mainTab,displayTab,styleTab};

    dlg.Items={descgroup,webbrowser,tabContainer};
    dlg.IsScrollable=true;
    dlg.IgnoreESCClose=false;
    dlg.AlwaysOnTop=true;
    dlg.ExplicitShow=1;

    dlg.PreApplyMethod='preApplyCB';
    dlg.PreApplyArgs={'%dialog'};
    dlg.PreApplyArgsDT={'handle'};

    dlg.CloseMethod='closeDialogCB';
    dlg.CloseMethodArgs={'%dialog','%closeaction'};
    dlg.CloseMethodArgsDT={'handle','string'};

    dlg.HelpMethod='helpview';
    dlg.HelpArgs={[docroot,'/simulink/helptargets.map'],'hmi_scope'};
end


function handleSelectionChange(obj)
    if isempty(obj.getOpenDialogs(true))

        for idx=1:length(obj.Listeners)
            delete(obj.Listeners(idx));
        end
        obj.Listeners=[];
    else
        blockHandle=get(obj.getBlock(),'handle');
        mdl=get_param(bdroot(blockHandle),'Name');
        isLibWidget=Simulink.HMI.isLibrary(mdl);
        selectedSignals=utils.populateCurrentSelectedSignals(mdl,blockHandle,isLibWidget);
        utils.sendSelectedSignalsToScopeDialog(blockHandle,selectedSignals);
    end
end
