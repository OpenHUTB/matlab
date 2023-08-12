function hC = getShiftAddMulComp( hN, hInSignals, hOutSignals, blockInfo )





slRate = hInSignals( 1 ).SimulinkRate;
in1Type = hInSignals( 1 ).Type;
outType = hOutSignals( 1 ).Type;



if in1Type.isArrayType || in1Type.isMatrix
hTopN = pirelab.createNewNetwork(  ...
'Name', 'Multiply_Top',  ...
'InportNames', { 'mulIn1', 'mulIn2' },  ...
'InportTypes', [ hInSignals( 1 ).Type, hInSignals( 2 ).Type ],  ...
'InportRates', [ slRate, slRate ],  ...
'OutportNames', { 'mulOut' },  ...
'OutportTypes', hOutSignals( 1 ).Type );




for ii = 1:numel( hTopN.PirOutputSignals )
hTopN.PirOutputSignals( ii ).SimulinkRate = slRate;
end 
hC = pirelab.instantiateNetwork( hN, hTopN, hInSignals, hOutSignals,  ...
[ 'Multiply_ShiftAdd', '_inst' ] );
hTopInSigs = hTopN.PirInputSignals;
hTopOutSigs = hTopN.PirOutputSignals;
in1SigType = hTopInSigs( 1 ).Type;
in2SigType = hTopInSigs( 2 ).Type;
outBaseType = hTopOutSigs( 1 ).Type.BaseType;
dimLen = hTopInSigs( 1 ).Type.getDimensions;



if in1SigType.isMatrix && in2SigType.isMatrix
numDim = in1SigType.Dimensions;
in1BaseType = in1SigType.BaseType;
in2BaseType = in2SigType.BaseType;
splitSig1Type = pirelab.createPirArrayType( in1BaseType, [ prod( numDim ), 0 ] );
splitSig2Type = pirelab.createPirArrayType( in2BaseType, [ prod( numDim ), 0 ] );
splitSig1OutS = addSignal( hTopN, 'splitSig1OutS', splitSig1Type, slRate );
splitSig2OutS = addSignal( hTopN, 'splitSig2OutS', splitSig2Type, slRate );
pirelab.getReshapeComp( hTopN, hTopInSigs( 1 ), splitSig1OutS );
pirelab.getReshapeComp( hTopN, hTopInSigs( 2 ), splitSig2OutS );
hInSigs1SplitVector = splitSig1OutS.split;
hInSigs1Split = hInSigs1SplitVector.PirOutputSignals;
hInSigs2SplitVector = splitSig2OutS.split;
hInSigs2Split = hInSigs2SplitVector.PirOutputSignals;
scalarCompOutS = hdlhandles( prod( dimLen ), 1 );


elseif in1SigType.isArrayType && in2SigType.isArrayType
inSigs1Split = hTopInSigs( 1 ).split;
hInSigs1Split = inSigs1Split.PirOutputSignals;
inSigs2Split = hTopInSigs( 2 ).split;
hInSigs2Split = inSigs2Split.PirOutputSignals;
scalarCompOutS = hdlhandles( dimLen( 1 ), 1 );
else 
hInSigs1Split = hTopInSigs( 1 );
hInSigs2Split = hTopInSigs( 2 );
end 


for i = 1:numel( hInSigs1Split )
scalarCompOutS( i ) = addSignal( hTopN, 'scalarSigOutS', outBaseType, slRate );
end 

elaborate_scalar( hTopN, [ hInSigs1Split, hInSigs2Split ], scalarCompOutS, blockInfo );

if outType.isMatrix
muxOutputType = pirelab.createPirArrayType( outBaseType, [ outType.Dimensions( 1 ) * outType.Dimensions( 2 ), 0 ] );
muxOutputS = addSignal( hTopN, 'MuxOutput', muxOutputType, slRate );
pirelab.getMuxComp( hTopN, scalarCompOutS( 1:end  ), muxOutputS, 'MuxOutput' );
pirelab.getReshapeComp( hTopN, muxOutputS, hTopOutSigs( 1 ) );
else 
pirelab.getMuxComp( hTopN, scalarCompOutS( 1:end  ), hTopOutSigs( 1 ), 'MuxOutput' );
end 

else 
hC = elaborate_scalar( hN, hInSignals, hOutSignals, blockInfo );
end 
end 


function hC = elaborate_scalar( hN, hInSignals, hOutSignals, blockInfo )
slRate = hInSignals( 1 ).SimulinkRate;
in1Type = hInSignals( 1 ).Type;
in2Type = hInSignals( end  ).Type;

hTopN = pirelab.createNewNetwork(  ...
'Name', 'Multiply',  ...
'InportNames', { 'mulIn1', 'mulIn2' },  ...
'InportTypes', [ hInSignals( 1 ).Type, hInSignals( end  ).Type ],  ...
'InportRates', [ slRate, slRate ],  ...
'OutportNames', { 'mulOut' },  ...
'OutportTypes', hOutSignals( 1 ).Type );


for ii = 1:numel( hTopN.PirOutputSignals )
hTopN.PirOutputSignals( ii ).SimulinkRate = slRate;
end 

if in2Type.WordLength <= in1Type.WordLength
inSigs = hTopN.PirInputSignals;
else 
inSigs = [ hTopN.PirInputSignals( 2 ), hTopN.PirInputSignals( 1 ) ];
end 

outSigs = hTopN.PirOutputSignals;

in1Sign = inSigs( 1 ).Type.Signed;
in1WL = inSigs( 1 ).Type.WordLength;
in1FL = inSigs( 1 ).Type.FractionLength;
in2Sign = inSigs( 2 ).Type.Signed;
in2WL = inSigs( 2 ).Type.WordLength;
in2FL = inSigs( 2 ).Type.FractionLength;
outSign = outSigs( 1 ).Type.Signed;
outWL = outSigs( 1 ).Type.WordLength;
outFL = outSigs( 1 ).Type.FractionLength;


if numel( hInSignals ) == 2
hC = pirelab.instantiateNetwork( hN, hTopN, hInSignals, hOutSignals,  ...
[ 'Multiply_ShiftAdd', '_inst' ] );
else 
lenInpSig = ( numel( hInSignals ) ) / 2;
in1Signals = hInSignals( 1:lenInpSig );
in2Signals = hInSignals( lenInpSig + 1:end  );


for i = 1:numel( in1Signals )
pirelab.instantiateNetwork( hN, hTopN, [ in1Signals( i ), in2Signals( i ) ], hOutSignals( i ),  ...
[ 'Multiply_ShiftAdd', '_inst', '_', num2str( i ) ] );
end 
end 

latencystrategy = blockInfo.latencyStrategy;
if strcmpi( latencystrategy, 'MAX' )
latency = ceil( log2( in2WL ) );
elseif strcmpi( latencystrategy, 'ZERO' )
latency = 0;
elseif strcmpi( latencystrategy, 'CUSTOM' )
latency = blockInfo.customLatency;
end 





if in2WL <= 2
switch latency
case 0
pipestage = [ 0, 0, 0 ];
case 1
pipestage = [ 0, 0, 1 ];
otherwise 
assert( false, 'Illegal latency for the specified input word length' )
end 
elseif in2WL <= 4
switch latency
case 0
pipestage = [ 0, 0, 0, 0 ];
case 1
pipestage = [ 0, 0, 0, 1 ];
case 2
pipestage = [ 1, 0, 0, 1 ];
otherwise 
assert( false, 'Illegal latency for the specified input word length' )
end 
elseif in2WL <= 8
switch latency
case 0
pipestage = [ 0, 0, 0, 0, 0 ];
case 1
pipestage = [ 0, 1, 0, 0, 0 ];
case 2
pipestage = [ 1, 0, 0, 0, 1 ];
case 3
pipestage = [ 1, 1, 0, 0, 1 ];
otherwise 
assert( false, 'Illegal latency for the specified input word length' )
end 
elseif in2WL <= 16
switch latency
case 0
pipestage = [ 0, 0, 0, 0, 0, 0 ];
case 1
pipestage = [ 0, 0, 0, 1, 0, 0 ];
case 2
pipestage = [ 1, 0, 0, 0, 0, 1 ];
case 3
pipestage = [ 1, 0, 0, 1, 0, 1 ];
case 4
pipestage = [ 1, 1, 0, 1, 0, 1 ];
otherwise 
assert( false, 'Illegal latency for the specified input word length' )
end 
elseif in2WL <= 32
switch latency
case 0
pipestage = [ 0, 0, 0, 0, 0, 0, 0 ];
case 1
pipestage = [ 0, 0, 0, 1, 0, 0, 0 ];
case 2
pipestage = [ 1, 0, 0, 0, 0, 0, 1 ];
case 3
pipestage = [ 1, 0, 1, 0, 0, 0, 1 ];
case 4
pipestage = [ 1, 1, 0, 1, 0, 0, 1 ];
case 5
pipestage = [ 1, 1, 0, 1, 1, 0, 1 ];
otherwise 
assert( false, 'Illegal latency for the specified input word length' )
end 
elseif in2WL <= 64
switch latency
case 0
pipestage = [ 0, 0, 0, 0, 0, 0, 0, 0 ];
case 1
pipestage = [ 0, 0, 0, 0, 0, 0, 0, 1 ];
case 2
pipestage = [ 1, 0, 0, 0, 0, 0, 0, 1 ];
case 3
pipestage = [ 1, 0, 0, 1, 0, 0, 0, 1 ];
case 4
pipestage = [ 1, 1, 0, 0, 1, 0, 0, 1 ];
case 5
pipestage = [ 1, 1, 0, 1, 0, 1, 0, 1 ];
case 6
pipestage = [ 1, 1, 0, 1, 1, 1, 0, 1 ];
otherwise 
assert( false, 'Illegal latency for the specified input word length' )
end 
end 

pirTyp13 = pir_ufixpt_t( 1, 0 );
pirTyp9 = pir_ufixpt_t( in1WL + 1, 0 );
pirTyp1 = pir_fixpt_t( in1Sign, in1WL, in1FL );
pirTyp3 = pir_fixpt_t( in2Sign, in2WL, in2FL );
pirTyp15 = pir_fixpt_t( in1Sign, in1WL + 1, 0 );
pirTyp2 = pir_fixpt_t( outSign, outWL, outFL );

if in2WL == 1
Constant1_out1_s27 = addSignal( hTopN, 'Constant1_out1', pirTyp1, slRate );
Switch1_out1_s54 = addSignal( hTopN, 'Switch1_out1_s54', pirTyp1, slRate );

pirelab.getConstComp( hTopN,  ...
Constant1_out1_s27,  ...
0,  ...
'Constant1', 'on', 1, '', '', '' );

pirelab.getSwitchComp( hTopN,  ...
[ inSigs( 1 ), Constant1_out1_s27 ],  ...
Switch1_out1_s54,  ...
inSigs( 2 ), 'Switch1',  ...
'~=', 0, 'Floor', 'Wrap' );

pirelab.getDTCComp( hTopN,  ...
Switch1_out1_s54,  ...
outSigs( 1 ),  ...
blockInfo.rndMode, blockInfo.ovMode, 'RWV', 'Data Type Conversion1' );
else 

Delay7_out1_s50 = addSignal( hTopN, 'Delay7_out1', pirTyp1, slRate );
Delay8_out1_s51 = addSignal( hTopN, 'Delay8_out1', pirTyp3, slRate );
BitSlice10_out1_s19 = addSignal( hTopN, 'Bit Slice10_out1', pirTyp13, slRate );
BitConcat7_out1_s16 = addSignal( hTopN, 'Bit Concat7_out1', pirTyp9, slRate );
Constant4_out1_s31 = addSignal( hTopN, 'Constant4_out1', pirTyp13, slRate );
Constant1_out1_s27 = addSignal( hTopN, 'Constant1_out1', pirTyp15, slRate );
BitConcat_out1_s9 = addSignal( hTopN, 'Bit Concat_out1', pirTyp9, slRate );
DataTypeConversion_out1_s37 = addSignal( hTopN, 'Data Type Conversion_out1', pirTyp15, slRate );
DataTypeConversion2_out1_s39 = addSignal( hTopN, 'Data Type Conversion2_out1', pirTyp15, slRate );
Switch_out1_s53 = addSignal( hTopN, 'Switch_out1', pirTyp15, slRate );
Switch1_out1_s54 = addSignal( hTopN, 'Switch1_out1', pirTyp15, slRate );
BitSlice_out1_s17 = addSignal( hTopN, 'Bit Slice_out1', pirTyp13, slRate );
BitSlice1_out1_s18 = addSignal( hTopN, 'Bit Slice1_out1', pirTyp13, slRate );

pirelab.getIntDelayComp( hTopN,  ...
inSigs( 1 ),  ...
Delay7_out1_s50,  ...
pipestage( 1 ), 'Delay7',  ...
int8( 0 ),  ...
0, 0, [  ], 0, 0 );

pirelab.getIntDelayComp( hTopN,  ...
inSigs( 2 ),  ...
Delay8_out1_s51,  ...
pipestage( 1 ), 'Delay8',  ...
int8( 0 ),  ...
0, 0, [  ], 0, 0 );

pirelab.getBitSliceComp( hTopN,  ...
Delay8_out1_s51,  ...
BitSlice_out1_s17,  ...
0, 0, 'Bit Slice' );

pirelab.getBitSliceComp( hTopN,  ...
Delay8_out1_s51,  ...
BitSlice1_out1_s18,  ...
1, 1, 'Bit Slice1' );


pirelab.getBitSliceComp( hTopN,  ...
Delay7_out1_s50,  ...
BitSlice10_out1_s19,  ...
in1WL - 1, in1WL - 1, 'Bit Slice10' );

if in1Sign
pirelab.getBitConcatComp( hTopN,  ...
[ BitSlice10_out1_s19, Delay7_out1_s50 ],  ...
BitConcat7_out1_s16,  ...
'Bit Concat7' );
else 
pirelab.getBitConcatComp( hTopN,  ...
[ Constant4_out1_s31, Delay7_out1_s50 ],  ...
BitConcat7_out1_s16,  ...
'Bit Concat7' );
end 

pirelab.getConstComp( hTopN,  ...
Constant4_out1_s31,  ...
0,  ...
'Constant4', 'on', 1, '', '', '' );

pirelab.getConstComp( hTopN,  ...
Constant1_out1_s27,  ...
0,  ...
'Constant1', 'on', 1, '', '', '' );

pirelab.getBitConcatComp( hTopN,  ...
[ Delay7_out1_s50, Constant4_out1_s31 ],  ...
BitConcat_out1_s9,  ...
'Bit Concat' );

pirelab.getDTCComp( hTopN,  ...
BitConcat7_out1_s16,  ...
DataTypeConversion_out1_s37,  ...
'Floor', 'Wrap', 'RWV', 'Data Type Conversion' );

pirelab.getDTCComp( hTopN,  ...
BitConcat_out1_s9,  ...
DataTypeConversion2_out1_s39,  ...
'Floor', 'Wrap', 'RWV', 'Data Type Conversion2' );

pirelab.getSwitchComp( hTopN,  ...
[ DataTypeConversion_out1_s37, Constant1_out1_s27 ],  ...
Switch_out1_s53,  ...
BitSlice_out1_s17, 'Switch',  ...
'~=', 0, 'Floor', 'Wrap' );

pirelab.getSwitchComp( hTopN,  ...
[ DataTypeConversion2_out1_s39, Constant1_out1_s27 ],  ...
Switch1_out1_s54,  ...
BitSlice1_out1_s18, 'Switch1',  ...
'~=', 0, 'Floor', 'Wrap' );

Switch2OutArrayS = hdlhandles( in2WL - 2, 1 );



for i = 2:in2WL - 1
if rem( i, 2 ) == 0
addWL = in1WL + 1;
else 
addWL = in1WL;
end 
pirTyp18 = pir_ufixpt_t( i, 0 );
pirTyp17 = pir_fixpt_t( in1Sign, addWL + i, 0 );
pirTyp10 = pir_ufixpt_t( addWL + i, 0 );

BitSliceOutS = addSignal( hTopN, [ 'BitSliceOutS_', num2str( i ) ], pirTyp13, slRate );
Constant5OutS = addSignal( hTopN, 'Constant5OutS', pirTyp18, slRate );
Constant2OutS = addSignal( hTopN, 'Constant2_out1', pirTyp17, slRate );
DataTypeConversion3OutS = addSignal( hTopN, 'DataTypeConversion3OutS', pirTyp17, slRate );
BitConcat1OutS = addSignal( hTopN, 'Bit Concat1_out1', pirTyp10, slRate );
Switch2OutS = addSignal( hTopN, 'Switch2OutS', pirTyp17, slRate );

pirelab.getBitSliceComp( hTopN,  ...
Delay8_out1_s51,  ...
BitSliceOutS,  ...
i, i, 'Bit Slice' );

pirelab.getConstComp( hTopN,  ...
Constant5OutS,  ...
0,  ...
'Constant5', 'on', 1, '', '', '' );

pirelab.getConstComp( hTopN,  ...
Constant2OutS,  ...
0,  ...
'Constant2', 'on', 1, '', '', '' );

if rem( i, 2 ) == 0
pirelab.getBitConcatComp( hTopN,  ...
[ BitConcat7_out1_s16, Constant5OutS ],  ...
BitConcat1OutS,  ...
'Bit Concat1' );
else 
pirelab.getBitConcatComp( hTopN,  ...
[ Delay7_out1_s50, Constant5OutS ],  ...
BitConcat1OutS,  ...
'Bit Concat1' );
end 

pirelab.getDTCComp( hTopN,  ...
BitConcat1OutS,  ...
DataTypeConversion3OutS,  ...
'Floor', 'Wrap', 'RWV', 'Data Type Conversion3' );

pirelab.getSwitchComp( hTopN,  ...
[ DataTypeConversion3OutS, Constant2OutS ],  ...
Switch2OutS,  ...
BitSliceOutS, 'Switch2',  ...
'~=', 0, 'Floor', 'Wrap' );
Switch2OutArrayS( i - 1 ) = Switch2OutS;
end 


pipestage_internal = pipestage( 2:end  - 1 );
numStages = ceil( log2( in2WL ) );
numSwitchOutSigs = in2WL;

if ( bitand( numSwitchOutSigs, 1 ) == 1 )
endVal = numSwitchOutSigs - 2;
else 
endVal = numSwitchOutSigs - 1;
end 

SwitchOutArray = hdlhandles( in2WL, 1 );

SwitchOutArray( 1:end  ) = [ Switch_out1_s53, Switch1_out1_s54, Switch2OutArrayS( 1:end  )' ];

AddInArray = hdlhandles( numSwitchOutSigs, numStages );


AddInArray( :, 1 ) = SwitchOutArray;



prevLenAdd = numSwitchOutSigs;
prsntLenAdd = 0;

addCount = 0;
subtractDone = false;



for i = 1:numStages
for j = 1:2:endVal

prsntLenAdd = prsntLenAdd + 1;
suffix1 = [ '_', int2str( i ) ];
suffix2 = [ '_', int2str( prsntLenAdd ) ];

addCount = addCount + 1;
hAddOutT = pir_fixpt_t( AddInArray( j + 1, i ).Type.Signed, AddInArray( j + 1, i ).Type.WordLength + 1, 0 );
AddOutS = addSignal( hTopN, [ 'AddOut', suffix1, suffix2 ], hAddOutT, slRate );
DelayOutS = addSignal( hTopN, [ 'DelayOut', suffix1, suffix2 ], hAddOutT, slRate );

if ( j + 1 == prevLenAdd ) && in2Sign && ~subtractDone
subtractDone = true;
pirelab.getAddComp( hTopN,  ...
[ AddInArray( j, i ), AddInArray( j + 1, i ) ],  ...
AddOutS,  ...
'Floor', 'Wrap', [ 'Add', suffix1, suffix2 ], hAddOutT, '+-' );
else 
pirelab.getAddComp( hTopN,  ...
[ AddInArray( j, i ), AddInArray( j + 1, i ) ],  ...
AddOutS,  ...
'Floor', 'Wrap', [ 'Add', suffix1, suffix2 ], hAddOutT, '++' );
end 

pirelab.getIntDelayComp( hTopN,  ...
AddOutS,  ...
DelayOutS,  ...
pipestage_internal( i ), [ 'Delay', suffix1, suffix2 ],  ...
0,  ...
0, 0, [  ], 0, 0 );



if ( i + 1 <= numStages )
AddInArray( prsntLenAdd, i + 1 ) = DelayOutS;
end 



if ( i + 1 > numStages )
lastAddOutS = addSignal( hTopN, 'lastAddOutS', hAddOutT, slRate );
pirelab.getWireComp( hTopN,  ...
DelayOutS,  ...
lastAddOutS,  ...
'prodOutput' );
end 
end 



if ( bitand( prevLenAdd, 1 ) == 1 )
lastSigType = AddInArray( prevLenAdd, i ).Type;
hLastSigT = pir_fixpt_t( lastSigType.Signed, lastSigType.WordLength, 0 );
DelayLastS = addSignal( hTopN, [ 'DelayLast', suffix1, int2str( prsntLenAdd ) ], hLastSigT, slRate );
prsntLenAdd = prsntLenAdd + 1;

pirelab.getIntDelayComp( hTopN,  ...
AddInArray( prevLenAdd, i ),  ...
DelayLastS,  ...
pipestage_internal( i ), [ 'Delay', suffix1, int2str( prsntLenAdd ) ],  ...
0,  ...
0, 0, [  ], 0, 0 );

AddInArray( prsntLenAdd, i + 1 ) = DelayLastS;
end 


if ( bitand( prsntLenAdd, 1 ) == 1 )
endVal = prsntLenAdd - 2;
else 
endVal = prsntLenAdd - 1;
end 



prevLenAdd = prsntLenAdd;
prsntLenAdd = 0;

end 
outInternalType = pir_fixpt_t( outSign, outWL, outFL - ( in1FL + in2FL ) );

DataTypeConversion1_out1_s38 = addSignal( hTopN, 'Data Type Conversion1_out1', outInternalType, slRate );
DataTypeConversionOut1S = addSignal( hTopN, 'DataTypeConversionOut1S', pirTyp2, slRate );

if strcmpi( blockInfo.ovMode, 'Saturate' )
lastAddSigT = lastAddOutS.Type;
outFullPrecType = pir_fixpt_t( outSign, lastAddSigT.WordLength, lastAddSigT.FractionLength );
DataTypeConversionOutS = addSignal( hTopN, 'DataTypeConversionOutS', outFullPrecType, slRate );
pirelab.getDTCComp( hTopN,  ...
lastAddOutS,  ...
DataTypeConversionOutS,  ...
'Floor', 'Wrap', 'SI', 'Data Type Conversion1' );

pirelab.getDTCComp( hTopN,  ...
DataTypeConversionOutS,  ...
DataTypeConversion1_out1_s38,  ...
blockInfo.rndMode, blockInfo.ovMode, 'RWV', 'Data Type Conversion1' );
else 
pirelab.getDTCComp( hTopN,  ...
lastAddOutS,  ...
DataTypeConversion1_out1_s38,  ...
blockInfo.rndMode, blockInfo.ovMode, 'RWV', 'Data Type Conversion1' );
end 
pirelab.getDTCComp( hTopN,  ...
DataTypeConversion1_out1_s38,  ...
DataTypeConversionOut1S,  ...
'Floor', 'Wrap', 'SI', 'Data Type Conversion1' );

pirelab.getIntDelayComp( hTopN,  ...
DataTypeConversionOut1S,  ...
outSigs( 1 ),  ...
pipestage( end  ), 'Delay9',  ...
int16( 0 ),  ...
0, 0, [  ], 0, 0 );
end 

end 

function hS = addSignal( hN, sigName, pirTyp, simulinkRate )
hS = hN.addSignal;
hS.Name = sigName;
hS.Type = pirTyp;
hS.SimulinkHandle = 0;
hS.SimulinkRate = simulinkRate;
end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpVaI3zC.p.
% Please follow local copyright laws when handling this file.

