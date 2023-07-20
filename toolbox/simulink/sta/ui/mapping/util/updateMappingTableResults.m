function updateMappingTableResults(inputSpecID,appInstanceID)




    tableStruct=tableStructFromInputSpecID(inputSpecID);


    fullChannel=sprintf('/sta%s/%s',appInstanceID,'sta/updatemappingtable');
    message.publish(fullChannel,tableStruct);