function publish(obj,action,data)





    m=slmle.internal.slmlemgr.getInstance;
    channel=sprintf('%s/%d',m.channel,obj.objectId);

    data.action=action;
    data.objectId=obj.objectId;
    data.eid=obj.eid;

    message.publish(channel,data);

