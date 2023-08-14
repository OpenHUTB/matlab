


function dlg=getDialogSchema(obj,~)
    blockHandle=get(obj.blockObj,'handle');
    model=get_param(bdroot(blockHandle),'Name');


    type=get_param(blockHandle,'BlockType');
    switch type
    case 'CircularGaugeBlock'
        desc=DAStudio.message('SimulinkHMI:dialogs:CircularGaugeDialogDesc');
        name=DAStudio.message('SimulinkHMI:dialogs:CircularGauge');
        helpTag='hmi_gauge';
    case 'SemiCircularGaugeBlock'
        desc=DAStudio.message('SimulinkHMI:dialogs:SemicircularGaugeDialogDesc');
        name=DAStudio.message('SimulinkHMI:dialogs:SemicircularGauge');
        helpTag='hmi_half_gauge';
    case 'QuarterGaugeBlock'
        desc=DAStudio.message('SimulinkHMI:dialogs:NinetydegreeGaugeDialogDesc');
        name=DAStudio.message('SimulinkHMI:dialogs:NinetydegreeGauge');
        helpTag='hmi_quarter_gauge';
    case 'LinearGaugeBlock'
        desc=DAStudio.message('SimulinkHMI:dialogs:LinearGaugeDialogDesc');
        name=DAStudio.message('SimulinkHMI:dialogs:LinearGauge');
        helpTag='hmi_linear_gauge';
    otherwise
        assert(false);
    end


    if Simulink.HMI.isLibrary(model)
        labelPosition=0;
    else
        labelPosition=get_param(blockHandle,'LabelPosition');
        labelPosition=simulink.hmi.getLabelPosition(labelPosition);
    end
    obj.ScaleColors=get_param(blockHandle,'ScaleColors');


    dlg=obj.getBaseDialogSchema();


    text.Type='text';
    text.WordWrap=true;
    text.Name=desc;
    descGroup.Type='group';
    descGroup.Name=name;
    descGroup.Items={text};
    descGroup.RowSpan=[1,1];
    descGroup.ColSpan=[1,3];


    bindingTable=dlg.Items{1};
    bindingTable.RowSpan=[1,1];
    bindingTable.ColSpan=[1,3];
    bindingTable.MinimumSize=[100,110];
    bindingTable.PreferredSize=[100,110];


    minimumValue.Type='edit';
    minimumValue.Tag='minimumValue';
    minimumValue.Name=DAStudio.message('SimulinkHMI:dialogs:MinimumPrompt');
    minimumValue.Value=get_param(blockHandle,'ScaleMin');
    minimumValue.RowSpan=[1,1];
    minimumValue.ColSpan=[1,3];


    maximumValue.Type='edit';
    maximumValue.Tag='maximumValue';
    maximumValue.Name=DAStudio.message('SimulinkHMI:dialogs:MaximumPrompt');
    maximumValue.Value=get_param(blockHandle,'ScaleMax');
    maximumValue.RowSpan=[2,2];
    maximumValue.ColSpan=[1,3];


    tickInterval.Type='edit';
    tickInterval.Tag='tickInterval';
    tickInterval.Name=DAStudio.message('SimulinkHMI:dialogs:TickIntervalPrompt');
    tickInterval.Value=get_param(blockHandle,'TickInterval');
    tickInterval.RowSpan=[3,3];
    tickInterval.ColSpan=[1,3];


    htmlPath='toolbox/simulink/hmi/web/Dialogs/SignalDialog/GaugesScaleColors.html';
    url=[htmlPath,'?widgetID=',obj.widgetId,'&model=',model,...
    '&isLibWidget=',num2str(obj.isLibWidget),'&isSlimDialog=',num2str(false)];
    scColorsBrowser.Url=Simulink.HMI.ConnectorAPI.getAPI().getURL(url);
    scColorsBrowser.Type='webbrowser';
    scColorsBrowser.Tag='gauge_scalecolors_browser';
    scColorsBrowser.DisableContextMenu=true;
    if Simulink.HMI.isLibrary(model)||utils.isLockedLibrary(model)
        scColorsBrowser.Enabled=false;
    else
        scColorsBrowser.Enabled=true;
    end
    scColorsBrowser.RowSpan=[4,4];
    scColorsBrowser.ColSpan=[1,3];
    scColorsBrowser.MinimumSize=[100,160];
    scColorsBrowser.PreferredSize=[100,160];


    legendPosition.Type='combobox';
    legendPosition.Tag='labelPosition';
    legendPosition.Name=...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionPrompt');
    legendPosition.Entries={...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionTop'),...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionBottom'),...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionHide')...
    };
    legendPosition.Value=labelPosition;
    legendPosition.RowSpan=[5,5];
    legendPosition.ColSpan=[1,3];


    if~strcmp(type,'LinearGaugeBlock')
        scaleDirection.Type='combobox';
        scaleDirection.Tag='scaleDirection';
        scaleDirection.Name=...
        DAStudio.message('SimulinkHMI:dialogs:GaugeBlockScaleDirectionPrompt');
        scaleDirection.Entries={...
        DAStudio.message('SimulinkHMI:dashboardblocks:GaugeBlockScaleDirectionClockwise'),...
        DAStudio.message('SimulinkHMI:dashboardblocks:GaugeBlockScaleDirectionCounterclockwise')
        };
        scaleDirection.Value=get_param(blockHandle,'ScaleDirection');
        scaleDirection.RowSpan=[6,6];
        scaleDirection.ColSpan=[1,3];
    end


    opacity=get_param(blockHandle,'Opacity');
    opacityField.Type='edit';
    opacityField.Tag='opacity';
    opacityField.Name=[DAStudio.message('SimulinkHMI:dialogs:DashboardBlockOpacityPrompt'),':'];
    opacityField.Value=opacity;
    opacityField.RowSpan=[1,1];
    opacityField.ColSpan=[1,3];


    colorJson=get_param(blockHandle,'BackgroundForegroundColor');
    [obj.BackgroundColor,obj.ForegroundColor]=hmiblockdlg.formatColorStrings(colorJson);
    fontColor=get_param(blockHandle,'FontColor');
    obj.fontColor="["+fontColor(1)+","+fontColor(2)+","+fontColor(3)+"]";
    colorsHtmlPath='toolbox/simulink/hmi/web/Dialogs/SignalDialog/GaugeBlockColors.html';
    colorWebbrowser=hmiblockdlg.createColorBrowserStructure(obj,colorsHtmlPath,false);
    colorWebbrowser.MinimumSize=[100,170];
    colorWebbrowser.PreferredSize=[100,170];
    colorWebbrowser.RowSpan=[2,2];
    colorWebbrowser.ColSpan=[1,3];




    propGroup.Type='group';
    propGroup.RowSpan=[2,2];
    propGroup.ColSpan=[1,3];
    propGroup.LayoutGrid=[1,3];
    propGroup.RowStretch=[1];
    propGroup.ColStretch=[0,0,1];
    propGroup.Items={bindingTable};


    mainGroup.Type='group';
    mainGroup.Items={minimumValue,maximumValue,...
    tickInterval,legendPosition,scColorsBrowser};
    if~strcmp(type,'LinearGaugeBlock')
        mainGroup.Items=[mainGroup.Items,{scaleDirection}];
    end

    numMainItems=length(mainGroup.Items);
    mainGroup.LayoutGrid=[numMainItems+1,3];
    mainGroup.RowStretch(1:numMainItems)=0;
    mainGroup.RowStretch(end+1)=1;
    mainGroup.ColStretch=[0,0,1];


    mainTab.Name=DAStudio.message('SimulinkHMI:dialogs:GaugeBlockMainGroup');
    mainTab.Items={mainGroup};


    formatGroup.Type='group';
    formatGroup.Items={};
    formatGroup.Items=[formatGroup.Items,{opacityField,colorWebbrowser}];
    numFormatItems=length(formatGroup.Items);
    formatGroup.LayoutGrid=[numFormatItems+1,3];
    formatGroup.RowStretch(1:numFormatItems)=0;
    formatGroup.RowStretch(end+1)=1;
    formatGroup.ColStretch=[0,0,1];


    formatTab.Name=DAStudio.message('SimulinkHMI:dialogs:GaugeBlockFormatGroup');
    formatTab.Items={formatGroup};


    tabContainer.Type='tab';
    tabContainer.Name='tabContainer';
    tabContainer.Tabs={mainTab,formatTab};


    dlg.Items={descGroup,propGroup,tabContainer};

    dlg.AlwaysOnTop=true;
    dlg.ExplicitShow=1;
    dlg.PreApplyMethod='preApplyCB';
    dlg.PreApplyArgs={'%dialog'};
    dlg.PreApplyArgsDT={'handle'};

    dlg.HelpMethod='helpview';
    dlg.HelpArgs={[docroot,'/simulink/helptargets.map'],helpTag};
end
