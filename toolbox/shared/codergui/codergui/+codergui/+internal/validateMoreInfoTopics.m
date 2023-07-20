

function valid=validateMoreInfoTopics(messageIds)



    if iscell(messageIds)
        valid=cellfun(@validateSingleTopic,messageIds);
    else
        valid=validateSingleTopic(messageIds);
    end
end

function valid=validateSingleTopic(messageId)
    [mapfile,topic]=coder.internal.moreinfo('-lookup',messageId);
    valid=~isempty(mapfile)&&~isempty(topic);
end