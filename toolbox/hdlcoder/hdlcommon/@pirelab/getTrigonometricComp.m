function trigComp = getTrigonometricComp( hN, hInSignals, hOutSignals, compName, slbh, fname, nfpOptions )




if nargin < 7
nfpOptions.Latency = int8( 0 );
nfpOptions.MantMul = int8( 0 );
nfpOptions.Denormals = int8( 0 );
nfpOptions.ArgReduction = true;
end 

trigComp = pircore.getTrigonometricComp( hN, hInSignals, hOutSignals, compName, slbh, fname, nfpOptions );

% Decoded using De-pcode utility v1.2 from file /tmp/tmps4YUA6.p.
% Please follow local copyright laws when handling this file.

