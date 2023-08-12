function [ file, id ] = decomposeRangeIdentifier( aRangeIdentifier )







R36
aRangeIdentifier( 1, 1 )string
end 
splits = split( aRangeIdentifier, '|' );
fileWithAngles = splits( 1 );
file = extractBetween( fileWithAngles, 2, strlength( fileWithAngles ) - 1 );
id = splits( 2 );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpOB4XBX.p.
% Please follow local copyright laws when handling this file.

