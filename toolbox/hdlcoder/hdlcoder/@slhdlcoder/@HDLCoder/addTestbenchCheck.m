function addTestbenchCheck(this,mdlName,errorLevel,msgData,msgID)


    if isa(msgData,'message')
        msgID=msgData.Identifier;
        msgData=msgData.getString;
    elseif isa(msgData,'MException')
        msgID=msgData.identifier;
        msgData=msgData.message;
    end

    qchk.level=errorLevel;
    qchk.path=mdlName;
    qchk.message=msgData;
    qchk.type='model';
    qchk.MessageID=msgID;

    this.updateTestbenchChecksCatalog(mdlName,qchk);
end
