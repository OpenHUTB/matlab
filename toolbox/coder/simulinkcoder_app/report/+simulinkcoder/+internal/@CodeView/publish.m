function publish(obj,action,data,uid)


    cr=simulinkcoder.internal.Report.getInstance;
    channel=cr.channel;

    s=[];
    s.cid=obj.cid;
    s.mdl=obj.model;
    s.action=action;
    s.data=data;

    if nargin==4
        s.uid=uid;
    end

    message.publish(channel,s);

