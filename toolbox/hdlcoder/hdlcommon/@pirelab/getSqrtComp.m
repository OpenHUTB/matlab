function sqrtComp = getSqrtComp( hN, hInSignals, hOutSignals, compName, slbh, fname, nfpOptions )




if nargin < 7
nfpOptions.Latency = int8( 0 );
nfpOptions.MantMul = int8( 0 );
nfpOptions.Denormals = int8( 0 );
end 

if strcmp( fname, 'signedSqrt' )

hC = hN.findComponent( 'sl_handle', slbh );


outSig = hC.PirOutputSignals;
nextComp = outSig.getConcreteReceivingComps;
delayFlag = false;


if length( nextComp ) == 1
if nextComp.isDelay && nextComp.getInitialValue == 0
numDelays = nextComp.getNumDelays;
delayFlag = true;
end 
end 


if hInSignals( 1 ).Type.isMatrix && hOutSignals( 1 ).Type.isMatrix

insertReshapeBefore( hN, hC, prod( hC.PirInputSignals( 1 ).Type.Dimensions ) );

insertReshapeAfter( hN, hC, prod( hC.PirOutputSignals( 1 ).Type.Dimensions ) );

hInSignals = hC.PirInputSignals;
hOutSignals = hC.PirOutputSignals;
end 


[ dimLen, baseTypeIn ] = pirelab.getVectorTypeInfo( hInSignals );

if isHalfType( hInSignals.Type.BaseType )
wL = 16;
unSignedwL = 15;
elseif isSingleType( hInSignals.Type.BaseType )
wL = 32;
unSignedwL = 31;
else 
wL = 64;
unSignedwL = 63;
end 


if hInSignals.Type.isArrayType
internalSigType = pirelab.createPirArrayType( baseTypeIn.BaseType, dimLen );
unsignedSig = pirelab.createPirArrayType( hdlcoder.tp_unsigned( wL ), dimLen );
signBitSig = pirelab.createPirArrayType( hdlcoder.tp_unsigned( 1 ), dimLen );
slicedSig = pirelab.createPirArrayType( hdlcoder.tp_unsigned( unSignedwL ), dimLen );
if ( isDoubleType( hInSignals.Type.BaseType ) )
vectorParams1D = 'on';
MsbBitSig = pirelab.createPirArrayType( hdlcoder.tp_unsigned( 1 ), dimLen );
slicedInSig = pirelab.createPirArrayType( hdlcoder.tp_unsigned( unSignedwL ), dimLen );
end 
else 
internalSigType = hInSignals.Type.BaseType;
unsignedSig = hdlcoder.tp_unsigned( wL );
signBitSig = hdlcoder.tp_unsigned( 1 );
slicedSig = hdlcoder.tp_unsigned( unSignedwL );
if ( isDoubleType( hInSignals.Type.BaseType ) )
vectorParams1D = 'off';
MsbBitSig = hdlcoder.tp_unsigned( 1 );
slicedInSig = hdlcoder.tp_unsigned( unSignedwL );
end 
end 


origIntSig = hN.addSignal( unsignedSig, [ compName, '_orig_int_sig' ] );
signBit = hN.addSignal( signBitSig, [ compName, '_signBit' ] );
positiveSig = hN.addSignal( unsignedSig, [ compName, '_pos_sig' ] );
positiveSigSingle = hN.addSignal( internalSigType, [ compName, '_pos_single_sig' ] );
sqrtSig = hN.addSignal( internalSigType, [ compName, '_sqrt_sig' ] );
sqrtIntSig = hN.addSignal( unsignedSig, [ compName, '_sqrt_int_sig' ] );
IntermediateSig = hN.addSignal( slicedSig, [ compName, '_inter_sig' ] );
signSqrtIntSig = hN.addSignal( unsignedSig, [ compName, 'signsqrt_int_sig' ] );
if ( isDoubleType( hInSignals.Type.BaseType ) )
slRate = hInSignals( 1 ).SimulinkRate;
MsbBit = hN.addSignal( MsbBitSig, [ compName, '_resetMSBBit' ] );
MsbBit.SimulinkRate = slRate;
slicedInBits62_0 = hN.addSignal( slicedInSig, [ compName, '_islicedBits62_0' ] );
end 
[ rndMode, ovMode ] = getBlockModes( slbh );


nfpReinterpretComp = pirelab.getNFPReinterpretCastComp( hN, hInSignals, origIntSig );%#ok<*NASGU>

bitSliceComp = pirelab.getBitSliceComp( hN, origIntSig, signBit, unSignedwL, unSignedwL );


if ( ~isDoubleType( hInSignals.Type.BaseType ) )
bitSetComp = pirelab.getBitSetComp( hN, origIntSig, positiveSig, 0, wL );
else 
constantComp = pirelab.getConstComp( hN, MsbBit, 0, 'Constant1', vectorParams1D );
bitSliceComp2 = pirelab.getBitSliceComp( hN, origIntSig, slicedInBits62_0, unSignedwL - 1, 0 );
bitConcatInComp = pirelab.getBitConcatComp( hN, [ MsbBit, slicedInBits62_0 ], positiveSig );
end 
nfpReinterpretComp = pirelab.getNFPReinterpretCastComp( hN, positiveSig, positiveSigSingle );


sqrtComp = pirelab.getSqrtComp( hN, positiveSigSingle, sqrtSig, [ compName, '_sqrt' ],  ...
 - 1, 'sqrt', nfpOptions );

sqrtLatency = targetcodegen.targetCodeGenerationUtils.resolveLatencyForComp( sqrtComp );

if delayFlag && ( sqrtLatency > 0 )
if numDelays > sqrtLatency
excessDelay = numDelays - sqrtLatency;
nextComp.setNumDelays( excessDelay );

nextComp.setOutputDelay( excessDelay )
else 
hOutSignals = nextComp.PirOutputSignals;

hN.removeComponent( nextComp );
end 
end 

nfpReinterpretComp = pirelab.getNFPReinterpretCastComp( hN, sqrtSig, sqrtIntSig );

bitSliceComp = pirelab.getBitSliceComp( hN, sqrtIntSig, IntermediateSig, unSignedwL - 1, 0 );

bitConcatComp = pirelab.getBitConcatComp( hN, [ signBit, IntermediateSig ], signSqrtIntSig );

if ( hOutSignals.Type.isFloatType )
nfpReinterpretComp = pirelab.getNFPReinterpretCastComp( hN, signSqrtIntSig, hOutSignals );
else 
singleSig = hN.addSignal( internalSigType, [ compName, '_single_sig' ] );
nfpReinterpretComp = pirelab.getNFPReinterpretCastComp( hN, signSqrtIntSig, singleSig );
dtcComp = pirelab.getDTCComp( hN, singleSig, hOutSignals, rndMode, ovMode, 'RWV', [ compName, '_DTC' ], '',  - 1, nfpOptions );
end 
else 
sqrtComp = pircore.getSqrtComp( hN, hInSignals, hOutSignals, compName, slbh, fname, nfpOptions );
end 

end 


function [ rndMode, ovMode ] = getBlockModes( slbh )
rndMode = get_param( slbh, 'RndMeth' );

sat = get_param( slbh, 'DoSatur' );
if strcmp( sat, 'on' )
ovMode = 'Saturate';
else 
ovMode = 'Wrap';
end 

end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpNWJica.p.
% Please follow local copyright laws when handling this file.

