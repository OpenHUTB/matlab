function publishMessage(baseMessageChanel,uniqueAppID,subChannel,msgValue)




    fullChannel=Simulink.sta.publish.genChannel(baseMessageChanel,uniqueAppID,subChannel);


    message.publish(fullChannel,msgValue);
