function hNewC = elaborate( this, hN, blockComp )


hInSignals = blockComp.PirInputSignals;
hOutSignals = blockComp.PirOutputSignals;
fname = get_param( blockComp.SimulinkHandle, 'Function' );
outSigType = get_param( blockComp.SimulinkHandle, 'OutputSignalType' );
nfpOptions = getNFPBlockInfo( this );



if strcmp( fname, 'mod' ) || strcmp( fname, 'rem' )

nfpModRemCheckResetToZeroStr = getImplParams( this, 'CheckResetToZero' );

if isempty( nfpModRemCheckResetToZeroStr ) || strcmp( nfpModRemCheckResetToZeroStr, 'on' )
nfpOptions.ModRemCheckResetToZero = true;
elseif strcmp( nfpModRemCheckResetToZeroStr, 'off' )
nfpOptions.ModRemCheckResetToZero = false;
end 

nfpModRemMaxIterationsStr = getImplParams( this, 'MaxIterations' );

if isempty( nfpModRemMaxIterationsStr ) || strcmp( nfpModRemMaxIterationsStr, '32' )
nfpOptions.ModRemMaxIterations = uint8( 32 );
elseif strcmp( nfpModRemMaxIterationsStr, '64' )
nfpOptions.ModRemMaxIterations = uint8( 64 );
elseif strcmp( nfpModRemMaxIterationsStr, '128' )
nfpOptions.ModRemMaxIterations = uint8( 128 );
end 
end 

if strcmp( fname, 'reciprocal' )

nfpRadixStr = getImplParams( this, 'DivisionAlgorithm' );

if isempty( nfpRadixStr ) || contains( nfpRadixStr, '2' )
nfpOptions.Radix = int32( 2 );
else 
nfpOptions.Radix = int32( 4 );
end 
end 

if ~isfield( nfpOptions, 'MantMul' )
nfpOptions.MantMul = int8( 0 );
end 




if strcmp( fname, 'square' )
hNewC = squareDetailedImpl( this, hN, blockComp, hInSignals, hOutSignals, nfpOptions, outSigType );


elseif strcmp( fname, 'conj' )
hNewC = conjDetailedImpl( this, hN, blockComp, hInSignals, hOutSignals, outSigType );


elseif strcmp( fname, 'hypot' )
hNewC = hypotDetailedImpl( this, hN, blockComp, hInSignals, hOutSignals, nfpOptions, outSigType );



else 
hNewC = pirelab.getMathComp( hN, hInSignals, hOutSignals, blockComp.Name,  ...
blockComp.SimulinkHandle, fname, nfpOptions );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpGTTbQs.p.
% Please follow local copyright laws when handling this file.

