function hC = getTBStimulusSwitchComp( hN, hInSignals, hOutSignal, hSelSignal, compName )


narginchk( 5, 5 );

assert( logical( hInSignals( 1 ).Type.isEqual( hOutSignal.Type ) ) );
assert( logical( hInSignals( 2 ).Type.isEqual( hOutSignal.Type ) ) );

hC = pircore.getTBStimulusSwitchComp( hN, hInSignals, hOutSignal, hSelSignal, compName );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpBxFQCi.p.
% Please follow local copyright laws when handling this file.

