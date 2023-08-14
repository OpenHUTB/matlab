function refreshDialog(widgetId)
    channel=['/customwebblocks/',widgetId];
    message.publish(channel,'refreshDialog');
end


