function dlg=getDialogSchema(obj,~)


    blockHandle=get(obj.blockObj,'handle');
    curFieldValue=get_param(blockHandle,'Value');
    curTextAlign=get_param(blockHandle,'Alignment');
    labelPosition=get_param(blockHandle,'LabelPosition');
    opacity=get_param(blockHandle,'Opacity');
    labelPosition=simulink.hmi.getLabelPosition(labelPosition);
    colorJson=get_param(blockHandle,'BackgroundForegroundColor');
    [obj.BackgroundColor,obj.ForegroundColor]=hmiblockdlg.formatColorStrings(colorJson);


    text.Type='text';
    desc=DAStudio.message('SimulinkHMI:dialogs:EditFieldDialogDesc');
    text.WordWrap=true;
    text.Name=desc;
    descGroup.Type='group';
    descGroup.Name=DAStudio.message('SimulinkHMI:messages:DashboardEditField');
    descGroup.Items={text};
    descGroup.RowSpan=[1,1];
    descGroup.ColSpan=[1,3];


    dlg=obj.getBaseDialogSchema();


    webbrowser=dlg.Items{1};
    webbrowser.RowSpan=[1,1];
    webbrowser.ColSpan=[1,3];

    textAlign.Type='combobox';
    textAlign.Tag='textAlign';
    textAlign.Name=...
    DAStudio.message('SimulinkHMI:messages:DashboardEditFieldAlignmentPrompt');
    textAlign.Entries={...
    DAStudio.message('SimulinkHMI:dashboardblocks:DisplayBlockLeftAlignment'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:DisplayBlockCenterAlignment'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:DisplayBlockRightAlignment')...
    };
    textAlign.Value=utils.getTranslatedAlignment(curTextAlign);
    textAlign.RowSpan=[1,1];
    textAlign.ColSpan=[1,3];


    labelPositionDropDown.Type='combobox';
    labelPositionDropDown.Tag='labelPosition';
    labelPositionDropDown.Name=...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionPrompt');
    labelPositionDropDown.Entries={...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionTop'),...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionBottom'),...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionHide')...
    };
    labelPositionDropDown.Value=labelPosition;
    labelPositionDropDown.RowSpan=[2,2];
    labelPositionDropDown.ColSpan=[1,3];


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


    mainGroup.Type='group';
    mainGroup.Items={textAlign,labelPositionDropDown};
    mainGroup.LayoutGrid=[3,3];
    mainGroup.RowStretch=[0,0,1];
    mainGroup.ColStretch=[0,0,1];


    formatGroup.Type='group';
    formatGroup.Items={opacityField,colorWebbrowser};
    formatGroup.LayoutGrid=[3,3];
    formatGroup.RowStretch=[0,0,1];
    formatGroup.ColStretch=[0,0,1];


    mainTab.Name=DAStudio.message('SimulinkHMI:dialogs:GaugeBlockMainGroup');
    mainTab.Items={mainGroup};


    formatTab.Name=DAStudio.message('SimulinkHMI:dialogs:GaugeBlockFormatGroup');
    formatTab.Items={formatGroup};


    tabContainer.Type='tab';
    tabContainer.Name='tabContainer';
    tabContainer.Tabs={mainTab,formatTab};

    dlg.Items={descGroup,webbrowser,tabContainer};

    dlg.AlwaysOnTop=true;
    dlg.ExplicitShow=1;
    dlg.PreApplyMethod='preApplyCB';
    dlg.PreApplyArgs={'%dialog'};
    dlg.PreApplyArgsDT={'handle'};

    dlg.HelpMethod='helpview';
    dlg.HelpArgs={[docroot,'/simulink/helptargets.map'],'hmi_edit'};
end