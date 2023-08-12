function channelList = find( info, channelGroupName, channelName )




R36
info( 1, 1 )matlab.io.tdms.TdmsInfo
channelGroupName( 1, : )string{ matlab.io.tdms.internal.validator.mustBeNonEmptyString }
channelName( 1, : )string = string.empty
end 
import matlab.io.tdms.internal.*
validator.mustBeChannelGroupsOf( channelGroupName, info.ChannelList );
index = ismember( info.ChannelList.ChannelGroupName, channelGroupName );
if ~utility.isEmptyString( channelName )
matlab.io.tdms.internal.validator.mustBeChannelsOf( channelName, channelGroupName, info.ChannelList );
index = index & ismember( info.ChannelList.ChannelName, channelName );
end 
channelList = info.ChannelList( index, : );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpn6bD9z.p.
% Please follow local copyright laws when handling this file.

