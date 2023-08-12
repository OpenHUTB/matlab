function C = readChannelGroups( info, startIndex, readSize, channelGroupNames )





R36
info( 1, 1 )matlab.io.tdms.TdmsInfo
startIndex( 1, 1 )uint64
readSize( 1, 1 )uint64
channelGroupNames( 1, : )string
end 
import matlab.io.tdms.internal.wrapper.utility.*

numSamplesAcrossChannelGroups = getNumSamples( info, channelGroupNames );
maxNumSamplesAcrossChannelGroups = max( numSamplesAcrossChannelGroups );

assert( startIndex + readSize <= maxNumSamplesAcrossChannelGroups,  ...
sprintf( "readChannelGroups out of Bounds. startIndex(%u) + readSize(%u) <= max(numSamplesAcrossChannelGroups)(%u)",  ...
startIndex, readSize, maxNumSamplesAcrossChannelGroups ) );

n = numel( channelGroupNames );
C = cell( 1, n );
for i = 1:n
C{ i } = readPaddedChannelGroup( info, channelGroupNames( i ), startIndex, readSize );
end 
end 


function T = readPaddedChannelGroup( info, channelGroupName, startIndex, readSize )
import matlab.io.tdms.internal.wrapper.utility.*
maxNumSamplesAcrossChannels = max( getNumSamples( info, channelGroupName ) );
if startIndex + readSize > maxNumSamplesAcrossChannels
if startIndex < maxNumSamplesAcrossChannels
T = readChannelsToTable( info, channelGroupName, startIndex, maxNumSamplesAcrossChannels - startIndex );
else 
T = createEmptyChannelTable( info, channelGroupName );
end 
else 
T = readChannelsToTable( info, channelGroupName, startIndex, readSize );
end 

end 

function T = createEmptyChannelTable( info, channelGroupName )
import matlab.io.tdms.internal.wrapper.utility.*
T = createChannelTable( getChannelNames( info, channelGroupName ), getMatlabDataType( info, channelGroupName ), 0 );
end 

function T = readChannelsToTable( info, channelGroupName, startIndex, readSize )
import matlab.io.tdms.internal.wrapper.utility.*
T = readChannels( info, startIndex, readSize, channelGroupName, getChannelNames( info, channelGroupName ) );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmprgKQFO.p.
% Please follow local copyright laws when handling this file.

