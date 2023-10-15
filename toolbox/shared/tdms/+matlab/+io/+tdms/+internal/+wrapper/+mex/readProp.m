function prop = readProp( filePath, channelGroupName, channelName )

arguments
    filePath( 1, 1 )string
    channelGroupName( 1, 1 )string = ""
    channelName( 1, 1 )string = ""
end

import matlab.io.tdms.internal.*

assert( ~( utility.isEmptyString( channelGroupName ) && ~utility.isEmptyString( channelName ) ),  ...
    sprintf( "ChannelNames should have ChannelGroupName" ) );

wrapper.mex.utility.licenseCheck(  );

if ~utility.isEmptyString( channelGroupName ) && ~utility.isEmptyString( channelName )
    prop = mexTDMS( int8( wrapper.mex.OperationType.GetChannelProperties ), filePath, channelGroupName, channelName );
elseif ~utility.isEmptyString( channelGroupName )
    prop = mexTDMS( int8( wrapper.mex.OperationType.GetChannelGroupProperties ), filePath, channelGroupName );
else
    prop = mexTDMS( int8( wrapper.mex.OperationType.GetFileProperties ), filePath );
end

end

