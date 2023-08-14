function msg=getMessage(obj,msgId,varargin)




    obj.loadMessgeData();

    msg=stm.internal.MRT.utility.MRTMessage(msgId);

    if(~obj.msgData.msgCatalog.isKey(msgId))
        return;
    end
    msg.message=obj.msgData.msgCatalog(msgId);
    nHoles=obj.msgData.msgHolesMap(msgId);

    tmpStr=msg.message;
    inputVars=varargin{:};
    assert(nHoles<=length(inputVars));
    for k=1:nHoles
        tmpStr=strrep(tmpStr,obj.msgData.tokenList{k},inputVars{k});
    end
    msg.message=tmpStr;
end
