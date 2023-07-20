function sid=getSID(objectId)


    if isempty(objectId)||~isnumeric(objectId)
        error('ObjectId must be a number and cannot be empty')
    end


    if strcmp(slmle.internal.checkMLFBType(objectId),'EMChart')
        objH=idToHandle(sfroot,sf('get',objectId,'.chart'));
        sid=Simulink.ID.getStateflowSID(objH);


    else
        objH=idToHandle(sfroot,objectId);
        sid=Simulink.ID.getStateflowSID(objH);
    end
