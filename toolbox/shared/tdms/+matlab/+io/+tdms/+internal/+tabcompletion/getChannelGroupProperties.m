function propNames=getChannelGroupProperties(fileName,channelGroupName)



    propNames=tdmsreadprop(fileName,ChannelGroupName=channelGroupName).Properties.VariableNames;
end
