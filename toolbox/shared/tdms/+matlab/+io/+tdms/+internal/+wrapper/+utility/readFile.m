function C = readFile( info, startIndex, readSize )




R36
info( 1, 1 )matlab.io.tdms.TdmsInfo
startIndex( 1, 1 )uint64
readSize( 1, 1 )uint64
end 
import matlab.io.tdms.internal.wrapper.utility.*

C = readChannelGroups( info, startIndex, readSize, getChannelGroupNames( info ) );

end 






% Decoded using De-pcode utility v1.2 from file /tmp/tmp3y6a7L.p.
% Please follow local copyright laws when handling this file.

