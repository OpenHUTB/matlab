function publish(obj,mdl,action,data,uid)


    s=[];
    s.mdl=mdl;
    s.action=action;
    s.data=data;

    if nargin==5
        s.uid=uid;
    end

    message.publish(obj.channel,s);

