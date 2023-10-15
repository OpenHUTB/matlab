function channelData = formatMexWriteData( channelData )

arguments
    channelData( 1, : )
end
import matlab.io.tdms.internal.wrapper.*
if isempty( channelData )
    return
end
if isdatetime( channelData ) || isduration( channelData )
    channelData = utility.getAbsoluteTime( channelData );
else
    channelData = convertCharsToStrings( channelData );
end
end

