function channelData = formatMexData( channelData )

arguments
    channelData( 1, : )
end
import matlab.io.tdms.internal.wrapper.*
if isempty( channelData )
    return
end
if isstruct( channelData )
    channelData = utility.getDateTime( channelData );
else
    channelData = convertCharsToStrings( channelData' );
end
end
