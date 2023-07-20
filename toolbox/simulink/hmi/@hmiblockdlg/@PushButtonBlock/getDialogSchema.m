

function dlg=getDialogSchema(obj,~)


    blockHandle=get(obj.blockObj,'handle');
    model=get_param(bdroot(blockHandle),'Name');
    colorJson=get_param(blockHandle,'BackgroundForegroundColor');
    opacity=get_param(blockHandle,'Opacity');
    [obj.BackgroundColor,obj.ForegroundColor]=hmiblockdlg.formatColorStrings(colorJson);
    obj.Icon=get_param(blockHandle,'Icon');
    obj.IconOnColor=get_param(blockHandle,'IconOnColor');
    obj.IconOffColor=get_param(blockHandle,'IconOffColor');


    dlg=obj.getBaseDialogSchema();


    if Simulink.HMI.isLibrary(model)
        labelPosition=0;
    else
        labelPosition=get_param(blockHandle,'LabelPosition');
        labelPosition=simulink.hmi.getLabelPosition(labelPosition);
    end
    buttonTypeValue=get_param(blockHandle,'ButtonType');
    iconAlignmentValue=get_param(blockHandle,'IconAlignment');
    customizeIconColorValue=strcmp(get_param(blockHandle,'IconColor'),'On');


    text.Type='text';
    desc=[DAStudio.message('SimulinkHMI:dialogs:PushButtonDialogDesc')];
    text.Name=desc;
    text.WordWrap=true;
    descGroup.Type='group';
    descGroup.Name=DAStudio.message('SimulinkHMI:dialogs:PushButton');
    descGroup.Items={text};
    descGroup.RowSpan=[1,1];
    descGroup.ColSpan=[1,3];


    webbrowser=dlg.Items{1};
    webbrowser.RowSpan=[1,1];
    webbrowser.ColSpan=[1,3];


    buttonText.Type='edit';
    buttonText.Tag='buttonText';
    buttonText.Name=DAStudio.message('SimulinkHMI:dialogs:PushButtonText');
    buttonText.Value=get_param(blockHandle,'ButtonText');
    buttonText.RowSpan=[1,1];
    buttonText.ColSpan=[1,3];


    onValue.Type='edit';
    onValue.Tag='onValue';
    onValue.Name=DAStudio.message('SimulinkHMI:dialogs:PushButtonOnValue');
    onValue.Value=num2str(get_param(blockHandle,'OnValue'),16);
    onValue.RowSpan=[2,2];
    onValue.ColSpan=[1,3];


    buttonType.Type='combobox';
    buttonType.Tag='buttonType';
    buttonType.Name=DAStudio.message('SimulinkHMI:dialogs:PushButtonType');
    buttonType.Entries={...
    DAStudio.message('SimulinkHMI:dashboardblocks:PushButtonBlockButtonTypeMomentary'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:PushButtonBlockButtonTypeLatch')...
    };
    buttonType.Value=buttonTypeValue;
    buttonType.RowSpan=[3,3];
    buttonType.ColSpan=[1,3];


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
    legendPosition.RowSpan=[4,4];
    legendPosition.ColSpan=[1,3];


    mainGroup.Type='group';
    mainGroup.Items={buttonText,onValue,buttonType,legendPosition};
    mainGroup.LayoutGrid=[5,1];
    mainGroup.RowStretch=[0,0,0,0,1];
    mainGroup.ColStretch=[0,1];


    mainTab.Name=DAStudio.message('SimulinkHMI:dialogs:GaugeBlockMainGroup');
    mainTab.Items={mainGroup};


    opacityField.Type='edit';
    opacityField.Tag='opacity';
    opacityField.Name=[DAStudio.message('SimulinkHMI:dialogs:DashboardBlockOpacityPrompt'),':'];
    opacityField.Value=opacity;
    opacityField.RowSpan=[1,1];
    opacityField.ColSpan=[1,3];


    colorsHtmlPath='toolbox/simulink/hmi/web/Dialogs/SignalDialog/ForegroundBackgroundColors.html';
    colorWebbrowser=hmiblockdlg.createColorBrowserStructure(obj,colorsHtmlPath,false);
    colorWebbrowser.PreferredSize=[100,155];
    colorWebbrowser.RowSpan=[2,2];
    colorWebbrowser.ColSpan=[1,3];


    formatGroup.Type='group';
    formatGroup.Items={opacityField,colorWebbrowser};
    formatGroup.LayoutGrid=[3,1];
    formatGroup.RowStretch=[0,0,1];
    formatGroup.ColStretch=[0,1];


    formatTab.Name=DAStudio.message('SimulinkHMI:dialogs:GaugeBlockFormatGroup');
    formatTab.Items={formatGroup};


    iconBrowser=dlg.Items{1};
    iconBrowser.RowSpan=[1,1];
    iconBrowser.ColSpan=[1,3];

    url=strcat('toolbox/simulink/hmi/web/Dialogs/SignalDialog/PushButtonDialog.html?widgetID=',obj.widgetId,...
    '&model=',model,'&IsCoreBlock=','1');
    iconBrowser.Url=Simulink.HMI.ConnectorAPI.getAPI().getURL(url);
    iconBrowser.Tag='pushButton_properties_browser';
    iconBrowser.DisableContextMenu=true;
    iconBrowser.Enabled=~((Simulink.HMI.isLibrary(model))||(utils.isLockedLibrary(model)));


    iconAlignment.Type='combobox';
    iconAlignment.Tag='iconAlignment';
    iconAlignment.Name=...
    DAStudio.message('SimulinkHMI:dialogs:PushButtonIconAlignment');
    iconAlignment.Entries={...
    DAStudio.message('SimulinkHMI:dashboardblocks:PushButtonBlockIconAlignmentLeft'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:PushButtonBlockIconAlignmentRight'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:PushButtonBlockIconAlignmentTop'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:PushButtonBlockIconAlignmentBottom'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:PushButtonBlockIconAlignmentCenter')...
    };
    iconAlignment.Value=iconAlignmentValue;
    iconAlignment.RowSpan=[2,2];
    iconAlignment.ColSpan=[1,3];


    customizeIconColor.Type='checkbox';
    customizeIconColor.Tag='customizeIconColor';
    customizeIconColor.Name=[DAStudio.message('SimulinkHMI:dialogs:PushButtonCustomizeIconColor')];
    customizeIconColor.Value=customizeIconColorValue;
    customizeIconColor.MatlabMethod='utils.slimDialogUtils.changePushButtonCustomizeIconColor';
    customizeIconColor.MatlabArgs={'%dialog',blockHandle,'%value',false};
    customizeIconColor.RowSpan=[3,3];
    customizeIconColor.ColSpan=[1,3];

    iconColorHtmlPath='toolbox/simulink/hmi/web/Dialogs/SignalDialog/ForegroundBackgroundColors.html';
    iconColorWebbrowser=hmiblockdlg.createColorBrowserStructure(obj,iconColorHtmlPath,false,{'ForegroundColor=PushButtonIconOnColor','BackgroundColor=PushButtonIconOffColor'});
    iconColorWebbrowser.Tag='icon_color_webbrowser';
    iconColorWebbrowser.PreferredSize=[100,155];
    iconColorWebbrowser.RowSpan=[4,4];
    iconColorWebbrowser.ColSpan=[1,3];
    iconColorWebbrowser.Enabled=customizeIconColorValue;


    iconGroup.Type='group';
    iconGroup.Items={iconBrowser,iconAlignment,customizeIconColor,iconColorWebbrowser};
    iconGroup.LayoutGrid=[5,1];
    iconGroup.RowStretch=[0,0,0,0,1];
    iconGroup.ColStretch=[0,1];


    iconTab.Name=DAStudio.message('SimulinkHMI:dialogs:PushButtonIcon');
    iconTab.Items={iconGroup};


    tabContainer.Type='tab';
    tabContainer.Name='tabContainer';
    tabContainer.Tabs={mainTab,formatTab,iconTab};
    dlg.Items={descGroup,webbrowser,tabContainer};
    dlg.IsScrollable=true;
    dlg.IgnoreESCClose=false;

    dlg.AlwaysOnTop=true;
    dlg.ExplicitShow=1;
    dlg.PreApplyMethod='preApplyCB';
    dlg.PreApplyArgs={'%dialog'};
    dlg.PreApplyArgsDT={'handle'};
    dlg.HelpMethod='helpview';
    dlg.HelpArgs={[docroot,'/simulink/helptargets.map'],'hmi_push_button'};

end



