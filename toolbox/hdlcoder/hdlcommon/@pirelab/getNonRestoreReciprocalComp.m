function hC = getNonRestoreReciprocalComp( hN, hInSignals, hOutSignals, reciprocalInfo )



hC = elaborate_scalar( hN, hInSignals, hOutSignals, reciprocalInfo );
end 
function hC = elaborate_scalar( hN, hInSignals, hOutSignals, reciprocalInfo )

hNonRestoreNet = pirelab.getNonRestoreReciprocalNetwork( hN, hInSignals, hOutSignals, reciprocalInfo );

hC = pirelab.instantiateNetwork( hN, hNonRestoreNet, hInSignals, hOutSignals, 'Reciprocal' );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmp3HvhwF.p.
% Please follow local copyright laws when handling this file.

