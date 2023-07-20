function propNames=getChannelProperties(fileName,channelGroupName,channelName)




    propNames=tdmsreadprop(fileName,ChannelGroupName=channelGroupName,ChannelName=channelName).Properties.VariableNames;
end