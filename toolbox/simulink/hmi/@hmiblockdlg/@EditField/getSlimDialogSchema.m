function dlg=getSlimDialogSchema(obj,~)




    dlg=obj.getBaseSlimDialogSchema();
    labelPosition=obj.getBlock().LabelPosition;
    labelPosition=simulink.hmi.getLabelPosition(labelPosition);
    opacity=obj.getBlock().Opacity;
    colorJson=obj.getBlock().BackgroundForegroundColor;
    [obj.BackgroundColor,obj.ForegroundColor]=hmiblockdlg.formatColorStrings(colorJson);


    alignment_label.Type='text';
    alignment_label.Tag='alignmentlabel';
    alignment_label.Name=...
    DAStudio.message('SimulinkHMI:dialogs:DisplayBlockAlignmentPrompt');
    alignment_label.RowSpan=[2,2];
    alignment_label.ColSpan=[1,3];

    alignment_cb.Type='combobox';
    alignment_cb.Tag='EditAlignment';
    alignment_cb.Source=obj;
    alignment_cb.Entries={...
    DAStudio.message('SimulinkHMI:dashboardblocks:DisplayBlockLeftAlignment'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:DisplayBlockCenterAlignment'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:DisplayBlockRightAlignment')...
    };
    alignment_cb.Value=obj.getBlock().Alignment;
    alignment_cb.MatlabMethod='utils.slimDialogUtils.setDisplayBlockAlignment';
    alignment_cb.MatlabArgs={'%dialog','%source','%tag','%value'};
    alignment_cb.RowSpan=[2,2];
    alignment_cb.ColSpan=[4,5];


    legendPositionLabel.Type='text';
    legendPositionLabel.Tag='labelPositionLabel';
    legendPositionLabel.Name=...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionPrompt');
    legendPositionLabel.RowSpan=[3,3];
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
    legendPosition.RowSpan=[3,3];
    legendPosition.ColSpan=[4,5];


    opacityLabel.Type='text';
    opacityLabel.Tag='opacityLabel';
    opacityLabel.Name=[DAStudio.message('SimulinkHMI:dialogs:DashboardBlockOpacityPrompt'),':'];
    opacityLabel.RowSpan=[4,4];
    opacityLabel.ColSpan=[1,3];

    opacityCB.Type='edit';
    opacityCB.Tag='opacity';
    opacityCB.Source=obj;
    opacityCB.Value=opacity;
    opacityCB.MatlabMethod='utils.slimDialogUtils.setDashboardBlockTransparency';
    opacityCB.MatlabArgs={'%dialog','%source','%tag','%value'};
    opacityCB.RowSpan=[4,4];
    opacityCB.ColSpan=[4,5];


    colorsHtmlPath='toolbox/simulink/hmi/web/Dialogs/SignalDialog/ForegroundBackgroundColors.html';
    colorWebbrowser=hmiblockdlg.createColorBrowserStructure(obj,colorsHtmlPath,true);
    colorWebbrowser.PreferredSize=[100,250];
    colorWebbrowser.RowSpan=[5,5];
    colorWebbrowser.ColSpan=[1,5];


    mainPanel.Type='togglepanel';
    mainPanel.Name=DAStudio.message('SimulinkHMI:dialogs:GaugeBlockMainGroup');
    mainPanel.Expand=true;
    mainPanel.Items={alignment_label,alignment_cb,...
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


    dlg.LayoutGrid=[4,5];
    dlg.RowStretch=[0,0,0,1];
    dlg.ColStretch=[0,0,0,0,1];
    dlg.Items={signalPanel,mainPanel,formatPanel};
end
