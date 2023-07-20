

function dlg=getSlimDialogSchema(obj,~)


    blockHandle=get(obj.blockObj,'handle');
    model=get_param(bdroot(blockHandle),'Name');
    colorJson=obj.getBlock().BackgroundForegroundColor;
    opacity=obj.getBlock().Opacity;
    [obj.BackgroundColor,obj.ForegroundColor]=hmiblockdlg.formatColorStrings(colorJson);
    obj.Icon=get_param(blockHandle,'Icon');
    obj.IconOnColor=get_param(blockHandle,'IconOnColor');
    obj.IconOffColor=get_param(blockHandle,'IconOffColor');


    dlg=obj.getBaseSlimDialogSchema();


    if Simulink.HMI.isLibrary(model)
        labelPosition=0;
    else
        labelPosition=get_param(blockHandle,'LabelPosition');
        labelPosition=simulink.hmi.getLabelPosition(labelPosition);
    end
    buttonTypeValue=get_param(blockHandle,'ButtonType');
    iconAlignmentValue=get_param(blockHandle,'IconAlignment');
    customizeIconColorValue=strcmp(get_param(blockHandle,'IconColor'),'On');


    buttonTextLabel.Type='text';
    buttonTextLabel.Name=DAStudio.message('SimulinkHMI:dialogs:PushButtonText');
    buttonTextLabel.WordWrap=true;
    buttonTextLabel.RowSpan=[1,1];
    buttonTextLabel.ColSpan=[1,3];

    buttonText.Type='edit';
    buttonText.Tag='buttonText';
    buttonText.Value=get_param(blockHandle,'ButtonText');
    buttonText.MatlabMethod='utils.slimDialogUtils.buttonSettingsChanged';
    buttonText.MatlabArgs={'%dialog',obj};
    buttonText.RowSpan=[1,1];
    buttonText.ColSpan=[4,5];


    onValueLabel.Type='text';
    onValueLabel.Name=DAStudio.message('SimulinkHMI:dialogs:PushButtonOnValue');
    onValueLabel.WordWrap=true;
    onValueLabel.RowSpan=[2,2];
    onValueLabel.ColSpan=[1,3];

    onValue.Type='edit';
    onValue.Tag='onValue';
    onValue.Value=num2str(get_param(blockHandle,'OnValue'),16);
    onValue.MatlabMethod='utils.slimDialogUtils.buttonSettingsChanged';
    onValue.MatlabArgs={'%dialog',obj};
    onValue.RowSpan=[2,2];
    onValue.ColSpan=[4,5];


    buttonTypeLabel.Type='text';
    buttonTypeLabel.Tag='buttonTypeLabel';
    buttonTypeLabel.Name=DAStudio.message('SimulinkHMI:dialogs:PushButtonType');
    buttonTypeLabel.Buddy='buttonType';
    buttonTypeLabel.RowSpan=[3,3];
    buttonTypeLabel.ColSpan=[1,3];

    buttonType.Type='combobox';
    buttonType.Tag='buttonType';
    buttonType.Entries={...
    DAStudio.message('SimulinkHMI:dashboardblocks:PushButtonBlockButtonTypeMomentary'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:PushButtonBlockButtonTypeLatch')...
    };
    buttonType.Value=buttonTypeValue;
    buttonType.MatlabMethod='set_param';
    buttonType.MatlabArgs={blockHandle,'ButtonType','%value'};
    buttonType.RowSpan=[3,3];
    buttonType.ColSpan=[4,5];


    legendPositionLabel.Type='text';
    legendPositionLabel.Tag='labelPositionLabel';
    legendPositionLabel.Name=...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionPrompt');
    legendPositionLabel.Buddy='legendPosition';
    legendPositionLabel.RowSpan=[4,4];
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
    legendPosition.RowSpan=[4,4];
    legendPosition.ColSpan=[4,5];


    opacityLabel.Type='text';
    opacityLabel.Tag='opacityLabel';
    opacityLabel.Name=[DAStudio.message('SimulinkHMI:dialogs:DashboardBlockOpacityPrompt'),':'];
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


    colorsHtmlPath='toolbox/simulink/hmi/web/Dialogs/SignalDialog/ForegroundBackgroundColors.html';
    colorWebbrowser=hmiblockdlg.createColorBrowserStructure(obj,colorsHtmlPath,true);
    colorWebbrowser.PreferredSize=[100,155];
    colorWebbrowser.RowSpan=[2,2];
    colorWebbrowser.ColSpan=[1,5];


    iconBrowser.Type='webbrowser';
    iconBrowser.RowSpan=[1,1];
    iconBrowser.ColSpan=[1,5];
    url=strcat('toolbox/simulink/hmi/web/Dialogs/SignalDialog/PushButtonDialog.html?widgetID=',obj.widgetId,...
    '&model=',model,'&isLibWidget=',num2str(obj.isLibWidget),'&isSlimDialog=',num2str(true),'&IsCoreBlock=','1');
    iconBrowser.Url=Simulink.HMI.ConnectorAPI.getAPI().getURL(url);
    iconBrowser.PreferredSize=[200,200];
    iconBrowser.Tag='pushButton_icon_browser';
    iconBrowser.DisableContextMenu=true;
    iconBrowser.Enabled=~((Simulink.HMI.isLibrary(model))||(utils.isLockedLibrary(model)));


    iconAlignmentLabel.Type='text';
    iconAlignmentLabel.Tag='iconAlignmentLabelLabel';
    iconAlignmentLabel.Name=DAStudio.message('SimulinkHMI:dialogs:PushButtonIconAlignment');
    iconAlignmentLabel.Buddy='iconAlignmentLabel';
    iconAlignmentLabel.RowSpan=[2,2];
    iconAlignmentLabel.ColSpan=[1,3];

    iconAlignment.Type='combobox';
    iconAlignment.Tag='iconAlignment';
    iconAlignment.Entries={...
    DAStudio.message('SimulinkHMI:dashboardblocks:PushButtonBlockIconAlignmentLeft'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:PushButtonBlockIconAlignmentRight'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:PushButtonBlockIconAlignmentTop'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:PushButtonBlockIconAlignmentBottom'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:PushButtonBlockIconAlignmentCenter')
    };
    iconAlignment.Value=iconAlignmentValue;
    iconAlignment.MatlabMethod='set_param';
    iconAlignment.MatlabArgs={blockHandle,'IconAlignment','%value'};
    iconAlignment.RowSpan=[2,2];
    iconAlignment.ColSpan=[4,5];


    customizeIconColor.Type='checkbox';
    customizeIconColor.Tag='CustomizeIconColor';
    customizeIconColor.Name=DAStudio.message('SimulinkHMI:dialogs:PushButtonCustomizeIconColor');
    customizeIconColor.Source=obj;
    customizeIconColor.Value=customizeIconColorValue;
    customizeIconColor.MatlabMethod='utils.slimDialogUtils.changePushButtonCustomizeIconColor';
    customizeIconColor.MatlabArgs={'%dialog',blockHandle,'%value',true};
    customizeIconColor.RowSpan=[3,3];
    customizeIconColor.ColSpan=[1,5];


    iconColorHtmlPath='toolbox/simulink/hmi/web/Dialogs/SignalDialog/ForegroundBackgroundColors.html';
    iconColorWebbrowser=hmiblockdlg.createColorBrowserStructure(obj,iconColorHtmlPath,true,{'ForegroundColor=PushButtonIconOnColor','BackgroundColor=PushButtonIconOffColor'});
    iconColorWebbrowser.Tag='icon_color_webbrowser';
    iconColorWebbrowser.PreferredSize=[100,155];
    iconColorWebbrowser.RowSpan=[4,4];
    iconColorWebbrowser.ColSpan=[1,5];
    iconColorWebbrowser.Enabled=customizeIconColorValue;


    mainPanel.Type='togglepanel';
    mainPanel.Name=DAStudio.message('SimulinkHMI:dialogs:GaugeBlockMainGroup');
    mainPanel.Expand=true;
    mainPanel.Items={buttonTextLabel,buttonText,...
    onValueLabel,onValue,...
    buttonTypeLabel,buttonType,...
    legendPositionLabel,legendPosition};
    numMainItems=length(mainPanel.Items);
    mainPanel.LayoutGrid=[numMainItems+1,5];
    mainPanel.RowStretch(1:numMainItems)=0;
    mainPanel.RowStretch(end+1)=1;
    mainPanel.ColStretch=[0,0,0,0,1];
    mainPanel.RowSpan=[2,2];
    mainPanel.ColSpan=[1,5];


    formatPanel.Type='togglepanel';
    formatPanel.Name=DAStudio.message('SimulinkHMI:dialogs:GaugeBlockFormatGroup');
    formatPanel.Items={opacityLabel,opacityCB,colorWebbrowser};
    numColorItems=length(formatPanel.Items);
    formatPanel.LayoutGrid=[numColorItems,5];
    formatPanel.RowStretch(1:numColorItems)=0;
    formatPanel.RowStretch(numColorItems)=1;
    formatPanel.ColStretch=[0,0,0,0,1];
    formatPanel.RowSpan=[3,3];
    formatPanel.ColSpan=[1,5];
    formatPanel.Expand=true;


    iconPanel.Type='togglepanel';
    iconPanel.Name=DAStudio.message('SimulinkHMI:dialogs:PushButtonIcon');
    iconPanel.Items={iconBrowser,iconAlignmentLabel,iconAlignment,customizeIconColor,iconColorWebbrowser};
    numIconItems=length(iconPanel.Items);
    iconPanel.LayoutGrid=[numIconItems,5];
    iconPanel.RowStretch(1:numIconItems)=0;
    iconPanel.RowStretch(numIconItems)=1;
    iconPanel.ColStretch=[0,0,0,0,1];
    iconPanel.RowSpan=[5,5];
    iconPanel.ColSpan=[1,5];
    iconPanel.Expand=true;


    signalPanel.Type='togglepanel';
    signalPanel.Name=DAStudio.message('SimulinkHMI:dialogs:GaugeBlockSignalTitle');
    signalPanel.Items=dlg.Items;
    signalPanel.Expand=true;
    signalPanel.LayoutGrid=[1,5];
    signalPanel.RowStretch=[1];
    signalPanel.ColStretch=[0,0,0,0,1];
    signalPanel.RowSpan=[1,1];
    signalPanel.ColSpan=[1,5];


    dlg.Items={signalPanel,mainPanel,formatPanel,iconPanel};
    dlg.LayoutGrid=[5,5];
    dlg.RowStretch=[0,0,0,0,1];
    dlg.ColStretch=[0,0,0,0,1];

end



