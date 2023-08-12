function cgirComp = getLibBitShiftComp( hN, hInSignals, hOutSignals, opName, shiftLength, compName )






if ( nargin < 6 )
compName = 'bitopShift';
end 

cgirComp = pircore.getLibBitShiftComp( hN, hInSignals, hOutSignals, opName, shiftLength, compName );

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp8_DI09.p.
% Please follow local copyright laws when handling this file.

