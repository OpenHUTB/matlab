
function hNewC = transformComplexComp( hN, hC, targetCompMap, nfpComp, hInSignals,  ...
hOutSignals, idx, isSingleType, compositeNFPOptions )
isComplexType = 0;
hasImagPart = 1;

for ii = 1:length( hInSignals )
if ~isComplexType
isComplexType = hInSignals( ii ).Type.isComplexType;
end 
end 




if ~isComplexType

for ii = 1:length( hOutSignals )
if ~isComplexType
isComplexType = hOutSignals( ii ).Type.isComplexType;
end 
end 
end 

if ~isComplexType
hNewC = transformScalarComp( hN, hC, targetCompMap,  ...
nfpComp, hInSignals, hOutSignals, idx, true, isSingleType, compositeNFPOptions );
else 



for ii = 1:length( hInSignals )
inType = hInSignals( ii ).Type;
if inType.isComplexType
baseType = hInSignals( ii ).Type.getLeafType;
hNewIn_re( ii ) = hN.addSignal( baseType, sprintf( 'nfp_in_%d_re', ii ) );
hNewIn_re( ii ).SimulinkRate = hInSignals( ii ).SimulinkRate;
hNewIn_im( ii ) = hN.addSignal( baseType, sprintf( 'nfp_in_%d_im', ii ) );
hNewIn_im( ii ).SimulinkRate = hInSignals( ii ).SimulinkRate;
pirelab.getComplex2RealImag( hN, hInSignals( ii ),  ...
[ hNewIn_re( ii ), hNewIn_im( ii ) ], 'Real and Imag',  ...
[ hInSignals( ii ).Name, '_cmpl' ] );
else 
hNewIn_re( ii ) = hInSignals( ii );%#ok<*AGROW>
hNewIn_im( ii ) = hN.addSignal( inType,  ...
sprintf( '%s_zero_im', hInSignals( ii ).Name ) );
pirelab.getConstComp( hN, hNewIn_im( ii ), 0, 'zeroconst',  ...
'on', true );
end 
end 



if strcmp( nfpComp, 'nfp_relop_comp' )

baseType = hOutSignals.Type.getLeafType;
hNewOut_re = hN.addSignal( baseType, 'nfp_out_re' );
hNewOut_re.SimulinkRate = hOutSignals.SimulinkRate;
hNewOut_im = hN.addSignal( baseType, 'nfp_out_im' );
hNewOut_im.SimulinkRate = hOutSignals.SimulinkRate;
pirelab.getLogicComp( hN, [ hNewOut_re, hNewOut_im ], hOutSignals, 'and' );
else 



for ii = 1:length( hOutSignals )
if ~hOutSignals( ii ).Type.isComplexType
hNewOut_re( ii ) = hOutSignals( ii );

assert( ~hOutSignals( ii ).Type.isComplexType )

hasImagPart = 0;
else 
baseType = hOutSignals( ii ).Type.getLeafType;
hNewOut_re( ii ) = hN.addSignal( baseType, sprintf( 'nfp_out_%d_re', ii ) );
hNewOut_re( ii ).SimulinkRate = hOutSignals( ii ).SimulinkRate;
hNewOut_im( ii ) = hN.addSignal( baseType, sprintf( 'nfp_out_%d_im', ii ) );
hNewOut_im( ii ).SimulinkRate = hOutSignals( ii ).SimulinkRate;
pirelab.getRealImag2Complex( hN, [ hNewOut_re( ii ), hNewOut_im( ii ) ],  ...
hOutSignals( ii ) );
end 
end 
end 


newComps = hdlhandles( 2, 1 );


if strcmp( nfpComp, 'nfp_gain_pow2_comp' )
gainVal = hC.getGainValue;
if ( numel( gainVal ) > 1 )
gainVal = gainVal( idx );
end 
assert( hdlispowerof2( gainVal ) );


if imag( gainVal ) ~= 0 && real( gainVal ) == 0

hNewIn_re_tmp = hNewIn_re;
hNewIn_re = hNewIn_im;
hNewIn_im = hNewIn_re_tmp;
end 
end 

newComps( 1 ) = transformScalarComp( hN, hC, targetCompMap,  ...
nfpComp, hNewIn_re( : ), hNewOut_re( : ), idx, true, isSingleType, compositeNFPOptions );
if hasImagPart
newComps( 2 ) = transformScalarComp( hN, hC, targetCompMap,  ...
nfpComp, hNewIn_im( : ), hNewOut_im( : ), idx, false, isSingleType, compositeNFPOptions );
end 
hNewC = newComps( 1 );
end 
end 

function hNewC = transformScalarComp( hN, hC, targetCompMap, nfpComp, hInSignals,  ...
hOutSignals, idx, isRealFactor, isSingleType, compositeNFPOptions )
switch nfpComp
case 'nfp_conv_comp'
hNewC = transformnfp.instantiateDTC( hN, hC, targetCompMap, hInSignals,  ...
hOutSignals, isSingleType );
case 'nfp_cast_comp'

hNewC = transformnfp.instantiateWireComp( hN, hC, targetCompMap,  ...
hInSignals, hOutSignals, isSingleType );
case 'nfp_gain_pow2_comp'
hNewC = transformnfp.instantiateGainPow2Comp( hN, hC, targetCompMap,  ...
hInSignals, hOutSignals, idx, isRealFactor, isSingleType );
otherwise 
hNewC = transformnfp.instantiateNetwork( hN, hC, targetCompMap, nfpComp,  ...
hInSignals, hOutSignals, isSingleType, compositeNFPOptions );
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpG8GXHr.p.
% Please follow local copyright laws when handling this file.

