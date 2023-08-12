function vol = rescaleVolume( vol, r, g, b, dataBounds )




R36

vol
r = [  ];
g = [  ];
b = [  ];
dataBounds = [  ];

end 

if ndims( vol ) == 4
RGB = vol;
clear vol;
vol( :, :, :, 1 ) = rescale( RGB( :, :, :, 1 ), r );
vol( :, :, :, 2 ) = rescale( RGB( :, :, :, 2 ), g );
vol( :, :, :, 3 ) = rescale( RGB( :, :, :, 3 ), b );
else 



if isempty( dataBounds )
limits = single( [ min( vol( : ) ), max( vol( : ) ) ] );
else 
limits = single( dataBounds );
end 

if limits( 2 ) == limits( 1 )


vol = im2uint8( vol );
else 
vol = rescale( vol, limits );
end 

end 

end 

function vol = rescale( vol, limits )

if limits( 2 ) == limits( 1 )


vol = zeros( size( vol ), 'uint8' );
else 





vol = uint8( ( single( vol ) - single( limits( 1 ) ) ) ./ ( single( limits( 2 ) - limits( 1 ) ) ) * 255 );
end 

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpEZCo3x.p.
% Please follow local copyright laws when handling this file.

