function rejectUpdateConfiguration(widgetId,update)
    channel=['/customwebblocks/',widgetId];
    message.publish(channel,update);
end
