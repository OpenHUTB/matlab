
function toggleCachedValueType(~,source,~,value)
    channel=['/customwebblocks/',source.widgetId];
    if value
        message.publish(channel,'setCachedValueTypeToRange');
    else
        message.publish(channel,'setCachedValueTypeToDiscrete');
    end
end