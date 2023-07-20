function dlg=getSlimDialogSchema(obj,~)




    dlg=obj.getBaseSlimDialogSchema();
    states=obj.getBlock().Values;
    labelPosition=obj.getBlock().LabelPosition;
    labelPosition=simulink.hmi.getLabelPosition(labelPosition);
    opacity=obj.getBlock().Opacity;
    colorJson=obj.getBlock().BackgroundForegroundColor;
    [obj.BackgroundColor,obj.ForegroundColor]=hmiblockdlg.formatColorStrings(colorJson);


    uncheckedLabel.Type='text';
    uncheckedLabel.Tag='uncheckedLabel';
    uncheckedLabel.Name=...
    DAStudio.message('SimulinkHMI:messages:DashboardCheckboxUncheckedLabel');
    uncheckedLabel.RowSpan=[2,2];
    uncheckedLabel.ColSpan=[1,3];

    uncheckedValue.Type='edit';
    uncheckedValue.Tag='uncheckedValue';
    uncheckedValue.Value=num2str(states(1),16);
    uncheckedValue.MatlabMethod='utils.slimDialogUtils.setCheckboxStateValue';
    uncheckedValue.MatlabArgs={'%dialog','%source','uncheckedValue',1,'%value'};
    uncheckedValue.RowSpan=[2,2];
    uncheckedValue.ColSpan=[4,5];


    checkedLabel.Type='text';
    checkedLabel.Tag='checkedLabel';
    checkedLabel.Name=...
    DAStudio.message('SimulinkHMI:messages:DashboardCheckboxCheckedLabel');
    checkedLabel.RowSpan=[3,3];
    checkedLabel.ColSpan=[1,3];

    checkedValue.Type='edit';
    checkedValue.Tag='checkedValue';
    checkedValue.Value=num2str(states(2),16);
    checkedValue.MatlabMethod='utils.slimDialogUtils.setCheckboxStateValue';
    checkedValue.MatlabArgs={'%dialog','%source','checkedValue',2,'%value'};
    checkedValue.RowSpan=[3,3];
    checkedValue.ColSpan=[4,5];




    labelStrLabel.Type='text';
    labelStrLabel.Tag='buttonGroupNameLabel';
    labelStrLabel.Name=...
    DAStudio.message('SimulinkHMI:dialogs:CheckboxLabelPrompt');
    labelStrLabel.RowSpan=[4,4];
    labelStrLabel.ColSpan=[1,3];

    labelStr.Type='edit';
    labelStr.Tag='CheckboxLabel';
    labelStr.Source=obj;
    labelStr.Value=obj.getBlock().Label;
    labelStr.MatlabMethod='utils.slimDialogUtils.setCheckboxLabel';
    labelStr.MatlabArgs={'%dialog','%source','%tag','%value'};
    labelStr.RowSpan=[4,4];
    labelStr.ColSpan=[4,5];

    legendPositionLabel.Type='text';
    legendPositionLabel.Tag='labelPositionText';
    legendPositionLabel.Name=...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionPrompt');
    legendPositionLabel.RowSpan=[5,5];
    legendPositionLabel.ColSpan=[1,3];

    legendPosition.Type='combobox';
    legendPosition.Tag='labelPosition';
    legendPosition.Source=obj;
    legendPosition.Entries={...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionTop'),...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionBottom'),...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionHide')...
    };
    legendPosition.Value=labelPosition;
    legendPosition.MatlabMethod='utils.slimDialogUtils.setCoreBlockLabelPosition';
    legendPosition.MatlabArgs={'%dialog','%source','%tag','%value'};
    legendPosition.RowSpan=[5,5];
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
    colorWebbrowser.PreferredSize=[100,250];
    colorWebbrowser.RowSpan=[2,2];
    colorWebbrowser.ColSpan=[1,5];


    mainPanel.Type='togglepanel';
    mainPanel.Name=DAStudio.message('SimulinkHMI:dialogs:GaugeBlockMainGroup');
    mainPanel.Expand=true;
    mainPanel.Items={uncheckedLabel,uncheckedValue,...
    checkedLabel,checkedValue,...
    labelStrLabel,labelStr,...
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