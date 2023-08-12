function cgirComp = getLookupNDComp( hN, hInSignals, hOutSignals,  ...
table_data, powerof2, bpType, oType, fType, interpVal, bp_data, compName, slbh, dims, rndMode, satMode, diagnostics, extrap, spacing, nfpOptions, mapToRAM )

















if ( nargin < 19 )
mapToRAM = true;
end 

if ( nargin < 18 )
nfpOptions.Latency = int8( 0 );
nfpOptions.Denormals = int8( 0 );
nfpOptions.MantMul = int8( 0 );
nfpOptions.PrecomputeCoefficients = false;
end 

if ( nargin < 17 )
extrap = 'Clip';
end 

if ( nargin < 16 )
diagnostics = 'None';
end 

if ( nargin < 15 )
satMode = 'Wrap';
end 

if ( nargin < 14 )
rndMode = 'Floor';
end 

if ( nargin < 13 )
dims = 1;
end 


if ( nargin < 12 || isempty( slbh ) )
slbh =  - 1;
end 

if ( nargin < 11 )
compName = 'LUTnD';
end 

assert( length( powerof2 ) == dims, 'powerof2 must have dim elements' );

if ~iscell( bpType )
bpType = { bpType };
end 


tableSize = numel( bp_data{ 1 } );
biggerDim = ceil( log2( tableSize ) );
if numel( bp_data ) == 2
tableSize = tableSize * numel( bp_data{ 2 } );
secondDim = ceil( log2( numel( bp_data{ 2 } ) ) );
if ( secondDim > biggerDim )
biggerDim = secondDim;
end 
end 



if ( any( arrayfun( @( x )x.Type.getLeafType.isFloatType, hInSignals ) ) && isfloat( oType ) && isfloat( fType ) &&  ...
interpVal <= 1 )

cgirComp = getLookupNDEarlyElab( hN, hInSignals, hOutSignals,  ...
table_data, oType, fType, interpVal, bp_data, compName, slbh, dims, extrap, spacing, nfpOptions, mapToRAM );


else 
if numel( bp_data ) == 1 && bpType{ 1 }.WordLength == 1
cgirComp = elabLUTAsSwitchComp( hN, hInSignals, hOutSignals, bp_data{ 1 },  ...
table_data, compName );
else 
if numel( hInSignals ) > 1

hasScalar = false;
hasVector = false;
scalarInputs = [  ];
vectorType = [  ];
for ii = 1:numel( hInSignals )
if hInSignals( ii ).Type.isArrayType
hasVector = true;
vectorType = hInSignals( ii ).Type;
else 
hasScalar = true;
scalarInputs = [ scalarInputs, ii ];%#ok<AGROW>
end 
end 

if hasScalar && hasVector

for ii = 1:numel( scalarInputs )
scalarInputIdx = scalarInputs( ii );

muxOutSignal = hN.addSignal( vectorType, [ hInSignals( scalarInputIdx ).Name, '_expanded' ] );
muxOutSignal.SimulinkRate = hInSignals( scalarInputIdx ).SimulinkRate;


pirelab.getMuxComp( hN, repmat( hInSignals( scalarInputIdx ), 1, vectorType.Dimensions ), muxOutSignal );


hInSignals( scalarInputIdx ) = muxOutSignal;
end 
end 
end 

cgirComp = pircore.getLookupNDComp( hN, hInSignals, hOutSignals,  ...
table_data, powerof2, bpType, oType, fType, interpVal, bp_data, compName, slbh, dims, rndMode, satMode, diagnostics, extrap, mapToRAM );
cgirComp.setLargeDimension( biggerDim );
end 
end 
end 





function comp = elabLUTAsSwitchComp( hN, selSignal, hOutSignal, bp_data,  ...
table_data, compName )
hT = hOutSignal( 1 ).Type;
hSig0 = hN.addSignal( hT, 'tableData0' );
hSig0.SimulinkRate = selSignal.SimulinkRate;
hSig1 = hN.addSignal( hT, 'tableData1' );
hSig1.SimulinkRate = selSignal.SimulinkRate;
pirelab.getConstComp( hN, hSig0, table_data( 1 ) );
pirelab.getConstComp( hN, hSig1, table_data( 2 ) );
selType = selSignal.Type;
if selType.isWordType && selType.FractionLength < 0
selSig = hN.addSignal( pir_boolean_t, 'sel' );
selSig.SimulinkRate = selSignal.SimulinkRate;
pirelab.getCompareToValueComp( hN, selSignal, selSig, '==', bp_data( 2 ) );
selSignal = selSig;
end 


comp = pirelab.getSwitchComp( hN, [ hSig1, hSig0 ], hOutSignal, selSignal,  ...
compName, '~=', 0 );
end 

function earlyElabNIC = getLookupNDEarlyElab( hN, hInSignals, hOutSignals,  ...
table_data, ~, ~, interpVal, bp_data, compName, ~, dims, extrap, spacing, nfpOptions, mapToRAM )












hInSignalsOrig = hInSignals;
hOutSignalsOrig = hOutSignals;
hNOrig = hN;

earlyElabNetworkName = compName;

inportNames = cell( numel( hInSignalsOrig ), 1 );
for ii = numel( hInSignalsOrig ): - 1:1
inportNames{ ii } = strcat( 'in', num2str( ii ) );
inportTypes( ii ) = hInSignals( ii ).Type;
inportRates( ii ) = hInSignals( ii ).SimulinkRate;
end 

outportNames = { 'out' };
outportTypes = hOutSignals.Type;

hN = pirelab.createNewNetwork(  ...
'Network', hNOrig,  ...
'Name', earlyElabNetworkName,  ...
'InportNames', inportNames,  ...
'InportTypes', inportTypes,  ...
'InportRates', inportRates,  ...
'OutportNames', outportNames,  ...
'OutportTypes', outportTypes );



hInSignals = hN.PirInputSignals;
hOutSignals = hN.PirOutputSignals;
hOutSignals.SimulinkRate = hOutSignalsOrig.SimulinkRate;


slSigRate = hInSignals( 1 ).SimulinkRate;



signalType = hInSignals( 1 ).Type.BaseType;
if signalType.isHalfType(  )
typeStr = 'int16';
bp_data = cellfun( @( x )half( x ), bp_data, 'UniformOutput', false );

elseif signalType.isSingleType(  )
typeStr = 'int32';
bp_data = cellfun( @( x )single( x ), bp_data, 'UniformOutput', false );
else 
typeStr = 'int64';
bp_data = cellfun( @( x )double( x ), bp_data, 'UniformOutput', false );
end 



isTableComplex = false;
if ~isreal( table_data )
table_data_imag = imag( table_data );
table_data = real( table_data );
isTableComplex = true;


if hOutSignals.Type.isArrayType
[ dimLen, baseTypeOut ] = pirelab.getVectorTypeInfo( hOutSignals );
hT = pirelab.createPirArrayType( baseTypeOut.BaseType, dimLen );
else 
hT = hOutSignals.Type.BaseType;
end 
else 
hT = hOutSignals.Type;
end 

isLinearInterp = interpVal == 1;
isLinearExtrap = strcmpi( extrap, 'Linear' );
precomputeCoefficients = nfpOptions.PrecomputeCoefficients;

for ii = dims: - 1:1
satLower = 0;
numBP = numel( bp_data{ ii } );
if ~isLinearInterp

satUpper = numBP - 1;

bpWordLength = max( 1, ceil( log2( numBP ) ) );
else 

satUpper = numBP - 2;
if ~precomputeCoefficients


bpWordLength = max( 1, ceil( log2( numBP ) ) );
else 

bpWordLength = max( 1, ceil( log2( numBP - 1 ) ) );
end 
end 


fixType = pirelab.convertSLType2PirType( typeStr );
prelookupOutType = pir_unsigned_t( bpWordLength );
if hInSignals( ii ).Type.isArrayType(  )
dimLen = pirelab.getVectorTypeInfo( hInSignals( ii ) );
fixType = pirelab.createPirArrayType( fixType, dimLen );
prelookupOutType = pirelab.createPirArrayType( prelookupOutType, dimLen );
end 

hPrelookupOut( ii ) = hN.addSignal( prelookupOutType, 'prelookup_idx' );
hPrelookupOut( ii ).SimulinkRate = slSigRate;

[ sat_comp, float2FixSig ] = buildFloatPrelookupLogic( hN, hInSignals( ii ), hPrelookupOut( ii ), bp_data{ ii }, satLower, satUpper, fixType, compName, nfpOptions, typeStr, bpWordLength );

if isLinearInterp && ~isLinearExtrap


hTempSignal = hN.addSignal( hT, 'satout' );
hTempSignal.SimulinkRate = slSigRate;

threshold = numBP - 2;
buildClipExtrapSwitches( hN, hInSignals( ii ), float2FixSig, sat_comp.PirInputSignals( 1 ), hTempSignal, bp_data{ ii }( 1 ), bp_data{ ii }( end  ), threshold, hT, fixType, typeStr );
hInSignals( ii ) = hTempSignal;
end 
end 


if isTableComplex

hRealOut = hN.addSignal( hT, 'realOut' );
hRealOut.SimulinkRate = slSigRate;

hImagOut = hN.addSignal( hT, 'imagOut' );
hImagOut.SimulinkRate = slSigRate;
else 
hRealOut = hOutSignals;
end 

buildInterpLogic( isLinearInterp, dims, hN, hPrelookupOut, hInSignals, hRealOut, hT, table_data, bp_data, spacing, compName, nfpOptions, mapToRAM );
if isTableComplex

buildInterpLogic( isLinearInterp, dims, hN, hPrelookupOut, hInSignals, hImagOut, hT, table_data_imag, bp_data, spacing, compName, nfpOptions, mapToRAM );
pirelab.getRealImag2Complex( hN, [ hRealOut, hImagOut ], hOutSignals( 1 ) );
end 

earlyElabNIC = pirelab.instantiateNetwork( hNOrig, hN, hInSignalsOrig,  ...
hOutSignalsOrig, earlyElabNetworkName );
end 

function LinearInterpolationTopNetwork( hN,  ...
InterpolationInSigs, InterpolationOutSigs, dims, hT, table_data, bp_data, spacing, compName, nfpOptions, mapToRAM )

[ inportNames, inportTypes, inportRates ] = getPortData( InterpolationInSigs, 'interpolationS' );
[ outportNames, outportTypes, ~ ] = getPortData( InterpolationOutSigs, 'interp_fQ' );
slRate = InterpolationInSigs( dims + 1 ).SimulinkRate;
hLinearInterpN = pirelab.createNewNetwork(  ...
'Name', 'LinearInterpolationTopNetwork',  ...
'InportNames', inportNames,  ...
'InportTypes', inportTypes,  ...
'InportRates', inportRates,  ...
'OutportNames', outportNames,  ...
'OutportTypes', outportTypes );


for ii = 1:numel( hLinearInterpN.PirOutputSignals )
hLinearInterpN.PirOutputSignals( ii ).SimulinkRate = slRate;
end 

if strcmpi( nfpOptions.AreaOptimization, 'Serial' )
hLinearInterpN.setSharingFactor( 2 ^ dims );
end 

linearInterpNetworkInSigs = hLinearInterpN.PirInputSignals;
linearInterpNetworkOutSigs = hLinearInterpN.PirOutputSignals;

buildLinearInterpComp( hLinearInterpN, linearInterpNetworkInSigs( 1:dims ), linearInterpNetworkInSigs( dims + 1:end  ), linearInterpNetworkOutSigs( 1 ), hT, table_data, bp_data, spacing, compName, nfpOptions, mapToRAM, dims );

pirelab.instantiateNetwork( hN, hLinearInterpN, InterpolationInSigs, InterpolationOutSigs,  ...
[ hLinearInterpN.Name, '_inst' ] );
end 

function [ comp, hConvOut ] = buildFloatPrelookupLogic( hN, hInSignal, hPrelookupOut, bp_data, satLower, satUpper, fixType, compName, nfpOptions, typeStr, bpWordLength )



slSigRate = hInSignal.SimulinkRate;
hConvOut = hN.addSignal( fixType, 'convout' );
hConvOut.SimulinkRate = slSigRate;


float2fix( hN, hInSignal, hConvOut, compName, class( bp_data ), typeStr );

bpDataProcessed = convertBPToFix( bp_data, typeStr );
if satUpper == 0

pirelab.getConstComp( hN, hPrelookupOut, 0 );
hPrelookupOut = hN.addSignal( hPrelookupOut );
hPrelookupOut.Name = 'prelookup_wire';

end 
comp = floorBp( hN, hConvOut, hPrelookupOut, bpDataProcessed, compName, bpWordLength, satLower, satUpper, nfpOptions );
end 

function comp = float2fix( hN, hInSignal, hOutSignal, compName, floatType, intType )




slSigRate = hInSignal.SimulinkRate;

if strcmpi( intType, 'int16' )
numBits = 16;
elseif strcmpi( intType, 'int32' )
numBits = 32;
else 
numBits = 64;
end 

fixType = pirelab.convertSLType2PirType( intType );
ufixType = pirelab.convertSLType2PirType( [ 'u', intType ] );
ufixType1 = pir_boolean_t;
bitslicetype = pir_fixpt_t( 0, numBits - 1, 0 );
if hInSignal.Type.isArrayType(  )
dimLen = pirelab.getVectorTypeInfo( hInSignal );
fixType = pirelab.createPirArrayType( fixType, dimLen );
ufixType = pirelab.createPirArrayType( ufixType, dimLen );
ufixType1 = pirelab.createPirArrayType( ufixType1, dimLen );
bitslicetype = pirelab.createPirArrayType( bitslicetype, dimLen );
end 


hUFixSignal = hN.addSignal( ufixType, 'ufixout' );
pirelab.getNFPReinterpretCastComp( hN, hInSignal, hUFixSignal );

hFixSignal = hN.addSignal( fixType, 'fixout' );
pirelab.getDTCComp( hN, hUFixSignal, hFixSignal, 'Floor', 'Wrap', 'SI' );





hAndOut = hN.addSignal( fixType, 'masksignbitout' );
hAndOut.SimulinkRate = slSigRate;
hBitSliceSignal = hN.addSignal( bitslicetype, 'bitsliceout' );
hBitSliceSignal.SimulinkRate = slSigRate;

pirelab.getBitSliceComp( hN, hFixSignal, hBitSliceSignal, numBits - 2, 0, 'Bit Slice' );

pirelab.getDTCComp( hN, hBitSliceSignal, hAndOut, 'Floor', 'Wrap', 'SI' );

hUMinusOut = hN.addSignal( fixType, 'uminusout' );
hUMinusOut.SimulinkRate = slSigRate;
pirelab.getUnaryMinusComp( hN, hAndOut, hUMinusOut );



hCompareToNaN = hN.addSignal( ufixType1, 'isNaN' );
hCompareToNaN.SimulinkRate = slSigRate;
hNaNSwitch = hN.addSignal( fixType, 'nanSwitch' );
hNaNSwitch.SimulinkRate = slSigRate;

nanBitPattern = convertBPToFix( cast(  - NaN, floatType ), intType );
pirelab.getCompareToValueComp( hN, hAndOut, hCompareToNaN, '==', nanBitPattern, 'relop_nan', false );
pirelab.getSwitchComp( hN, [ hAndOut, hUMinusOut ], hNaNSwitch, hCompareToNaN,  ...
'uminusnan_switch', '~=' );



comp = pirelab.getSwitchComp( hN, [ hFixSignal, hNaNSwitch ], hOutSignal, hFixSignal,  ...
'signbit_switch', '>' );
end 

function comp = floorBp( hN, hDataSignal, hOutSignal, bpData, compName, bpWordLength, satLower, satUpper, nfpOptions )



slSigRate = hDataSignal.SimulinkRate;

ufixType1 = pir_boolean_t;
ufixType2 = pir_unsigned_t( bpWordLength );
if hDataSignal.Type.isArrayType(  )
dimLen = pirelab.getVectorTypeInfo( hDataSignal );
ufixType1 = pirelab.createPirArrayType( ufixType1, dimLen );
ufixType2 = pirelab.createPirArrayType( ufixType2, dimLen );
end 


for ii = numel( bpData ) - 1: - 1:1
sigName = strcat( 'relopout_', num2str( ii ) );
hRelOpOut = hN.addSignal( ufixType1, sigName );
hRelOpOut.SimulinkRate = slSigRate;

pirelab.getCompareToValueComp( hN, hDataSignal, hRelOpOut, '>=', bpData( ii + 1 ), sigName, false );

hRelOpOutVec( ii ) = hRelOpOut;
end 

if numel( hRelOpOutVec ) > 1
hMatSumOut = hN.addSignal( ufixType2, 'matsumout' );
hMatSumOut.SimulinkRate = slSigRate;


pirelab.getTreeArch( hN, hRelOpOutVec, hMatSumOut, 'sum', 'Floor', 'Wrap',  ...
[ compName, '_treesum' ], 'Zero', false, true, false, 'Value', 0, nfpOptions );
else 

hMatSumOut = hRelOpOutVec;
end 

if ( satLower == 0 && satUpper == numel( bpData ) - 1 ) || satUpper == 0


comp = pirelab.getWireComp( hN, hMatSumOut, hOutSignal );
else 


comp = pirelab.getSaturateComp( hN, hMatSumOut, hOutSignal, satLower, satUpper );
end 
end 

function buildInterpLogic( isLinearInterp, dims, hN, hPrelookupOut, hInSignals, hOutSignals, hT, table_data, bp_data, spacing, compName, nfpOptions, mapToRAM )
if ~isLinearInterp



getDirectLUT( hN, hPrelookupOut, hOutSignals, table_data, compName, '', mapToRAM );
elseif ~nfpOptions.PrecomputeCoefficients
LinearInterpolationTopNetwork( hN, [ hPrelookupOut( 1:end  ), hInSignals( 1:end  )' ], hOutSignals, dims, hT, table_data, bp_data, spacing, compName, nfpOptions, mapToRAM );
elseif dims == 1 && nfpOptions.PrecomputeCoefficients
buildLinearInterpPrecomputed1DComp( hN, hPrelookupOut, hInSignals, hOutSignals, hT, table_data, bp_data, compName, nfpOptions, mapToRAM );
elseif dims == 2 && nfpOptions.PrecomputeCoefficients
buildLinearInterpPrecomputed2DComp( hN, hPrelookupOut, hInSignals, hOutSignals, hT, table_data, bp_data, compName, nfpOptions, mapToRAM );
elseif dims == 3 && nfpOptions.PrecomputeCoefficients
buildLinearInterpPrecomputed3DComp( hN, hPrelookupOut, hInSignals, hOutSignals, hT, table_data, bp_data, compName, nfpOptions, mapToRAM );
end 
end 

function comp = buildLinearInterpPrecomputed1DComp( hN, hPrelookupOut, hInSignals, hOutSignals, hT, table_data, bp_data, compName, nfpOptions, mapToRAM )

[ slope_data, intercept_data ] = preProcess1D( table_data, bp_data );

slSigRate = hInSignals( 1 ).SimulinkRate;

hSlopeOut = hN.addSignal( hT, 'slopeout' );
hSlopeOut.SimulinkRate = slSigRate;
hInterceptOut = hN.addSignal( hT, 'interceptout' );
hInterceptOut.SimulinkRate = slSigRate;


getDirectLUT( hN, hPrelookupOut, hSlopeOut, slope_data, compName, 'internal_LUT_1', mapToRAM );

getDirectLUT( hN, hPrelookupOut, hInterceptOut, intercept_data, compName, 'internal_LUT_2', mapToRAM );


hMulOut = hN.addSignal( hT, 'mulout' );
hMulOut.SimulinkRate = slSigRate;
pirelab.getMulComp( hN, [ hSlopeOut, hInSignals( 1 ) ], hMulOut, 'Floor', 'Wrap', 'multiplier', '**',  ...
'',  - 1, int8( 0 ), nfpOptions );


comp = pirelab.getAddComp( hN, [ hMulOut, hInterceptOut ], hOutSignals, 'Floor', 'Wrap', 'adder',  ...
hT, '++', '',  - 1, nfpOptions );
end 

function comp = buildLinearInterpPrecomputed2DComp( hN, hPrelookup, hInSignals, hOutSignals, hT, table_data, bp_data, compName, nfpOptions, mapToRAM )

[ c1_data, c2_data, c3_data, c4_data ] = preProcess2D( table_data, bp_data );

slSigRate = hInSignals( 1 ).SimulinkRate;
hC1Out = hN.addSignal( hT, 'c1out' );
hC1Out.SimulinkRate = slSigRate;
hC2Out = hN.addSignal( hT, 'c2out' );
hC2Out.SimulinkRate = slSigRate;
hC3Out = hN.addSignal( hT, 'c3out' );
hC3Out.SimulinkRate = slSigRate;
hC4Out = hN.addSignal( hT, 'c4out' );
hC4Out.SimulinkRate = slSigRate;





getDirectLUT( hN, hPrelookup, hC1Out, c1_data, compName, 'internal_LUT_1', mapToRAM );

getDirectLUT( hN, hPrelookup, hC2Out, c2_data, compName, 'internal_LUT_2', mapToRAM );

getDirectLUT( hN, hPrelookup, hC3Out, c3_data, compName, 'internal_LUT_3', mapToRAM );

getDirectLUT( hN, hPrelookup, hC4Out, c4_data, compName, 'internal_LUT_4', mapToRAM );


hXYMulOut = hN.addSignal( hT, 'xyout' );
hXYMulOut.SimulinkRate = slSigRate;
hC1XYMulOut = hN.addSignal( hT, 'c1xyout' );
hC1XYMulOut.SimulinkRate = slSigRate;
hC2XMulOut = hN.addSignal( hT, 'c2xout' );
hC2XMulOut.SimulinkRate = slSigRate;
hC3YMulOut = hN.addSignal( hT, 'c3yout' );
hC3YMulOut.SimulinkRate = slSigRate;

pirelab.getMulComp( hN, [ hInSignals( 1 ), hInSignals( 2 ) ], hXYMulOut, 'Floor', 'Wrap', 'multiplier', '**',  ...
'',  - 1, int8( 0 ), nfpOptions );
pirelab.getMulComp( hN, [ hXYMulOut, hC1Out ], hC1XYMulOut, 'Floor', 'Wrap', 'multiplier', '**',  ...
'',  - 1, int8( 0 ), nfpOptions );
pirelab.getMulComp( hN, [ hInSignals( 2 ), hC2Out ], hC2XMulOut, 'Floor', 'Wrap', 'multiplier', '**',  ...
'',  - 1, int8( 0 ), nfpOptions );
pirelab.getMulComp( hN, [ hInSignals( 1 ), hC3Out ], hC3YMulOut, 'Floor', 'Wrap', 'multiplier', '**',  ...
'',  - 1, int8( 0 ), nfpOptions );


addVec = [ hC1XYMulOut, hC2XMulOut, hC3YMulOut, hC4Out ];
comp = pirelab.getAddComp( hN, addVec, hOutSignals, 'Floor',  ...
'Wrap', 'adder', hT, '++++', '',  - 1, nfpOptions );
end 

function comp = buildLinearInterpPrecomputed3DComp( hN, hPrelookup, hInSignals, hOutSignals, hT, table_data, bp_data, compName, nfpOptions, mapToRAM )

[ c1_data, c2_data, c3_data, c4_data, c5_data, c6_data, c7_data, c8_data ] = preProcess3D( table_data, bp_data );

slSigRate = hInSignals( 1 ).SimulinkRate;
hC1Out = hN.addSignal( hT, 'c1out' );
hC1Out.SimulinkRate = slSigRate;
hC2Out = hN.addSignal( hT, 'c2out' );
hC2Out.SimulinkRate = slSigRate;
hC3Out = hN.addSignal( hT, 'c3out' );
hC3Out.SimulinkRate = slSigRate;
hC4Out = hN.addSignal( hT, 'c4out' );
hC4Out.SimulinkRate = slSigRate;
hC5Out = hN.addSignal( hT, 'c5out' );
hC5Out.SimulinkRate = slSigRate;
hC6Out = hN.addSignal( hT, 'c6out' );
hC6Out.SimulinkRate = slSigRate;
hC7Out = hN.addSignal( hT, 'c7out' );
hC7Out.SimulinkRate = slSigRate;
hC8Out = hN.addSignal( hT, 'c8out' );
hC8Out.SimulinkRate = slSigRate;





getDirectLUT( hN, hPrelookup, hC1Out, c1_data, compName, 'internal_LUT_1', mapToRAM );

getDirectLUT( hN, hPrelookup, hC2Out, c2_data, compName, 'internal_LUT_2', mapToRAM );

getDirectLUT( hN, hPrelookup, hC3Out, c3_data, compName, 'internal_LUT_3', mapToRAM );

getDirectLUT( hN, hPrelookup, hC4Out, c4_data, compName, 'internal_LUT_4', mapToRAM );

getDirectLUT( hN, hPrelookup, hC5Out, c5_data, compName, 'internal_LUT_5', mapToRAM );

getDirectLUT( hN, hPrelookup, hC6Out, c6_data, compName, 'internal_LUT_6', mapToRAM );

getDirectLUT( hN, hPrelookup, hC7Out, c7_data, compName, 'internal_LUT_7', mapToRAM );

getDirectLUT( hN, hPrelookup, hC8Out, c8_data, compName, 'internal_LUT_8', mapToRAM );


hXYMulOut = hN.addSignal( hT, 'xyout' );
hXYMulOut.SimulinkRate = slSigRate;
hYZMulOut = hN.addSignal( hT, 'yzout' );
hYZMulOut.SimulinkRate = slSigRate;
hZXMulOut = hN.addSignal( hT, 'zxout' );
hZXMulOut.SimulinkRate = slSigRate;
hXYZMulOut = hN.addSignal( hT, 'xyzout' );
hXYZMulOut.SimulinkRate = slSigRate;
hC1XYZMulOut = hN.addSignal( hT, 'c1xyzout' );
hC1XYZMulOut.SimulinkRate = slSigRate;
hC2ZXMulOut = hN.addSignal( hT, 'c2zxout' );
hC2ZXMulOut.SimulinkRate = slSigRate;
hC3YZMulOut = hN.addSignal( hT, 'c3yzout' );
hC3YZMulOut.SimulinkRate = slSigRate;
hC4XYMulOut = hN.addSignal( hT, 'c4xyout' );
hC4XYMulOut.SimulinkRate = slSigRate;
hC5ZMulOut = hN.addSignal( hT, 'c5zout' );
hC5ZMulOut.SimulinkRate = slSigRate;
hC6YMulOut = hN.addSignal( hT, 'c6yout' );
hC6YMulOut.SimulinkRate = slSigRate;
hC7XMulOut = hN.addSignal( hT, 'c7xout' );
hC7XMulOut.SimulinkRate = slSigRate;


pirelab.getMulComp( hN, [ hInSignals( 1 ), hInSignals( 2 ) ], hXYMulOut, 'Floor', 'Wrap', 'multiplier', '**',  ...
'',  - 1, int8( 0 ), nfpOptions );
pirelab.getMulComp( hN, [ hInSignals( 3 ), hInSignals( 1 ) ], hYZMulOut, 'Floor', 'Wrap', 'multiplier', '**',  ...
'',  - 1, int8( 0 ), nfpOptions );
pirelab.getMulComp( hN, [ hInSignals( 2 ), hInSignals( 3 ) ], hZXMulOut, 'Floor', 'Wrap', 'multiplier', '**',  ...
'',  - 1, int8( 0 ), nfpOptions );
pirelab.getMulComp( hN, [ hYZMulOut, hInSignals( 2 ) ], hXYZMulOut, 'Floor', 'Wrap', 'multiplier', '**',  ...
'',  - 1, int8( 0 ), nfpOptions );
pirelab.getMulComp( hN, [ hC1Out, hXYZMulOut ], hC1XYZMulOut, 'Floor', 'Wrap', 'multiplier', '**',  ...
'',  - 1, int8( 0 ), nfpOptions );
pirelab.getMulComp( hN, [ hC2Out, hZXMulOut ], hC2ZXMulOut, 'Floor', 'Wrap', 'multiplier', '**',  ...
'',  - 1, int8( 0 ), nfpOptions );
pirelab.getMulComp( hN, [ hC3Out, hYZMulOut ], hC3YZMulOut, 'Floor', 'Wrap', 'multiplier', '**',  ...
'',  - 1, int8( 0 ), nfpOptions );
pirelab.getMulComp( hN, [ hC4Out, hXYMulOut ], hC4XYMulOut, 'Floor', 'Wrap', 'multiplier', '**',  ...
'',  - 1, int8( 0 ), nfpOptions );
pirelab.getMulComp( hN, [ hC5Out, hInSignals( 3 ) ], hC5ZMulOut, 'Floor', 'Wrap', 'multiplier', '**',  ...
'',  - 1, int8( 0 ), nfpOptions );
pirelab.getMulComp( hN, [ hC6Out, hInSignals( 1 ) ], hC6YMulOut, 'Floor', 'Wrap', 'multiplier', '**',  ...
'',  - 1, int8( 0 ), nfpOptions );
pirelab.getMulComp( hN, [ hC7Out, hInSignals( 2 ) ], hC7XMulOut, 'Floor', 'Wrap', 'multiplier', '**',  ...
'',  - 1, int8( 0 ), nfpOptions );

addVec = [ hC1XYZMulOut, hC2ZXMulOut, hC3YZMulOut, hC4XYMulOut, hC5ZMulOut, hC6YMulOut, hC7XMulOut, hC8Out ];
comp = pirelab.getAddComp( hN, addVec, hOutSignals, 'Floor',  ...
'Wrap', 'adder', hT, '++++++++', '',  - 1, nfpOptions );
end 

function comp = buildLinearInterpComp( hN, hPrelookup, hInSignals, hOutSignals, hT, table_data, bp_data, spacing, compName, nfpOptions, mapToRAM, dims )


Q1 = hdlhandles( 1, dims );
for i = 1:dims
Q1( i ) = hPrelookup( i );
end 
slSigRate = Q1( 1 ).SimulinkRate;

frac = hdlhandles( 1, dims );
Q2 = hdlhandles( 1, dims );

for i = 1:dims
[ frac( i ), Q2( i ) ] = buildFractionCalculation( hN, hT, Q1( i ), hInSignals( i ), bp_data{ i }, spacing( i ), num2str( i ), compName, nfpOptions, mapToRAM );
end 

interpSigs = hdlhandles( dims, 2 ^ dims );
for i = dims: - 1:1
for j = 1:( 2 ^ i )
interpSigs( i, j ) = hN.addSignal( hT, [ 'interp_', num2str( i ), num2str( j ) ] );
interpSigs( i, j ).SimulinkRate = slSigRate;
end 
end 


DirectLUTInSigs = [ Q1, Q2 ];
DirectLUTOutSigs = interpSigs( dims, 1:end  );

DirectLUTNetwork( hN, DirectLUTInSigs, DirectLUTOutSigs, slSigRate, table_data, mapToRAM, nfpOptions, dims );

l = 1;
for i = dims: - 1:2
k = 1;
for j = 1:2:( 2 ^ i )
buildLinearInterpLogic( hN, hT, interpSigs( i - 1, k ), interpSigs( i, j ), interpSigs( i, j + 1 ), frac( l ), nfpOptions );
k = k + 1;
end 
l = l + 1;
end 
comp = buildLinearInterpLogic( hN, hT, hOutSignals, interpSigs( 1, 1 ), interpSigs( 1, 2 ), frac( dims ), nfpOptions );
end 

function [ f, Q2 ] = buildFractionCalculation( hN, hT, Q1, x, bp_data, spacing, dimChar, compName, nfpOptions, mapToRAM )
ufixType1 = pir_unsigned_t( 1 );
if Q1.Type.isArrayType(  )
ufixType1 = pirelab.createPirArrayType( ufixType1, pirelab.getVectorTypeInfo( Q1 ) );
else 


hT = hT.BaseType;
end 

slSigRate = Q1.SimulinkRate;

bias = hN.addSignal( ufixType1, 'bias' );
bias.SimulinkRate = slSigRate;
Q2 = hN.addSignal( Q1.Type, [ 'Q', dimChar, '2' ] );
Q2.SimulinkRate = slSigRate;
pirelab.getConstComp( hN, bias, 1 );
pirelab.getAddComp( hN, [ Q1, bias ], Q2, 'Floor', 'Wrap' );

if spacing > 0


bp0 = bp_data( 1 );
inv_spacing = 1 / spacing;

bp0Sig = hN.addSignal( hT, [ 'bp0_', dimChar ] );
bp0Sig.SimulinkRate = slSigRate;
pirelab.getConstComp( hN, bp0Sig, bp0 );

idx2Float = hN.addSignal( hT, [ 'Q1_float_', dimChar ] );
idx2Float.SimulinkRate = slSigRate;
scaledIndex = hN.addSignal( hT, [ 'Q1_times_spacing_', dimChar ] );
scaledIndex.SimulinkRate = slSigRate;
plusOffset = hN.addSignal( hT, [ 'bpN_', dimChar ] );
plusOffset.SimulinkRate = slSigRate;
scaledFraction = hN.addSignal( hT, [ dimChar, '_minus_bpN' ] );
scaledFraction.SimulinkRate = slSigRate;
f = hN.addSignal( hT, 'fraction' );
f.SimulinkRate = slSigRate;

pirelab.getDTCComp( hN, Q1, idx2Float, 'Floor', 'Wrap', 'RWV', 'index_to_float', '',  - 1, nfpOptions );
pirelab.getGainComp( hN, idx2Float, scaledIndex, spacing, 1, 0, 'Floor', 'Wrap', 'scaled_index', 0, '', [  ], false, nfpOptions );
pirelab.getAddComp( hN, [ scaledIndex, bp0Sig ], plusOffset, 'Floor', 'Wrap', 'plus_bp0', hT, '++', '',  - 1, nfpOptions );
pirelab.getAddComp( hN, [ x, plusOffset ], scaledFraction, 'Floor', 'Wrap', [ dimChar, '_sub_bpN' ], hT, '+-', '',  - 1, nfpOptions );
pirelab.getGainComp( hN, scaledFraction, f, inv_spacing, 1, 0, 'Floor', 'Wrap', 'frac', 0, '', [  ], false, nfpOptions );
else 

x1 = hN.addSignal( hT, [ dimChar, '1' ] );
x1.SimulinkRate = slSigRate;
x2 = hN.addSignal( hT, [ dimChar, '2' ] );
x2.SimulinkRate = slSigRate;


getDirectLUT( hN, Q1, x1, bp_data, compName, [ dimChar, '1' ], mapToRAM );
getDirectLUT( hN, Q2, x2, bp_data, compName, [ dimChar, '2' ], mapToRAM );


x_x1 = hN.addSignal( hT, [ dimChar, '_minus_', dimChar, '1' ] );
x_x1.SimulinkRate = slSigRate;
x2_x1 = hN.addSignal( hT, [ dimChar, '2_minus_', dimChar, '1' ] );
x2_x1.SimulinkRate = slSigRate;
div_zp = hN.addSignal( hT, [ x2_x1.Name, '_zp' ] );
div_zp.SimulinkRate = slSigRate;
constOne = hN.addSignal( hT, [ dimChar, '_zp_val' ] );
constOne.SimulinkRate = slSigRate;
f = hN.addSignal( hT, 'fraction' );
f.SimulinkRate = slSigRate;
pirelab.getAddComp( hN, [ x, x1 ], x_x1, 'Floor', 'Wrap', [ dimChar, '_sub_', dimChar, '1' ], hT, '+-', '',  - 1, nfpOptions );
pirelab.getAddComp( hN, [ x2, x1 ], x2_x1, 'Floor', 'Wrap', [ 'sub_', dimChar ], hT, '+-', '',  - 1, nfpOptions );

pirelab.getConstComp( hN, constOne, 1 );
pirelab.getSwitchComp( hN, [ x2_x1, constOne ], div_zp, x2_x1, 'frac_zp_switch', '~=', 0 );

pirelab.getMulComp( hN, [ x_x1, div_zp ], f, 'Floor', 'Wrap', 'frac', '*/', '',  - 1, int8( 0 ), nfpOptions );
end 
end 

function comp = buildLinearInterpLogic( hN, hT, outSig, fQ1, fQ2, frac, nfpOptions )

slSigRate = fQ1.SimulinkRate;
interval = hN.addSignal( hT, 'interval' );
interval.SimulinkRate = slSigRate;
interp = hN.addSignal( hT, 'interp' );
interp.SimulinkRate = slSigRate;
pirelab.getAddComp( hN, [ fQ2, fQ1 ], interval, 'Floor', 'Wrap', 'fQ2_minus_fQ1', hT, '+-', '',  - 1, nfpOptions );
pirelab.getMulComp( hN, [ interval, frac ], interp, 'Floor', 'Wrap', 'interval_times_frac', '**', '',  - 1, int8( 0 ),  ...
nfpOptions );


comp = pirelab.getAddComp( hN, [ fQ1, interp ], outSig, 'Floor', 'Wrap', 'fQ1_plus_interp', hT,  ...
'++', '',  - 1, nfpOptions );
end 

function lut_comp = getDirectLUT( hN, inSigs, outSigs, tableData, compName, compInfo, mapToRAM )
numDims = sum( size( tableData ) > 1 );
if ~isempty( compInfo )
compName = [ compName, '_', compInfo ];
end 

if ~isscalar( tableData )
assert( numDims == numel( inSigs ), 'dimensions and number of input signals do not match' );

lut_comp = pirelab.getDirectLookupComp( hN, inSigs, outSigs, tableData, compName,  - 1, numDims, 'Element', 'Error', 'Inherit: Inherit from ''Table data''', mapToRAM );

lut_comp.setUseSLHandle( 0 );
else 



pirelab.getConstComp( hN, outSigs, tableData, compName );
end 
end 

function comp = buildClipExtrapSwitches( hN, hInSignal, float2FixSig, hControlSignal, hOutSignal, constLower, constUpper, thresh, hT, fixType, typeStr )



slSigRate = hInSignal.SimulinkRate;


fixConstLower = convertBPToFix( constLower, typeStr );
hConstLowerFixedSignal = hN.addSignal( fixType, 'const_0' );
hConstLowerFixedSignal.SimulinkRate = slSigRate;
pirelab.getConstComp( hN, hConstLowerFixedSignal, fixConstLower );
ufixType1 = pir_unsigned_t( 1 );
if hInSignal.Type.isArrayType(  )
ufixType1 = pirelab.createPirArrayType( ufixType1, pirelab.getVectorTypeInfo( hInSignal ) );
end 
hRelOpOut = hN.addSignal( ufixType1, 'relopout_0' );
hRelOpOut.SimulinkRate = slSigRate;
pirelab.getRelOpComp( hN, [ float2FixSig, hConstLowerFixedSignal ], hRelOpOut, '>=', false );

hConstLowerSignal = hN.addSignal( hT, 'const_lower' );
hConstLowerSignal.SimulinkRate = slSigRate;
pirelab.getConstComp( hN, hConstLowerSignal, constLower );

hConstUpperSignal = hN.addSignal( hT, 'const_upper' );
hConstUpperSignal.SimulinkRate = slSigRate;
pirelab.getConstComp( hN, hConstUpperSignal, constUpper );

hSwitch1Out = hN.addSignal( hT, 'switch_1' );
hSwitch1Out.SimulinkRate = slSigRate;

pirelab.getSwitchComp( hN, [ hInSignal, hConstLowerSignal ], hSwitch1Out, hRelOpOut,  ...
'clip_switch1', '~=', 0 );

comp = pirelab.getSwitchComp( hN, [ hConstUpperSignal, hSwitch1Out ], hOutSignal, hControlSignal,  ...
'clip_switch2', '>', thresh );
end 


function [ slope_data, intercept_data ] = preProcess1D( table_data, bp_data )



slope_data = zeros( 1, numel( table_data ) - 1, 'like', bp_data{ 1 } );
intercept_data = zeros( 1, numel( table_data ) - 1, 'like', bp_data{ 1 } );

for ii = 1:numel( table_data ) - 1
m = ( table_data( ii + 1 ) - table_data( ii ) ) / ( bp_data{ 1 }( ii + 1 ) - bp_data{ 1 }( ii ) );
b = table_data( ii ) - m * bp_data{ 1 }( ii );

slope_data( ii ) = m;
intercept_data( ii ) = b;

end 

end 
function [ c1_data, c2_data, c3_data, c4_data ] = preProcess2D( table_data, bp_data )



yDim = numel( bp_data{ 1 } );
xDim = numel( bp_data{ 2 } );

c1_data = zeros( yDim - 1, xDim - 1, 'like', bp_data{ 1 } );
c2_data = zeros( yDim - 1, xDim - 1, 'like', bp_data{ 1 } );
c3_data = zeros( yDim - 1, xDim - 1, 'like', bp_data{ 1 } );
c4_data = zeros( yDim - 1, xDim - 1, 'like', bp_data{ 1 } );

for ii = 1:yDim - 1
for jj = 1:xDim - 1
f11 = table_data( ii, jj );
f12 = table_data( ii + 1, jj );
f21 = table_data( ii, jj + 1 );
f22 = table_data( ii + 1, jj + 1 );

x1 = bp_data{ 2 }( jj );
x2 = bp_data{ 2 }( jj + 1 );

y1 = bp_data{ 1 }( ii );
y2 = bp_data{ 1 }( ii + 1 );


c1_data( ii, jj ) = ( f11 ) / ( ( x1 - x2 ) * ( y1 - y2 ) ) +  ...
( f12 ) / ( ( x1 - x2 ) * ( y2 - y1 ) ) +  ...
( f21 ) / ( ( x1 - x2 ) * ( y2 - y1 ) ) +  ...
( f22 ) / ( ( x1 - x2 ) * ( y1 - y2 ) );

c2_data( ii, jj ) = ( f11 * y2 ) / ( ( x1 - x2 ) * ( y2 - y1 ) ) +  ...
( f12 * y1 ) / ( ( x1 - x2 ) * ( y1 - y2 ) ) +  ...
( f21 * y2 ) / ( ( x1 - x2 ) * ( y1 - y2 ) ) +  ...
( f22 * y1 ) / ( ( x1 - x2 ) * ( y2 - y1 ) );

c3_data( ii, jj ) = ( f11 * x2 ) / ( ( x1 - x2 ) * ( y2 - y1 ) ) +  ...
( f12 * x2 ) / ( ( x1 - x2 ) * ( y1 - y2 ) ) +  ...
( f21 * x1 ) / ( ( x1 - x2 ) * ( y1 - y2 ) ) +  ...
( f22 * x1 ) / ( ( x1 - x2 ) * ( y2 - y1 ) );

c4_data( ii, jj ) = ( f11 * x2 * y2 ) / ( ( x1 - x2 ) * ( y1 - y2 ) ) +  ...
( f12 * x2 * y1 ) / ( ( x1 - x2 ) * ( y2 - y1 ) ) +  ...
( f21 * x1 * y2 ) / ( ( x1 - x2 ) * ( y2 - y1 ) ) +  ...
( f22 * x1 * y1 ) / ( ( x1 - x2 ) * ( y1 - y2 ) );

end 
end 

end 

function [ c1_data, c2_data, c3_data, c4_data, c5_data,  ...
c6_data, c7_data, c8_data ] = preProcess3D( table_data, bp_data )



yDim = numel( bp_data{ 1 } );
xDim = numel( bp_data{ 2 } );
zDim = numel( bp_data{ 3 } );

c1_data = zeros( yDim - 1, xDim - 1, zDim - 1, 'like', bp_data{ 1 } );
c2_data = zeros( yDim - 1, xDim - 1, zDim - 1, 'like', bp_data{ 1 } );
c3_data = zeros( yDim - 1, xDim - 1, zDim - 1, 'like', bp_data{ 1 } );
c4_data = zeros( yDim - 1, xDim - 1, zDim - 1, 'like', bp_data{ 1 } );
c5_data = zeros( yDim - 1, xDim - 1, zDim - 1, 'like', bp_data{ 1 } );
c6_data = zeros( yDim - 1, xDim - 1, zDim - 1, 'like', bp_data{ 1 } );
c7_data = zeros( yDim - 1, xDim - 1, zDim - 1, 'like', bp_data{ 1 } );
c8_data = zeros( yDim - 1, xDim - 1, zDim - 1, 'like', bp_data{ 1 } );


for ii = 1:yDim - 1
for jj = 1:xDim - 1
for kk = 1:zDim - 1

f111 = table_data( ii, jj, kk );
f121 = table_data( ii + 1, jj, kk );
f211 = table_data( ii, jj + 1, kk );
f112 = table_data( ii, jj, kk + 1 );
f212 = table_data( ii, jj + 1, kk + 1 );
f122 = table_data( ii + 1, jj, kk + 1 );
f221 = table_data( ii + 1, jj + 1, kk );
f222 = table_data( ii + 1, jj + 1, kk + 1 );

x1 = bp_data{ 2 }( jj );
x2 = bp_data{ 2 }( jj + 1 );

y1 = bp_data{ 1 }( ii );
y2 = bp_data{ 1 }( ii + 1 );

z1 = bp_data{ 3 }( kk );
z2 = bp_data{ 3 }( kk + 1 );


c1_data( ii, jj, kk ) = ( ( f222 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) -  ...
( f122 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) -  ...
( f212 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) +  ...
( f112 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) -  ...
( f221 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) +  ...
( f121 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) +  ...
( f211 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) -  ...
( f111 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) );


c2_data( ii, jj, kk ) = ( ( f212 * y2 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) -  ...
( f112 * y2 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) -  ...
( f222 * y1 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) +  ...
( f122 * y1 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) -  ...
( f211 * y2 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) +  ...
( f111 * y2 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) +  ...
( f221 * y1 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) -  ...
( f121 * y1 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) );



c3_data( ii, jj, kk ) = ( ( f122 * x2 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) -  ...
( f222 * x1 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) -  ...
( f112 * x2 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) +  ...
( f212 * x1 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) -  ...
( f121 * x2 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) +  ...
( f221 * x1 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) +  ...
( f111 * x2 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) -  ...
( f211 * x1 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) );


c4_data( ii, jj, kk ) = ( ( f221 * z2 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) -  ...
( f121 * z2 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) -  ...
( f211 * z2 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) +  ...
( f111 * z2 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) -  ...
( f222 * z1 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) +  ...
( f122 * z1 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) +  ...
( f212 * z1 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) -  ...
( f112 * z1 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) );

c5_data( ii, jj, kk ) = ( ( f112 * x2 * y2 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) -  ...
( f212 * x1 * y2 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) -  ...
( f122 * x2 * y1 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) +  ...
( f222 * x1 * y1 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) -  ...
( f111 * x2 * y2 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) +  ...
( f211 * x1 * y2 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) +  ...
( f121 * x2 * y1 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) -  ...
( f221 * x1 * y1 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) );



c6_data( ii, jj, kk ) = ( ( f121 * x2 * z2 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) -  ...
( f221 * x1 * z2 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) -  ...
( f111 * x2 * z2 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) +  ...
( f211 * x1 * z2 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) -  ...
( f122 * x2 * z1 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) +  ...
( f222 * x1 * z1 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) +  ...
( f112 * x2 * z1 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) -  ...
( f212 * x1 * z1 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) );


c7_data( ii, jj, kk ) = ( ( f211 * y2 * z2 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) -  ...
( f111 * y2 * z2 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) -  ...
( f221 * y1 * z2 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) +  ...
( f121 * y1 * z2 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) -  ...
( f212 * y2 * z1 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) +  ...
( f112 * y2 * z1 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) +  ...
( f222 * y1 * z1 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) -  ...
( f122 * y1 * z1 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) );


c8_data( ii, jj, kk ) = ( ( f111 * x2 * y2 * z2 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) -  ...
( f211 * x1 * y2 * z2 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) -  ...
( f121 * x2 * y1 * z2 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) +  ...
( f221 * x1 * y1 * z2 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) -  ...
( f112 * x2 * y2 * z1 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) +  ...
( f212 * x1 * y2 * z1 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) +  ...
( f122 * x2 * y1 * z1 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) -  ...
( f222 * x1 * y1 * z1 / ( ( x2 - x1 ) * ( y2 - y1 ) * ( z2 - z1 ) ) ) );
end 
end 
end 
end 

function DirectLUTNetwork( hN,  ...
DirectLUTInSigs, DirectLUTOutSigs, slRate, table_data, mapToRAM, nfpOptions, dims )

[ inportNames, inportTypes, inportRates ] = getPortData( DirectLUTInSigs, 'Q' );
[ outportNames, outportTypes, ~ ] = getPortData( DirectLUTOutSigs, 'fQ' );

hDirectLUTN = pirelab.createNewNetwork(  ...
'Name', 'DirectLUTNetwork',  ...
'InportNames', inportNames,  ...
'InportTypes', inportTypes,  ...
'InportRates', inportRates,  ...
'OutportNames', outportNames,  ...
'OutportTypes', outportTypes );
for ii = 1:numel( hDirectLUTN.PirOutputSignals )
hDirectLUTN.PirOutputSignals( ii ).SimulinkRate = slRate;
end 

if strcmpi( nfpOptions.AreaOptimization, 'Serial' )
hDirectLUTN.setSharingFactor( 2 ^ dims );
end 

directLUTNetworkInSigs = hDirectLUTN.PirInputSignals;
directLUTNetworkOutSigs = hDirectLUTN.PirOutputSignals;

DirectLUTSubNetwork( hDirectLUTN, directLUTNetworkInSigs,  ...
directLUTNetworkOutSigs, slRate, table_data, mapToRAM, dims );

pirelab.instantiateNetwork( hN, hDirectLUTN, DirectLUTInSigs, DirectLUTOutSigs,  ...
[ hDirectLUTN.Name, '_inst' ] );

end 

function DirectLUTSubNetwork( hN,  ...
DirectLUTAtomicInSigs, DirectLUTAtomicOutSigs, slRate, table_data, mapToRAM, dims )

[ inportNames, inportTypes, inportRates ] = getPortData( DirectLUTAtomicInSigs( 1:dims ), 'Q' );
[ outportNames, outportTypes, ~ ] = getPortData( DirectLUTAtomicOutSigs( 1 ), 'fQ' );

hDirectLUTSubN = pirelab.createNewNetwork(  ...
'Name', 'DirectLUTSubNetwork',  ...
'InportNames', inportNames,  ...
'InportTypes', inportTypes,  ...
'InportRates', inportRates,  ...
'OutportNames', outportNames,  ...
'OutportTypes', outportTypes );

for ii = 1:numel( hDirectLUTSubN.PirOutputSignals )
hDirectLUTSubN.PirOutputSignals( ii ).SimulinkRate = slRate;
end 



hDirectLUTSubN.setFlattenHierarchy( 'off' );

directLUTCompInSigs = hDirectLUTSubN.PirInputSignals;
directLUTCompOutSigs = hDirectLUTSubN.PirOutputSignals;

getDirectLUT( hDirectLUTSubN, directLUTCompInSigs,  ...
directLUTCompOutSigs, table_data, 'DirectLUT', 'fQ11111', mapToRAM );

index_1 = 1:dims;
index_2 = ( dims + 1 ):( dims * 2 );

for i = 1:( 2 ^ dims )
pirelab.instantiateNetwork( hN, hDirectLUTSubN, DirectLUTAtomicInSigs( index_1 ),  ...
DirectLUTAtomicOutSigs( i ), [ hDirectLUTSubN.Name, num2str( i ), '_inst' ] );
for j = 0:( dims - 1 )
if ( rem( i, ( 2 ^ j ) ) ) == 0
[ index_2( j + 1 ), index_1( j + 1 ) ] = deal( index_1( j + 1 ), index_2( j + 1 ) );
end 
end 
end 
end 

function data_fix = convertBPToFix( data, typeStr )



if isa( data( 1 ), 'half' )
data_fix = zeros( size( data ), typeStr );
for ii = 1:numel( data )



unsigned_data = data( ii ).storedInteger;
data_fix( ii ) = typecast( unsigned_data, typeStr );
end 
else 
data_fix = typecast( data, typeStr );
end 
data_fix( data_fix < 0 ) =  - bitand( data_fix( data_fix < 0 ), intmax( typeStr ) );
end 

function [ portnames, porttypes, portrates ] = getPortData( sigs, sigName )
numSigs = numel( sigs );
portnames = cell( numSigs, 1 );
porttypes = hdlhandles( 1, numSigs );
portrates = zeros( 1, numSigs );
for ii = 1:numSigs
portnames{ ii } = strcat( sigName, num2str( ii ) );
porttypes( ii ) = sigs( ii ).Type;
portrates( ii ) = sigs( ii ).SimulinkRate;
end 

end 





% Decoded using De-pcode utility v1.2 from file /tmp/tmp6MGyst.p.
% Please follow local copyright laws when handling this file.

