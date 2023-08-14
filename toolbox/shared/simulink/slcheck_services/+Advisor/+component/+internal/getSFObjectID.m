












function objectID=getSFObjectID(sid)

    obj=Simulink.ID.getHandle(sid);

    if isa(obj,'double')
        sfID=sfprivate('block2chart',obj);
        obj=find(sfroot,'Id',sfID);

        objectID=obj.Id;

    elseif isa(obj,'Stateflow.Object')
        objectID=obj.Id;
    else
        objectID=-1;
    end
end