function action(obj,msg)




    data=slmle.internal.MLFBEventData(msg);
    obj.notify('MLFB',data);

