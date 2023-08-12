function outputVector = scalarExpand( hN, hInScalar, numElements, isRowVector )




if nargin < 4
isRowVector = 0;
end 

if isRowVector
portDims = [ 1, numElements ];
else 
portDims = numElements;
end 
hT = pirelab.getPirVectorType( hInScalar.Type, portDims );

outputVector = hN.addSignal( hT, sprintf( '%s_scalarexpand', hInScalar.Name ) );
hMuxInSignals = repmat( hInScalar, 1, numElements );
hMuxComp = pirelab.getMuxComp( hN, hMuxInSignals, outputVector );
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpUDZ39u.p.
% Please follow local copyright laws when handling this file.

