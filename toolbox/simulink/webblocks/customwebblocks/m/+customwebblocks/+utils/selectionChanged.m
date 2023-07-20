function selectionChanged(widgetId,subComponent)
    channel=['/customwebblocks/',widgetId];
    msg=struct();
    msg.event='selectionChanged';
    msg.data=subComponent;
    message.publish(channel,jsonencode(msg));
end