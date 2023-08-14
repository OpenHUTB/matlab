function dlg=getSlimDialogSchema(obj,~)




    dlg=obj.getBaseSlimDialogSchema();
    blockHandle=get(obj.blockObj,'handle');
    labelPosition=obj.getBlock().LabelPosition;
    labelPosition=simulink.hmi.getLabelPosition(labelPosition);
    opacity=get_param(blockHandle,'Opacity');
    formatString=get_param(blockHandle,'FormatString');
    colorJson=get_param(blockHandle,'BackgroundForegroundColor');
    gridColor=get_param(blockHandle,'GridColor');
    showGridValue=get_param(blockHandle,'ShowGrid');

    [obj.BackgroundColor,obj.ForegroundColor]=hmiblockdlg.formatColorStrings(colorJson);
    obj.GridColor="["+gridColor(1)+","+gridColor(2)+","+gridColor(3)+"]";


    format_label.Type='text';
    format_label.Tag='formatlabel';
    format_label.Name=...
    [DAStudio.message('SimulinkHMI:dialogs:DisplayBlockFormatPrompt'),':'];
    format_label.RowSpan=[2,2];
    format_label.ColSpan=[1,3];

    format_cb.Type='combobox';
    format_cb.Tag='DispFormat';
    format_cb.Source=obj;
    format_cb.Entries={...
    DAStudio.message('SimulinkHMI:dashboardblocks:SHORT'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:LONG'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:SHORT_E'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:LONG_E'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:SHORT_G'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:LONG_G'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:SHORT_ENG'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:LONG_ENG'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:BANK'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:PLUS'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:HEX'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:RAT'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:CUSTOM'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:INTEGER')
    };
    format_cb.Value=obj.getBlock().Format;
    format_cb.MatlabMethod='utils.slimDialogUtils.setDisplayBlockFormat';
    format_cb.MatlabArgs={'%dialog','%source','%tag','%value'};
    format_cb.RowSpan=[2,2];
    format_cb.ColSpan=[4,5];


    formatString_label.Type='text';
    formatString_label.Tag='formatStringLabel';
    formatString_label.Name=...
    [DAStudio.message('SimulinkHMI:dialogs:DisplayBlockFormatStringPrompt'),':'];
    formatString_label.RowSpan=[3,3];
    formatString_label.ColSpan=[1,3];

    formatString_cb.Type='edit';
    formatString_cb.Tag='formatString';
    formatString_cb.Enabled=strcmp(obj.getBlock().Format,DAStudio.message('SimulinkHMI:dashboardblocks:CUSTOM'));
    formatString_cb.Source=obj;
    formatString_cb.Value=formatString;
    formatString_cb.MatlabMethod='utils.slimDialogUtils.setDisplayBlockFormatString';
    formatString_cb.MatlabArgs={'%dialog','%source','%tag','%value'};
    formatString_cb.RowSpan=[3,3];
    formatString_cb.ColSpan=[4,5];


    alignment_label.Type='text';
    alignment_label.Tag='alignmentlabel';
    alignment_label.Name=...
    [DAStudio.message('SimulinkHMI:dialogs:DisplayBlockAlignmentPrompt'),':'];
    alignment_label.RowSpan=[4,4];
    alignment_label.ColSpan=[1,3];

    alignment_cb.Type='combobox';
    alignment_cb.Tag='DispAlignment';
    alignment_cb.Source=obj;
    alignment_cb.Entries={...
    DAStudio.message('SimulinkHMI:dashboardblocks:DisplayBlockLeftAlignment'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:DisplayBlockCenterAlignment'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:DisplayBlockRightAlignment')...
    };
    alignment_cb.Value=utils.getTranslatedAlignment(obj.getBlock().Alignment);
    alignment_cb.MatlabMethod='utils.slimDialogUtils.setDisplayBlockAlignment';
    alignment_cb.MatlabArgs={'%dialog','%source','%tag','%value'};
    alignment_cb.RowSpan=[4,4];
    alignment_cb.ColSpan=[4,5];


    legendPositionLabel.Type='text';
    legendPositionLabel.Tag='labelPositionLabel';
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


    transparency_label.Type='text';
    transparency_label.Tag='transparencyLabel';
    transparency_label.Name=...
    [DAStudio.message('SimulinkHMI:dialogs:DashboardBlockOpacityPrompt'),':'];
    transparency_label.RowSpan=[2,2];
    transparency_label.ColSpan=[1,3];

    transparency_cb.Type='edit';
    transparency_cb.Tag='opacity';
    transparency_cb.Source=obj;
    transparency_cb.Value=opacity;
    transparency_cb.MatlabMethod='utils.slimDialogUtils.setDashboardBlockTransparency';
    transparency_cb.MatlabArgs={'%dialog','%source','%tag','%value'};
    transparency_cb.RowSpan=[2,2];
    transparency_cb.ColSpan=[4,5];


    fitToView_label.Type='text';
    fitToView_label.Tag='fitToViewLabel';
    fitToView_label.Name=...
    [DAStudio.message('SimulinkHMI:dialogs:DisplayBlockFitToViewPrompt'),':'];
    fitToView_label.RowSpan=[7,7];
    fitToView_label.ColSpan=[1,3];

    fitToView_cb.Type='combobox';
    fitToView_cb.Tag='DispFitToView';
    fitToView_cb.Source=obj;
    fitToView_cb.Entries={...
    DAStudio.message('SimulinkHMI:dialogs:DisplayBlockLayoutPreserveDimensions'),...
    DAStudio.message('SimulinkHMI:dialogs:DisplayBlockLayoutFillSpace')...
    };
    fitToView_cb.Value=utils.getTranslatedLayout(obj.getBlock().Layout);
    fitToView_cb.MatlabMethod='utils.slimDialogUtils.setDisplayBlockFitToView';
    fitToView_cb.MatlabArgs={'%dialog','%source','%tag','%value'};
    fitToView_cb.RowSpan=[7,7];
    fitToView_cb.ColSpan=[4,5];


    showGrid.Type='checkbox';
    showGrid.Tag='showGridBox';
    showGrid.Name=...
    [DAStudio.message('SimulinkHMI:dialogs:DisplayBlockShowGridText')];
    showGrid.Value=strcmp(showGridValue,'on');
    if strcmpi(showGridValue,'on')
        showGrid.Value=1;
    else
        showGrid.Value=0;
    end
    showGrid.MatlabMethod='utils.slimDialogUtils.setDisplayShowGrid';
    showGrid.MatlabArgs={'%dialog','%source','%tag','%value'};
    showGrid.RowSpan=[1,1];
    showGrid.ColSpan=[1,5];


    colorsHtmlPath='toolbox/simulink/hmi/web/Dialogs/SignalDialog/DisplayBlockColors.html';
    webbrowser=hmiblockdlg.createColorBrowserStructure(obj,colorsHtmlPath,true);
    webbrowser.PreferredSize=[100,250];
    webbrowser.RowSpan=[9,9];
    webbrowser.ColSpan=[1,5];


    colorsGroup.Type='panel';
    colorsGroup.Tag='colorGroupTag';
    colorsGroup.Name=...
    [DAStudio.message('SimulinkHMI:dialogs:DisplayBlockColorsGroup')];
    colorsGroup.RowSpan=[3,3];
    colorsGroup.ColSpan=[1,5];
    colorsGroup.LayoutGrid=[1,1];
    colorsGroup.Items={webbrowser};


    signalPanel.Type='togglepanel';
    signalPanel.Name=DAStudio.message('SimulinkHMI:dialogs:GaugeBlockSignalTitle');
    signalPanel.Items=dlg.Items;
    signalPanel.Expand=true;
    signalPanel.LayoutGrid=[1,5];
    signalPanel.RowStretch=[1];
    signalPanel.ColStretch=[0,0,0,0,1];
    signalPanel.RowSpan=[1,1];
    signalPanel.ColSpan=[1,5];


    mainPanel.Type='togglepanel';
    mainPanel.Name=DAStudio.message('SimulinkHMI:dialogs:DisplayBlockMainGroup');
    mainPanel.Expand=true;
    mainPanel.Items={format_label,format_cb,...
    formatString_label,formatString_cb,...
    alignment_label,alignment_cb,...
    legendPositionLabel,legendPosition,...
    fitToView_label,fitToView_cb};
    numMainItems=length(mainPanel.Items);
    mainPanel.LayoutGrid=[numMainItems+1,5];
    mainPanel.RowStretch(1:numMainItems)=0;
    mainPanel.RowStretch(end+1)=1;
    mainPanel.ColStretch=[0,0,0,0,1];
    mainPanel.RowSpan=[2,2];
    mainPanel.ColSpan=[1,5];


    formatPanel.Type='togglepanel';
    formatPanel.Name=DAStudio.message('SimulinkHMI:dialogs:GaugeBlockFormatGroup');
    formatPanel.Expand=true;
    formatPanel.Items={showGrid,transparency_label,transparency_cb,colorsGroup};
    numFormatItems=length(formatPanel.Items);
    formatPanel.LayoutGrid=[numFormatItems+1,5];
    formatPanel.RowStretch(1:numFormatItems)=0;
    formatPanel.RowStretch(end+1)=1;
    formatPanel.ColStretch=[0,0,0,0,1];
    formatPanel.RowSpan=[3,3];
    formatPanel.ColSpan=[1,5];


    dlg.LayoutGrid=[3,5];
    dlg.RowStretch=[0,0,1];
    dlg.ColStretch=[0,0,0,0,1];
    dlg.Items={signalPanel,mainPanel,formatPanel};
end