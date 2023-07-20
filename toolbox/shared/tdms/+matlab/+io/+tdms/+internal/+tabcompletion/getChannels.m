function channelNames=getChannels(location,channelGroupName)




    fileName=matlab.io.datastore.FileSet(location).nextfile().Filename;
    channelList=tdmsinfo(fileName).ChannelList;
    rows=ismember(channelList.ChannelGroupName,channelGroupName);
    channelNames=channelList(rows,:).ChannelName;
end
