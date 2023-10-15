function C = readData( filePath, startIndex, readSize, channelGroupName, channelNames )

arguments
    filePath( 1, 1 )string
    startIndex( 1, 1 )uint64
    readSize( 1, 1 )uint64
    channelGroupName( 1, 1 )string = ""
    channelNames( 1, : )string = string.empty
end
import matlab.io.tdms.internal.*

assert( ~( utility.isEmptyString( channelGroupName ) && ~utility.isEmptyString( channelNames ) ),  ...
    sprintf( "ChannelNames should have ChannelGroupName" ) );

info = wrapper.readInfo( filePath );
if utility.isEmptyString( channelGroupName ) && utility.isEmptyString( channelNames )
    C = wrapper.utility.readFile( info, startIndex, readSize );
elseif utility.isEmptyString( channelNames )
    C = wrapper.utility.readChannelGroups( info, startIndex, readSize, channelGroupName );
else
    C = { wrapper.utility.readChannels( info, startIndex, readSize, channelGroupName, channelNames ) };
end

end

