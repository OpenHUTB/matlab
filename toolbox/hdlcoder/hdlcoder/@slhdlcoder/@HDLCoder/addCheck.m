function addCheck(this,modelName,errorLevel,msgData,type,pathinfo)












    if(nargin<5)
        type='model';
    end

    if(nargin<6)
        pathinfo=modelName;
    end

    if isa(msgData,'message')
        msg=msgData.getString;
        msgID=msgData.Identifier;
    else
        assert(isa(msgData,'MException'));
        msg=msgData.message;
        msgID=msgData.identifier;
    end

    newMsg.level=errorLevel;
    newMsg.path=pathinfo;
    newMsg.message=msg;
    newMsg.type=type;
    newMsg.MessageID=msgID;

    this.updateChecksCatalog(modelName,newMsg);
end
