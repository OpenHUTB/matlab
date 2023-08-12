function channelGroupName = getChannelGroupNames( info )




R36
info( 1, 1 )matlab.io.tdms.TdmsInfo
end 
channelGroupName = unique( info.ChannelList.ChannelGroupName, "stable" )';
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpQ7MrNi.p.
% Please follow local copyright laws when handling this file.

