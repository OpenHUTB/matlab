function out=isTempModelSID(obj,sid)




    if nargin>1
        sid=convertStringsToChars(sid);
    end

    out=~isempty(obj.SourceSubsystem)&&~strcmp(strtok(obj.SourceSubsystem,':'),strtok(sid,':'));
end
