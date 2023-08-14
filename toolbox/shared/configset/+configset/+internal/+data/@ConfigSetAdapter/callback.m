function callback(obj,~,e)




    name=e.NewValue;
    if~isempty(name)

        s.action='removeError';
        s.params=name;
        obj.notify('CSEvent',configset.internal.data.ConfigSetEventData(s));


        obj.update(e.AffectedObject,name);
    end
