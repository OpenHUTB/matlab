function callback(obj,~,eventData)





    msg=eventData.data;
    if msg.objectId~=obj.objectId
        return;
    end
    if isfield(msg,'eid')&&msg.eid~=obj.eid
        return;
    end

    obj.action(msg);

