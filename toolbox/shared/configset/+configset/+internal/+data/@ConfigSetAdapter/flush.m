function flush(obj,refresh)







    if nargin<2
        refresh=false;
    end

    if refresh
        data.action='refresh';
        data.params=[];
    else
        data.action='update';
        data.params=obj.params;
    end

    obj.notify('CSEvent',configset.internal.data.ConfigSetEventData(data));
    obj.params={};

    if obj.needUpdateOverride
        obj.updateOverride();
        obj.needUpdateOverride=false;
    end

    obj.locked=false;
