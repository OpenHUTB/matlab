function C = readFile( info, startIndex, readSize )

arguments
    info( 1, 1 )matlab.io.tdms.TdmsInfo
    startIndex( 1, 1 )uint64
    readSize( 1, 1 )uint64
end
import matlab.io.tdms.internal.wrapper.utility.*

C = readChannelGroups( info, startIndex, readSize, getChannelGroupNames( info ) );

end
