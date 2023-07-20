function sendStaMappingInformation(inputSpecID,jsonStruct,appInstanceID)




    outMsg=mappingStartup(inputSpecID,jsonStruct);
    fullChannel=sprintf('/sta%s/%s',appInstanceID,'SignalAuthoring/mapping/restoremapping');
    message.publish(fullChannel,outMsg);