


function dlg=getSlimDialogSchema(obj,~)
    blockHandle=get(obj.blockObj,'handle');
    model=get_param(bdroot(blockHandle),'Name');


    dlg=obj.getBaseSlimDialogSchema();


    if Simulink.HMI.isLibrary(model)
        labelPosition=0;
    else
        labelPosition=get_param(blockHandle,'LabelPosition');
        labelPosition=simulink.hmi.getLabelPosition(labelPosition);
    end
    obj.ScaleColors=get_param(blockHandle,'ScaleColors');


    minimumValueTxt.Type='text';
    minimumValueTxt.Name=DAStudio.message('SimulinkHMI:dialogs:MinimumPrompt');
    minimumValueTxt.WordWrap=true;
    minimumValueTxt.RowSpan=[1,1];
    minimumValueTxt.ColSpan=[1,3];

    minimumValue.Type='edit';
    minimumValue.Tag='minimumValue';
    minimumValue.Value=get_param(blockHandle,'ScaleMin');
    minimumValue.RowSpan=[1,1];
    minimumValue.ColSpan=[4,5];
    minimumValue.MatlabMethod='utils.slimDialogUtils.gaugeSettingsChanged';
    minimumValue.MatlabArgs={'%dialog',obj};


    maximumValueTxt.Type='text';
    maximumValueTxt.Name=DAStudio.message('SimulinkHMI:dialogs:MaximumPrompt');
    maximumValueTxt.WordWrap=true;
    maximumValueTxt.RowSpan=[2,2];
    maximumValueTxt.ColSpan=[1,3];

    maximumValue.Type='edit';
    maximumValue.Tag='maximumValue';
    maximumValue.Value=get_param(blockHandle,'ScaleMax');
    maximumValue.RowSpan=[2,2];
    maximumValue.ColSpan=[4,5];
    maximumValue.MatlabMethod='utils.slimDialogUtils.gaugeSettingsChanged';
    maximumValue.MatlabArgs={'%dialog',obj};


    tickValueTxt.Type='text';
    tickValueTxt.Name=DAStudio.message('SimulinkHMI:dialogs:TickIntervalPrompt');
    tickValueTxt.WordWrap=true;
    tickValueTxt.RowSpan=[3,3];
    tickValueTxt.ColSpan=[1,3];

    tickValue.Type='edit';
    tickValue.Tag='tickInterval';
    tickValue.Value=get_param(blockHandle,'TickInterval');
    tickValue.RowSpan=[3,3];
    tickValue.ColSpan=[4,5];
    tickValue.MatlabMethod='utils.slimDialogUtils.gaugeSettingsChanged';
    tickValue.MatlabArgs={'%dialog',obj};


    scColorsBrowser.Type='webbrowser';
    scColorsBrowser.RowSpan=[4,4];
    scColorsBrowser.ColSpan=[1,5];
    htmlPath='toolbox/simulink/hmi/web/Dialogs/SignalDialog/GaugesScaleColors.html';
    url=[htmlPath,'?widgetID=',obj.widgetId,'&model=',model,...
    '&isLibWidget=',num2str(obj.isLibWidget),'&isSlimDialog=',num2str(true)];
    scColorsBrowser.Url=Simulink.HMI.ConnectorAPI.getAPI().getURL(url);
    scColorsBrowser.Tag='gauge_scalecolors_browser';
    scColorsBrowser.DisableContextMenu=true;
    if Simulink.HMI.isLibrary(model)||utils.isLockedLibrary(model)
        scColorsBrowser.Enabled=false;
    else
        scColorsBrowser.Enabled=true;
    end



    legendPositionLabel.Type='text';
    legendPositionLabel.Tag='labelPositionLabel';
    legendPositionLabel.Name=...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionPrompt');
    legendPositionLabel.Buddy='legendPosition';
    legendPositionLabel.RowSpan=[5,5];
    legendPositionLabel.ColSpan=[1,3];

    legendPosition.Type='combobox';
    legendPosition.Tag='labelPosition';
    legendPosition.Entries={...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionTop'),...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionBottom'),...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionHide')...
    };
    legendPosition.Value=labelPosition;
    legendPosition.MatlabMethod='utils.slimDialogUtils.labelPositionChanged';
    legendPosition.MatlabArgs={'%dialog',obj};
    legendPosition.RowSpan=[5,5];
    legendPosition.ColSpan=[4,5];


    type=get_param(blockHandle,'BlockType');
    if~strcmp(type,'LinearGaugeBlock')
        scaleDirectionLabel.Type='text';
        scaleDirectionLabel.Tag='scaleDirectionLabel';
        scaleDirectionLabel.Name=...
        DAStudio.message('SimulinkHMI:dialogs:GaugeBlockScaleDirectionPrompt');
        scaleDirectionLabel.Buddy='scaleDirection';
        scaleDirectionLabel.RowSpan=[6,6];
        scaleDirectionLabel.ColSpan=[1,3];

        scaleDirection.Type='combobox';
        scaleDirection.Tag='scaleDirection';
        scaleDirection.Entries={...
        DAStudio.message('SimulinkHMI:dashboardblocks:GaugeBlockScaleDirectionClockwise'),...
        DAStudio.message('SimulinkHMI:dashboardblocks:GaugeBlockScaleDirectionCounterclockwise')
        };
        scaleDirection.Value=get_param(blockHandle,'ScaleDirection');
        scaleDirection.MatlabMethod='set_param';
        scaleDirection.MatlabArgs={blockHandle,'ScaleDirection','%value'};
        scaleDirection.RowSpan=[6,6];
        scaleDirection.ColSpan=[4,5];
    end


    opacity=get_param(blockHandle,'Opacity');
    opacityLabel.Type='text';
    opacityLabel.Tag='opacityLabel';
    opacityLabel.WordWrap=true;
    opacityLabel.Name=...
    [DAStudio.message('SimulinkHMI:dialogs:DashboardBlockOpacityPrompt'),':'];
    opacityLabel.RowSpan=[1,1];
    opacityLabel.ColSpan=[1,3];

    opacityCB.Type='edit';
    opacityCB.Tag='opacity';
    opacityCB.Source=obj;
    opacityCB.Value=opacity;
    opacityCB.MatlabMethod='utils.slimDialogUtils.setDashboardBlockTransparency';
    opacityCB.MatlabArgs={'%dialog','%source','%tag','%value'};
    opacityCB.RowSpan=[1,1];
    opacityCB.ColSpan=[4,5];


    colorJson=obj.getBlock().BackgroundForegroundColor;
    [obj.BackgroundColor,obj.ForegroundColor]=hmiblockdlg.formatColorStrings(colorJson);
    fontColor=get_param(blockHandle,'FontColor');
    obj.fontColor="["+fontColor(1)+","+fontColor(2)+","+fontColor(3)+"]";
    colorsHtmlPath='toolbox/simulink/hmi/web/Dialogs/SignalDialog/GaugeBlockColors.html';
    colorWebbrowser=hmiblockdlg.createColorBrowserStructure(obj,colorsHtmlPath,true);
    colorWebbrowser.RowSpan=[2,2];
    colorWebbrowser.ColSpan=[1,5];


    mainPanel.Type='togglepanel';
    mainPanel.Name=DAStudio.message('SimulinkHMI:dialogs:GaugeBlockMainGroup');
    mainPanel.Expand=true;
    mainPanel.Items={minimumValueTxt,minimumValue,...
    maximumValueTxt,maximumValue,...
    tickValueTxt,tickValue,...
    legendPositionLabel,legendPosition,scColorsBrowser};
    if~strcmp(type,'LinearGaugeBlock')
        mainPanel.Items=[mainPanel.Items,{scaleDirectionLabel,scaleDirection}];
    end
    numMainItems=length(mainPanel.Items);
    mainPanel.LayoutGrid=[numMainItems+1,5];
    mainPanel.RowStretch(1:numMainItems)=0;
    mainPanel.RowStretch(end+1)=1;
    mainPanel.ColStretch=[0,0,0,0,1];
    mainPanel.RowSpan=[2,2];
    mainPanel.ColSpan=[1,5];


    formatPanel.Type='togglepanel';
    formatPanel.Name=DAStudio.message('SimulinkHMI:dialogs:GaugeBlockFormatGroup');
    formatPanel.Items=[{opacityLabel,opacityCB,colorWebbrowser}];
    numColorItems=length(formatPanel.Items);
    formatPanel.LayoutGrid=[numColorItems,5];
    formatPanel.RowStretch(1:numColorItems)=0;
    formatPanel.RowStretch(numColorItems)=1;
    formatPanel.ColStretch=[0,0,0,0,1];
    formatPanel.RowSpan=[3,3];
    formatPanel.ColSpan=[1,5];
    formatPanel.Expand=true;


    signalPanel.Type='togglepanel';
    signalPanel.Name=DAStudio.message('SimulinkHMI:dialogs:GaugeBlockSignalTitle');
    signalPanel.Items=dlg.Items;
    signalPanel.Expand=true;
    signalPanel.LayoutGrid=[1,5];
    signalPanel.RowStretch=[1];
    signalPanel.ColStretch=[0,0,0,0,1];
    signalPanel.RowSpan=[1,1];
    signalPanel.ColSpan=[1,5];


    dlg.Items={signalPanel,mainPanel,formatPanel};
    dlg.LayoutGrid=[3,5];
    dlg.RowStretch=[0,0,1];
    dlg.ColStretch=[0,0,0,0,1];
end
