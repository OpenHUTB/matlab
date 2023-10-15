function writeProp( filePath, properties, channelGroupName, channelName )

arguments
    filePath( 1, 1 )string
    properties( 1, : )struct
    channelGroupName( 1, 1 )string = ""
    channelName( 1, 1 )string = ""
end

import matlab.io.tdms.internal.*

assert( ~( utility.isEmptyString( channelGroupName ) && ~utility.isEmptyString( channelName ) ),  ...
    sprintf( "ChannelNames should have ChannelGroupName" ) );

wrapper.mex.utility.licenseCheck(  );

if ~utility.isEmptyString( channelGroupName ) && ~utility.isEmptyString( channelName )
    mexTDMS( int8( wrapper.mex.OperationType.SetChannelProperties ), filePath, properties, channelGroupName, channelName );
elseif ~utility.isEmptyString( channelGroupName )
    mexTDMS( int8( wrapper.mex.OperationType.SetChannelGroupProperties ), filePath, properties, channelGroupName );
else
    mexTDMS( int8( wrapper.mex.OperationType.SetFileProperties ), filePath, properties );
end

end

