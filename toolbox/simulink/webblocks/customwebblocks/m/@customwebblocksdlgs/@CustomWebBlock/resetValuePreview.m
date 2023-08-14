function resetValuePreview(widgetId)
    channel=['/customwebblocks/',widgetId];
    message.publish(channel,'resetValuePreview');
end