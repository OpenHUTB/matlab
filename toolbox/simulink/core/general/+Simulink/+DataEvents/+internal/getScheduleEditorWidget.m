function uiPanel=getScheduleEditorWidget(widgetStruct)




    widgetStruct.ColSpan=[2,2];
    widgetStruct.RowSpan=[1,1];
    if isfield(widgetStruct,'NameLocation')
        widgetStruct=rmfield(widgetStruct,'NameLocation');
    end

    uiConnector.Type='pushbutton';
    uiConnector.Tag='scheduleEditor';
    uiConnector.ColSpan=[1,1];
    uiConnector.RowSpan=[1,1];
    uiConnector.Alignment=1;
    uiConnector.MatlabMethod='Simulink.DataEvents.cb_LaunchScheduleEditor';
    uiConnector.MatlabArgs={'%dialog'};
    uiConnector.Name=message('SimulinkPartitioning:PartitioningEditor:ScheduleEditorNodeName').getString;
    uiConnector.ToolTip=message('SimulinkPartitioning:PartitioningEditor:EventsPanelDesc').getString;
    uiConnector.DialogRefresh=true;

    uiPanel.Type='panel';
    uiPanel.Name='';
    uiPanel.LayoutGrid=[1,2];
    uiPanel.Tag=[widgetStruct.Tag,'|Panel'];
    uiPanel.Items={uiConnector};
    uiPanel.RowSpan=[1,1];
    uiPanel.ColSpan=[1,1];

end

