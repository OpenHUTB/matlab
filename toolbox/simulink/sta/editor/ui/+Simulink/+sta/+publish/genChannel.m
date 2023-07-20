function fullChannel=genChannel(baseMessageChanel,uniqueAppID,subChannel)





    fullChannel=sprintf('/%s%s/%s',baseMessageChanel,...
    uniqueAppID,...
    subChannel);
