function roundingComp = getRoundingFunctionComp( hN, hInSignals, hOutSignals, op, compName, nfpOptions )



if nargin < 6
nfpOptions.Latency = int8( 0 );
nfpOptions.MantMul = int8( 0 );
nfpOptions.Denormals = int8( 0 );
end 

if ( nargin < 5 )
compName = 'RoundingFunction';
end 

if ( nargin < 4 )
op = 'floor';
end 

roundingComp = pircore.getRoundingFunctionComp( hN, hInSignals, hOutSignals, op, compName, nfpOptions );

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpCFP7qy.p.
% Please follow local copyright laws when handling this file.

