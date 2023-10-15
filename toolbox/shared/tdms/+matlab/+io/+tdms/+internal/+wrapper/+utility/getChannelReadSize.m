function readSizes = getChannelReadSize( startIndex, readSize, numSamples )

arguments
    startIndex( 1, 1 )uint64
    readSize( 1, 1 )uint64
    numSamples( 1, : )uint64
end
import matlab.io.tdms.internal.wrapper.utility.*
assert( startIndex + readSize <= max( numSamples ) );
readSizes = readSize - getChannelPadSize( startIndex, readSize, numSamples );
end

