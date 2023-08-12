function [ f, g ] = trimfcn( DES, fcn, t, x0, u0, y0, ix, iu, iy, dx0, idx )









nx = length( x0 );
x = DES( 1:nx );
u = DES( nx + 1:nx + length( u0 ) );
lambda = DES( length( DES ) );




y = feval( fcn, t, x, u, 'outputs' );
dx = feval( fcn, t, x, u, 'derivs' );




gg = [ x( ix ) - x0( ix );y( iy ) - y0( iy );u( iu ) - u0( iu ) ];
g = [ dx( idx ) - dx0( idx );gg - lambda; - gg - lambda ];




f = lambda;


% Decoded using De-pcode utility v1.2 from file /tmp/tmpzsoMdR.p.
% Please follow local copyright laws when handling this file.

