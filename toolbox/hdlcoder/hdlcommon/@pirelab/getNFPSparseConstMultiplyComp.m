function coreComp = getNFPSparseConstMultiplyComp( hN, hInSignals, hOutSignals,  ...
constMatrixSize, constMatrix, latency, sharingFactor, fpDelays, nfpOptions, name )



if ( nargin < 8 )
name = 'nfpsparseconstmultiply';
end 

coreComp = pircore.getNFPSparseConstMultiplyComp( hN, hInSignals, hOutSignals,  ...
constMatrixSize, constMatrix, latency, sharingFactor, fpDelays, nfpOptions, name );

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpiA3s8k.p.
% Please follow local copyright laws when handling this file.

