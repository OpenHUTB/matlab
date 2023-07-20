function isT=isTransparent(inferFcnInfo)



    if isempty(inferFcnInfo)
        isT=[];
        return;
    end

    isT=[inferFcnInfo.IsTransparent];
    if~isscalar(isT)
        ets=find(isT);
        for j=1:numel(ets)
            idx=ets(j);
            isT(idx)=applyOverride(inferFcnInfo(idx));
        end
    elseif isT %#ok
        isT=applyOverride(inferFcnInfo);
    end

end

function isT=applyOverride(inferFcnInfo)
    isT=true;
    messages=inferFcnInfo.Messages;
    for id=1:numel(messages)
        msgID=messages(id).MsgID;
        if~strcmp(msgID,'Coder:builtins:FunctionCallFailed')
            isT=false;
            return;
        end
    end

end


