function switchModel(obj,current)


    data.model=current;
    obj.publish('switchModel',data);