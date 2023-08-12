function [ a, b ] = d2ci( phi, gam, t )


















narginchk( 3, 3 );
error( abcdchk( phi, gam ) );

[ m, n ] = size( phi );
[ m, nb ] = size( gam );



if m == 1
if phi == 1
a = 0;b = gam / t;
return 
end 
end 


b = zeros( m, nb );
nonzero = find( sum( abs( gam ) ) ~= 0 );
nz = length( nonzero );



[ s, errest ] = logm( [ [ phi, gam( :, nonzero ) ];zeros( nz, n ), eye( nz ) ] );
s = s / t;
a = s( 1:n, 1:n );
b( :, nonzero ) = s( 1:n, n + 1:n + nz );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpnMAGfi.p.
% Please follow local copyright laws when handling this file.

