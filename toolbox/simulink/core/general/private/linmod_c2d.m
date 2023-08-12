function [ Phi, Gamma ] = linmod_c2d( a, b, t )

















narginchk( 3, 3 );
error( abcdchk( a, b ) );

[ m, n ] = size( a );
[ m, nb ] = size( b );
s = expm( [ [ a, b ] * t;zeros( nb, n + nb ) ] );
Phi = s( 1:n, 1:n );
Gamma = s( 1:n, n + 1:n + nb );



% Decoded using De-pcode utility v1.2 from file /tmp/tmp7HwcGP.p.
% Please follow local copyright laws when handling this file.

