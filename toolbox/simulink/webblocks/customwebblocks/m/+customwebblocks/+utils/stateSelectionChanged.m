function stateSelectionChanged(widgetId,index)
    channel=['/customwebblocks/',widgetId];
    msg=struct();
    msg.event='stateSelectionChanged';
    msg.data=index;
    message.publish(channel,jsonencode(msg));
end

