function hC = getTBTimeDelayComp( hN, hInSignal, hOutSignal, timeDelay, compName )


narginchk( 4, 5 );

if nargin < 5
compName = [ hInSignal.Name, '_delay' ];
end 

assert( logical( hInSignal.Type.isEqual( hOutSignal.Type ) ) );



intTD = round( timeDelay );
hC = pircore.getTBTimeDelayComp( hN, hInSignal, hOutSignal, intTD, compName );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpx3eLe5.p.
% Please follow local copyright laws when handling this file.

