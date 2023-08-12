function S = coplanarWaveguideS( obj, freq, z0 )




R36
obj( 1, 1 )
freq( 1, : ){ mustBeFinite, mustBeNonnegative, mustBeVector }
z0( 1, 1 ){ mustBeFinite, mustBePositive } = 50
end 

validateattributes( freq, { 'double' }, { 'increasing' }, 2 )

ckt = circuit;
add( ckt, [ 1, 2, 0, 0 ], txlineCPW( obj ) )
setports( ckt, [ 1, 0 ], [ 2, 0 ] )
S = sparameters( ckt, freq, z0 );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpkGIZ6s.p.
% Please follow local copyright laws when handling this file.

