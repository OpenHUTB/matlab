function T = readChannels( info, startIndex, readSize, channelGroupName, channelNames )

arguments
    info( 1, 1 )matlab.io.tdms.TdmsInfo
    startIndex( 1, 1 )uint64
    readSize( 1, 1 )uint64
    channelGroupName( 1, 1 )string
    channelNames( 1, : )string
end

import matlab.io.tdms.internal.wrapper.utility.*

numSamplesAcrossChannels = getNumSamples( info, channelGroupName, channelNames );
maxNumSamplesAcrossChannels = max( numSamplesAcrossChannels );

assert( startIndex + readSize <= maxNumSamplesAcrossChannels,  ...
    sprintf( "readChannels out of Bounds. startIndex(%u) + readSize(%u) <= max(numSamplesAcrossChannels)(%u)",  ...
    startIndex, readSize, maxNumSamplesAcrossChannels ) );

readSizeAcrossChannels = getChannelReadSize( startIndex, readSize, numSamplesAcrossChannels );
T = readChannelsToTable( info, channelGroupName, channelNames, startIndex, readSizeAcrossChannels );
end

function T = readChannelsToTable( info, channelGroupName, channelNames, startIndex, readSizes )
import matlab.io.tdms.internal.wrapper.*
maxReadSize = max( readSizes );
T = reserveTable( info, channelGroupName, channelNames, maxReadSize );
if ~isempty( T )
    for i = 1:length( channelNames )
        T.( channelNames( i ) ) =  ...
            utility.padVector(  ...
            utility.formatMexData(  ...
            mexReadData( info, channelGroupName, channelNames( i ), startIndex, readSizes( i ) ) ), maxReadSize )';
    end
end
end

function T = reserveTable( info, channelGroupName, channelNames, readSize )
import matlab.io.tdms.internal.wrapper.utility.*
T = createChannelTable( channelNames, getMatlabDataType( info, channelGroupName, channelNames ), readSize );
end

function data = mexReadData( info, channelGroupName, channelName, startIndex, channelReadSize )
import matlab.io.tdms.internal.wrapper.*
if channelReadSize == 0
    data = utility.getEmptyType( utility.getMatlabDataType( info, channelGroupName, channelName ) );
else
    data = mex.readData( info.Path, startIndex, channelReadSize, channelGroupName, channelName );
end
end
