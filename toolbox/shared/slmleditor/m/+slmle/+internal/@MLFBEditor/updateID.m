function updateID(obj)



    data=[];
    data.sid=Simulink.ID.getSID(obj.h);

    obj.publish('updateID',data);


