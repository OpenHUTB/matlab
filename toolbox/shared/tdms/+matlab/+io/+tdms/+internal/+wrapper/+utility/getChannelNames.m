function channelName = getChannelNames( info, channelGroupName )

arguments
    info( 1, 1 )matlab.io.tdms.TdmsInfo
    channelGroupName( 1, 1 )string
end
import matlab.io.tdms.internal.wrapper.utility.*
channelName = find( info, channelGroupName ).ChannelName';
end
