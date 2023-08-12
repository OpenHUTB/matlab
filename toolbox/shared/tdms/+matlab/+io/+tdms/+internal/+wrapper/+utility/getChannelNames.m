function channelName = getChannelNames( info, channelGroupName )




R36
info( 1, 1 )matlab.io.tdms.TdmsInfo
channelGroupName( 1, 1 )string
end 
import matlab.io.tdms.internal.wrapper.utility.*
channelName = find( info, channelGroupName ).ChannelName';
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpKHqHJ9.p.
% Please follow local copyright laws when handling this file.

