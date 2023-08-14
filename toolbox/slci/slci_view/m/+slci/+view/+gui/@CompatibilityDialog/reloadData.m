

function reloadData(obj,modelName,msgID)
    if(nargin==1)
        src=slci.view.internal.getSource(obj.getStudio);
        modelName=src.modelName;
        msgID='reloadData';
    end

    msg=obj.loadData(modelName);
    msg.msgID=msgID;
    message.publish(obj.getChannel,msg);
end
