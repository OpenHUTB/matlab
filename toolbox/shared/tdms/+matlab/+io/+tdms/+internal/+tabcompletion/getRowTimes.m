function channelNames=getRowTimes(location,channelGroupName)



    fileName=matlab.io.datastore.FileSet(location).nextfile().Filename;
    channelList=tdmsinfo(fileName).ChannelList;
    rows=ismember(channelList.ChannelGroupName,channelGroupName)&ismember(channelList.DataType,"Timestamp");
    channelNames=channelList(rows,:).ChannelName;
end


