function str=resolveMessageString(maybeMsgId)












    if iscell(maybeMsgId)
        strs=cell(size(maybeMsgId));
        for idx=1:numel(maybeMsgId)
            strs{idx}=lResolveMessageString(...
            maybeMsgId{idx});
        end
        str=strjoin(strs,': ');
    else
        str=lResolveMessageString(maybeMsgId);
    end

end

function str=lResolveMessageString(maybeMsgId)
    if pm_ismessageid(maybeMsgId)
        str=getString(message(maybeMsgId));
    else
        str=maybeMsgId;
    end
end
