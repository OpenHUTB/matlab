function destroyWebPanelWidget(panelWidgetHandleHex)
    widgetPath=getfullname(str2double(panelWidgetHandleHex));
    delete_block(widgetPath);
end
