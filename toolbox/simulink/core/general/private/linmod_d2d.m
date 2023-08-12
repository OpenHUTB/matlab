function [ a, b ] = linmod_d2d( phi, gam, t1, t2 )














narginchk( 4, 4 );
error( abcdchk( phi, gam ) );

[ m, n ] = size( phi );
[ m, nb ] = size( gam );


b = zeros( m, nb );
nonzero = [ 1:nb ];


rTs = t2 / t1;
if abs( round( rTs ) - rTs ) < sqrt( eps ) * rTs
rTs = round( rTs );
end 

RealFlag = isreal( phi ) & isreal( gam );

p = eig( phi );
if any( imag( p ) == 0 & real( p ) <= 0 ) & rem( rTs, 1 )

s = [ phi, gam( :, nonzero );zeros( nb, n ), eye( nb ) ] ^ rTs;
if RealFlag
s = real( s );
end 
a = s( 1:n, 1:n );
if length( nonzero )
b( :, nonzero ) = s( 1:n, n + 1:n + nb );
end 









else 

if rTs == round( rTs ), 
s = [ phi, gam( :, nonzero );zeros( nb, n ), eye( nb ) ] ^ rTs;
else 

M = [ phi, gam( :, nonzero );zeros( nb, n ), eye( nb ) ];
if ~isempty( M )
s = expm( rTs * logm( M ) );
else 
s = [  ];
end 
end 
if RealFlag
s = real( s );
end 
a = s( 1:n, 1:n );
if length( nonzero )
b( :, nonzero ) = s( 1:n, n + 1:n + nb );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmprwk7hR.p.
% Please follow local copyright laws when handling this file.

