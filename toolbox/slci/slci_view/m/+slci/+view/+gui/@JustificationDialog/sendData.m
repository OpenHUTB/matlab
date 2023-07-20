



function sendData(obj)

    src=slci.view.internal.getSource(obj.getStudio);


    msg.model=src.modelName;
    msg.msgID='reloadData';
    message.publish(obj.getChannel,msg);


    if slcifeature('SLCIJustification')==1
        msg.data=obj.fSendJsonData;
        msg.type='getJustificationData';
        message.publish(obj.getChannel,msg);
    end
