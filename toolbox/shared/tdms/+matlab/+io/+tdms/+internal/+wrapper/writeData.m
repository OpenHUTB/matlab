function data = writeData( filePath, data, channelGroupNames, format )

arguments
    filePath( 1, 1 )string
    data( 1, : )cell
    channelGroupNames( 1, : )string = string.empty
    format matlab.io.tdms.internal.wrapper.TimeChannel = matlab.io.tdms.internal.wrapper.TimeChannel.single
end
import matlab.io.tdms.internal.*

data = formatData( data );
channelGroupNames = getValidChannelGroupNames( filePath, length( data ), channelGroupNames );
validateLayoutRequirements( channelGroupNames, data, format );

for k = 1:length( data )
    if istimetable( data{ k } )
        writeWaveform( filePath, data{ k }, channelGroupNames{ k }, format )
    else
        writeNonWaveform( filePath, data{ k }, channelGroupNames{ k } );
    end
end
end

function validateLayoutRequirements( channelGroupNames, data, format )
import matlab.io.tdms.internal.*

if length( channelGroupNames ) ~= length( data )
    error( message( "tdms:TDMS:MismatchInCellArrayAndChannelGroupSize" ) );
end
if format == wrapper.TimeChannel.none
    validateNoTimeChannelLayoutReq( data );
end
end

function channelGroupNames = getValidChannelGroupNames( filePath, channelGroupCount, channelGroupNames )
import matlab.io.tdms.internal.*
if utility.isEmptyString( channelGroupNames )
    if isfile( filePath )
        channelGroupNames = wrapper.utility.getChannelGroupNames( wrapper.readInfo( filePath ) );
        channelGroupNames = wrapper.utility.createUniqueChannelGroupNames( channelGroupCount, channelGroupNames );
    else
        channelGroupNames = wrapper.utility.createUniqueChannelGroupNames( channelGroupCount );
    end
end
end

function validateNoTimeChannelLayoutReq( data )
f = @( tt )~( ( istimetable( tt ) && isregular( tt ) ) || istable( tt ) );
if any( cellfun( f, data ) )
    eid = "tdms:TDMS:NoTimeChannelLayoutError";
    throwAsCaller( MException( eid, message( eid ) ) );
end
end

function writeWaveform( filePath, data, channelGroupName, format )
import matlab.io.tdms.internal.*
switch format
    case wrapper.TimeChannel.none
        wrapper.utility.writeNoTimeChannel( filePath, data, channelGroupName );
    case wrapper.TimeChannel.single
        wrapper.utility.writeSingleTimeChannel( filePath, data, channelGroupName );
    otherwise
        assert( false, "Unknown Waveform Layout: " + string( format ) + " in writeData" );
end
end

function writeNonWaveform( filePath, data, channelGroupName )
matlab.io.tdms.internal.wrapper.utility.writeNoTimeData( filePath, data, channelGroupName );
end

function data = formatData( data )
data = cellfun( @formatTable, data, UniformOutput = false );
end

function data = formatTable( data )
data = matlab.io.tdms.internal.wrapper.utility.daqdurationtt2datetimett( splitvars( data ) );
end


