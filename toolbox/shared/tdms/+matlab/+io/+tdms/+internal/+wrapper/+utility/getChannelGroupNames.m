function channelGroupName = getChannelGroupNames( info )

arguments
    info( 1, 1 )matlab.io.tdms.TdmsInfo
end
channelGroupName = unique( info.ChannelList.ChannelGroupName, "stable" )';
end
