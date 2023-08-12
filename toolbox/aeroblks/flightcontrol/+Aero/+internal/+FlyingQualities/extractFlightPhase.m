function fqStruct = extractFlightPhase( fqStruct, flightphase )




R36
fqStruct
flightphase( 1, 1 )string
end 

fqStruct = fqStruct( :, [ fqStruct( 1, : ).FlightPhase ] == flightphase );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpndMASA.p.
% Please follow local copyright laws when handling this file.

