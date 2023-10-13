function fqStruct = extractFlightPhase( fqStruct, flightphase )

arguments
fqStruct
flightphase( 1, 1 )string
end 

fqStruct = fqStruct( :, [ fqStruct( 1, : ).FlightPhase ] == flightphase );
end 



