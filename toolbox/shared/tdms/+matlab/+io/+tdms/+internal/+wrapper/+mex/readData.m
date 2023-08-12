function channelData = readData( filePath, startIndex, readSize, channelGroupName, channelName )



R36
filePath( 1, 1 )string
startIndex( 1, 1 )uint64
readSize( 1, 1 )uint64
channelGroupName( 1, 1 )string
channelName( 1, 1 )string
end 
import matlab.io.tdms.internal.wrapper.mex.*
utility.licenseCheck(  );
channelData = mexTDMS( int8( OperationType.Read ), filePath, startIndex, readSize, channelGroupName, channelName );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp2bjqcR.p.
% Please follow local copyright laws when handling this file.

