function groupId=getGroupId(blkObj,pathItem,uid2gID)




    data=struct('Object',blkObj,'ElementName',pathItem);
    dataArrayHandler=fxptds.SimulinkDataArrayHandler;
    uid=dataArrayHandler.getUniqueIdentifier(data);
    groupId=-1;
    if(uid2gID.isKey(uid.UniqueKey))
        groupId=uid2gID(uid.UniqueKey);
    end
end