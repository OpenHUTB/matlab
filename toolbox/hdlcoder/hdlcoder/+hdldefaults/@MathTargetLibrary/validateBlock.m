function v = validateBlock( this, hC )



v = hdlvalidatestruct;

isNFP = targetcodegen.targetCodeGenerationUtils.isNFPMode(  );

if ~( targetcodegen.targetCodeGenerationUtils.isAlteraMode(  ) || isNFP )
assert( targetmapping.hasFloatingPointPort( hC ) );
v( end  + 1 ) = hdlvalidatestruct( 1, message( 'hdlcoder:validate:TargetInvalidarch' ) );
else 
hInSignals = hC.PirInputSignals;
hT = getPirSignalBaseType( hInSignals( 1 ).Type );
hLeafType = hT.getLeafType;
if ~( targetmapping.isValidDataType( hLeafType ) )
v( end  + 1 ) = hdlvalidatestruct( 1, message( 'hdlcoder:validate:TargetInvaliddatatype' ) );
end 
end 

fname = get_param( hC.SimulinkHandle, 'Function' );

if ~( isNFP && ( strcmp( fname, 'conj' ) || strcmp( fname, 'magnitude^2' ) || strcmp( fname, 'square' ) || strcmp( fname, 'hypot' ) ) )
v = [ v, validateComplex( this, hC, message( 'hdlcoder:validate:MathFunctionComplexUnsupported', fname ) ) ];
end 


if isNFP && targetmapping.hasFloatingPointPort( hC )
hInSignals = hC.PirInputSignals;
hT = getPirSignalBaseType( hInSignals( 1 ).Type );
hLeafType = hT.getLeafType;

if hLeafType.isDoubleType

if ~strcmpi( fname, 'reciprocal' ) && ~strcmpi( fname, 'log' )
v = [ v, hdlvalidatestruct( 1, message( 'hdlcommon:nativefloatingpoint:NFPContainsDoubleError' ) ) ];
end 
end 

if hLeafType.isHalfType && ~strcmpi( fname, 'reciprocal' )
v = [ v, hdlvalidatestruct( 1, message( 'hdlcommon:nativefloatingpoint:NFPContainsHalfError' ) ) ];
end 
end 

if isNFP && targetmapping.hasFloatingPointPort( hC ) && strcmpi( fname, 'reciprocal' )
nfpOptions = getNFPBlockInfo( this );
hInSignals = hC.PirInputSignals;
hT = getPirSignalBaseType( hInSignals( 1 ).Type );
hLeafType = hT.getLeafType;
if hLeafType.isSingleType
dataType = 'SINGLE';
elseif hLeafType.isHalfType
dataType = 'HALF';
else 
dataType = 'DOUBLE';
end 
if nfpOptions.Latency ~= int8( 0 )
fc = hdlgetparameter( 'FloatingPointTargetConfiguration' );
ipSettings = fc.IPConfig.getIPSettings( 'Recip', dataType );
if ( ipSettings.CustomLatency >= 0 ) && nfpOptions.Latency ~= int8( 4 )
v( end  + 1 ) = hdlvalidatestruct( 1, message( 'hdlcommon:nativefloatingpoint:NFPCustomLatencyLocalOptError',  ...
dataType, 'Recip' ) );
end 
nfpRadixStr = getImplParams( this, 'DivisionAlgorithm' );
if isempty( nfpRadixStr ) || contains( nfpRadixStr, '2' )
nfpOptions.Radix = int32( 2 );
else 
nfpOptions.Radix = int32( 4 );
end 

if strcmpi( dataType, 'SINGLE' )
maxLatency = ipSettings.MaxLatency - 24 + 12 * ( 4 / nfpOptions.Radix );
elseif strcmpi( dataType, 'HALF' )
maxLatency = ipSettings.MaxLatency - 10 + 5 * ( 4 / nfpOptions.Radix );
else 
maxLatency = ipSettings.MaxLatency - 50 + 25 * ( 4 / nfpOptions.Radix );
end 
if ( nfpOptions.Latency == int8( 4 ) ) && ( nfpOptions.CustomLatency > maxLatency )
v( end  + 1 ) = hdlvalidatestruct( 1, message( 'hdlcommon:nativefloatingpoint:InvalidCustomLatencySpecified',  ...
hC.getBlockPath, num2str( maxLatency ) ) );
end 
end 
end 

in1signal = hC.PirInputPorts( 1 ).Signal;
if ( targetcodegen.targetCodeGenerationUtils.isAlteraMode(  ) || targetcodegen.targetCodeGenerationUtils.isXilinxMode(  ) ) && in1signal.Type.isMatrix
v = hdlvalidatestruct( 1,  ...
message( 'hdlcommon:targetcodegen:UnsupportedMatrixTypesTargetcodegen' ) );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpni1FzP.p.
% Please follow local copyright laws when handling this file.

