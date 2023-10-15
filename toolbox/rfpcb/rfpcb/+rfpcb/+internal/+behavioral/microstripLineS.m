function S = microstripLineS( obj, freq, z0 )

arguments
    obj( 1, 1 )
    freq( 1, : ){ mustBeFinite, mustBeNonnegative, mustBeVector }
    z0( 1, 1 ){ mustBeFinite, mustBePositive } = 50
end

ckt = circuit;
tx = txlineMicrostrip( obj );
add( ckt, [ 1, 2, 0, 0 ], tx )
setports( ckt, [ 1, 0 ], [ 2, 0 ] )
S = sparameters( ckt, freq, z0 );
end

