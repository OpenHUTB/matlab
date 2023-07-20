function callback(obj,msg)




    ed=configset.internal.data.ConfigSetEventData(msg);
    obj.notify('Event',ed);

