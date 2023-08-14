function lock(obj,flag)


    data.lock=flag;

    obj.isLocked=flag;
    obj.publish('lock',data);

