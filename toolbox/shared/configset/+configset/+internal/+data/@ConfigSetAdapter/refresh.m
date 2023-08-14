function refresh(obj)




    s.action='refresh';
    s.params=[];
    obj.notify('CSEvent',configset.internal.data.ConfigSetEventData(s));


