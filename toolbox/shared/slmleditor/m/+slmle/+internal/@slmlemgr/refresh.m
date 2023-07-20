function refresh(obj,objectId,uid)




    data=[];

    if nargin<2
        error('Insufficient number of arguments. Must be atleast 2');
    end

    if isnumeric(objectId)
        data.objectId=objectId;
    else
        data.objectId=obj.getObjectId(objectId);
    end

    if nargin>2
        data.uid=uid;
    end

    try
        data.text=slmle.internal.object2Data(objectId,'getScript');
    catch ME
        data.error=ME.message;
    end

    obj.publish(objectId,'refresh',data);

