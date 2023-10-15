function writeData( filePath, data, channelGroupName, channelName )

arguments
    filePath( 1, 1 )string
    data( 1, : )
    channelGroupName( 1, 1 )string
    channelName( 1, 1 )string
end
import matlab.io.tdms.internal.wrapper.mex.*
utility.licenseCheck(  );
mexTDMS( int8( OperationType.Write ), filePath, data, channelGroupName, channelName );
end

