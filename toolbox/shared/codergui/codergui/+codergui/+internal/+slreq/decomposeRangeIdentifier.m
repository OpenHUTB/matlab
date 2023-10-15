function [ file, id ] = decomposeRangeIdentifier( aRangeIdentifier )

arguments
    aRangeIdentifier( 1, 1 )string
end
splits = split( aRangeIdentifier, '|' );
fileWithAngles = splits( 1 );
file = extractBetween( fileWithAngles, 2, strlength( fileWithAngles ) - 1 );
id = splits( 2 );
end
