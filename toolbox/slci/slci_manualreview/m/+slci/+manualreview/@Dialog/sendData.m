


function sendData(obj,msgID,data)
    msg.msgID=msgID;
    msg.data=data;
    msg.codeLanguage=obj.getCodeLanguage;
    message.publish(obj.getChannel,msg);
end