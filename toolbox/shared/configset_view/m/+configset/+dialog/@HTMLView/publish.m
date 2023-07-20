function publish(obj,subchannel,data)


    obj.startTransaction(subchannel);
    channel=configset.dialog.Connector.channel;

    s=[];
    s.serverId=obj.ID;
    s.action=subchannel;
    s.data=data;
    message.publish(channel,s);
