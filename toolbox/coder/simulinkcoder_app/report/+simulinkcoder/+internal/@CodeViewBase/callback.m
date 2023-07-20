function callback(obj,src,evt)


    data=evt.data;
    newEvt=simulinkcoder.internal.CodeViewEventData(data);
    obj.notify('CodeViewEvent',newEvt);


