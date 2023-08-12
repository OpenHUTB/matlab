function padSize = getChannelPadSize( startIndex, readSize, numSamples )




R36
startIndex( 1, 1 )uint64
readSize( 1, 1 )uint64
numSamples( 1, : )uint64
end 
assert( startIndex + readSize <= max( numSamples ) );
padSize = ( startIndex + readSize ) - numSamples;
padSize = max( padSize, uint64( 0 ) );
padSize = min( padSize, readSize );
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpyE92sR.p.
% Please follow local copyright laws when handling this file.

