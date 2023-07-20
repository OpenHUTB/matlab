function dlgStruct=getDialogSchema(obj)


    blockDiffWebWidget.Type='webbrowser';
    blockDiffWebWidget.WebKit=true;
    blockDiffWebWidget.HTML=obj.blockdiffHtml;
    blockDiffWebWidget.Tag='blockDiffWebWidgetTag';


    blockDiffPanel.Name=DAStudio.message('sl_pir_cpp:creator:blockDiffPanelName');
    blockDiffPanel.Type='group';
    blockDiffPanel.Tag='blockDifferencePanelTag';
    blockDiffPanel.Items={blockDiffWebWidget};
    blockDiffPanel.RowSpan=[1,1];
    blockDiffPanel.ColSpan=[1,1];


    ssSourceMetrics=...
    CloneDetectionUI.internal.SpreadSheetSource.Metrics...
    (obj.cloneUIObj.metrics,obj.cloneUIObj.totalBlocks,obj.cloneUIObj.refactorButtonEnable);

    metricsPanelSSWidget.Name='spreadsheet widget metrics';
    metricsPanelSSWidget.Type='spreadsheet';
    metricsPanelSSWidget.Tag='spreadsheetWidgetMetrics';
    metricsPanelSSWidget.Columns=...
    {DAStudio.message('sl_pir_cpp:creator:metricsSSColumn1'),...
    DAStudio.message('sl_pir_cpp:creator:metricsSSColumn2'),...
    DAStudio.message('sl_pir_cpp:creator:metricsSSColumn3')};
    metricsPanelSSWidget.Source=ssSourceMetrics;
    metricsPanelSSWidget.DialogRefresh=1;


    metricsPanel.Name=DAStudio.message('sl_pir_cpp:creator:metricsPanelName');
    metricsPanel.Type='group';
    metricsPanel.Tag='metricsPanelTag';
    metricsPanel.Items={metricsPanelSSWidget};
    metricsPanel.RowSpan=[2,2];
    metricsPanel.ColSpan=[1,1];

    dlgStruct.DialogTitle='';
    dlgStruct.Items={blockDiffPanel,metricsPanel};
    dlgStruct.StandaloneButtonSet={''};
    dlgStruct.EmbeddedButtonSet={''};
    dlgStruct.LayoutGrid=[2,1];
    dlgStruct.RowStretch=[1,1];

end