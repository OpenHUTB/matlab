function Serializer1DComp = getSerializer1DComp( hN, hInSignals, hOutSignals, ratio, idleCycles, validInPort, startOutPort, validOutPort, compName )











if ( nargin < 9 )
compName = 'Serializer1D';
end 

Serializer1DComp = pircore.getSerializer1DComp( hN, hInSignals, hOutSignals, ratio, idleCycles, validInPort, startOutPort, validOutPort, compName );
% Decoded using De-pcode utility v1.2 from file /tmp/tmp4SQ7q8.p.
% Please follow local copyright laws when handling this file.

