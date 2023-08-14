function channelGroups=getChannelGroups(location)




    fileName=matlab.io.datastore.FileSet(location).nextfile().Filename;
    channelGroups=unique(tdmsinfo(fileName).ChannelList.ChannelGroupName);
end

