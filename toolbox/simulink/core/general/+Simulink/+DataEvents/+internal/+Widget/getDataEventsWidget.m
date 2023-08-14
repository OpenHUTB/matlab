function uiPanel=getDataEventsWidget(widgetStruct,varargin)



    if(nargin>0)
        blkHandle=varargin{1};
    end

    widgetStruct.ColSpan=[1,1];
    widgetStruct.RowSpan=[1,1];
    if isfield(widgetStruct,'NameLocation')
        widgetStruct=rmfield(widgetStruct,'NameLocation');
    end


    dataEventsWidget=Simulink.DataEvents.internal.Widget.DataEventsWidget(blkHandle);
    uiBrowser.Type='webbrowser';
    uiBrowser.WebKit=false;
    uiBrowser.DisableContextMenu=true;
    uiBrowser.Url=dataEventsWidget.getUrl(false);
    uiBrowser.Tag=[widgetStruct.Tag,'|data_events_widget_tag'];
    uiBrowser.RowSpan=[1,1];
    uiBrowser.ColSpan=[1,1];
    uiBrowser.UserData=dataEventsWidget;

    uiPanel.Type='panel';
    uiPanel.Name='Input Events';
    uiPanel.LayoutGrid=[6,2];
    uiPanel.Tag=[widgetStruct.Tag,'|data_events_panel_tag'];
    uiPanel.Items={uiBrowser};
    uiPanel.RowSpan=[1,1];
    uiPanel.ColSpan=[1,1];

    dataEventsWidget.show();

end

