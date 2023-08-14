function switchModel(obj,current)



    data.model=get_param(current,'Name');
    obj.publish('switchModel',data);


