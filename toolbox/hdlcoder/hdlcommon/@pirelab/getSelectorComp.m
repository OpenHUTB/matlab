function selectorComp = getSelectorComp( hN, hInSignals, hOutSignals, indexMode,  ...
indexOptionArray, indexParamArray, outputSizeArray, numDims, compName,  ...
inputPortWidth, nfpOptions )


if nargin < 11
nfpOptions.Latency = int8( 0 );
nfpOptions.MantMul = int8( 0 );
nfpOptions.Denormals = int8( 0 );
end 

if nargin < 10
inputPortWidth =  - 1;
end 

if nargin < 9
compName = 'Selector';
end 

inSigs = hInSignals;
inType = hInSignals( 1 ).Type;
nfpMode = targetcodegen.targetCodeGenerationUtils.isNFPMode;
oneBasedIdx = 0;
if strcmpi( indexMode, 'one-based' )
oneBasedIdx = 1;
end 

if numel( hInSignals ) == 2 && strcmp( numDims, '1' )

if inputPortWidth ==  - 1


if inType.isArrayType
inDim = inType.Dimensions;
else 
inDim = 1;
end 
inputPortWidth = [ 1, inDim ];
end 

inSigs( 2 ) = handleSpecialSelectionTypes( inSigs( 2 ), prod( inputPortWidth ) );
elseif strcmp( numDims, '2' )




portIdx = [ 0, find( reshape( contains( indexOptionArray, 'port' ), 1, length( indexOptionArray ) ) ) ];

if inputPortWidth ==  - 1
if inType.isArrayType
inputPortWidth = inType.Dimensions;
if numel( inputPortWidth ) < 2
if inType.isRowVector
inputPortWidth = [ 1, inputPortWidth ];
else 
inputPortWidth = [ inputPortWidth, 1 ];
end 
end 
else 
inputPortWidth = [ 1, 1 ];
end 
end 

for ii = 2:numel( portIdx )

inSigs( ii ) = handleSpecialSelectionTypes( inSigs( ii ), inputPortWidth( portIdx( ii ) ) );
end 
end 

selectorComp = pircore.getSelectorComp( hN, inSigs, hOutSignals, indexMode,  ...
indexOptionArray, indexParamArray, outputSizeArray, numDims, compName );

function selSig = handleSpecialSelectionTypes( selSig, inputPortWidth )


selType = selSig.Type.getLeafType;
if nfpMode && selType.isFloatType

floatConvSig = pirelab.insertFloat2IdxDTCCompOnInput( hN, selSig,  ...
inputPortWidth, oneBasedIdx, [ compName, '_dtc_comp' ], nfpOptions );

selSig = floatConvSig;
elseif ~selType.isFloatType && selType.isNumericType && selType.FractionLength < 0

uintT = getSmallestUintType( inputPortWidth, oneBasedIdx );
fiConvSig = pirelab.insertDTCCompOnInput( hN, selSig, uintT,  ...
'Zero', 'Wrap', [ compName, '_dtc_comp' ] );

selSig = fiConvSig;
end 
end 

end 

function uintT = getSmallestUintType( width, oneBasedIdx )




minimumSelectBitsNeeded = ceil( log2( double( width + oneBasedIdx ) ) );

smallestByteAddressableDT = min( max( 2 ^ ceil( log2( minimumSelectBitsNeeded ) ),  ...
8 ), 32 );
uintT = pir_unsigned_t( smallestByteAddressableDT );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpgBzctu.p.
% Please follow local copyright laws when handling this file.

