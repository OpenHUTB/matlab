function channelData = formatMexWriteData( channelData )



R36
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
% Decoded using De-pcode utility v1.2 from file /tmp/tmpza0mE8.p.
% Please follow local copyright laws when handling this file.

