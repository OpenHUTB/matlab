function readSizes = getChannelReadSize( startIndex, readSize, numSamples )




R36
startIndex( 1, 1 )uint64
readSize( 1, 1 )uint64
numSamples( 1, : )uint64
end 
import matlab.io.tdms.internal.wrapper.utility.*
assert( startIndex + readSize <= max( numSamples ) );
readSizes = readSize - getChannelPadSize( startIndex, readSize, numSamples );
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpn8RTkS.p.
% Please follow local copyright laws when handling this file.

