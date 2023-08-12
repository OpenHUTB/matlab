function pass = getMapDelayToRam( hInSignal, delayNumber, ramThreshold )



if nargin < 3
ramThreshold = hdlgetparameter( 'rammappingthreshold' );
end 

if delayNumber < 4
pass = false;
else 

[ dimlen, hBT ] = pirelab.getVectorTypeInfo( hInSignal );

if numel( dimlen ) == 1

if hdlsignaliscomplex( hInSignal )
hBT = hBT.BaseType;
dimlen = dimlen * 2;
end 

ramsize = dimlen * hBT.WordLength * delayNumber;

pass = ( ramsize >= ramThreshold );
else 

pass = false;
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpO6LpxH.p.
% Please follow local copyright laws when handling this file.

