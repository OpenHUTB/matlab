function channelData = formatMexData( channelData )



R36
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
% Decoded using De-pcode utility v1.2 from file /tmp/tmpDULQM5.p.
% Please follow local copyright laws when handling this file.

