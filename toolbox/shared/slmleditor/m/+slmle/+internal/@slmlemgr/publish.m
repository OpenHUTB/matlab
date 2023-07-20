function publish(obj,objectId,action,data)






    channel=sprintf('%s/%d',obj.channel,objectId);
    data.action=action;
    message.publish(channel,data);

