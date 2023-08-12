function recipComp = getReciprocalComp( hN, hInSignals, hOutSignals, newtonInfo, slbh, nfpOptions )



inputType = hInSignals.Type.BaseType;
if nargin < 6
nfpOptions.Latency = int8( 0 );
nfpOptions.MantMul = int8( 0 );
nfpOptions.Denormals = int8( 0 );
nfpOptions.Radix = int32( 2 );
else 
if ~isfield( nfpOptions, 'Radix' )
nfpOptions.Radix = int32( 2 );
end 
end 

if ~isFloatType( inputType )
inputWL = inputType.WordLength;
inputFL =  - inputType.FractionLength;

if inputFL > inputWL
if inputType.Signed
newInType = pir_sfixpt_t( inputWL,  - inputWL );
newOutType = pir_sfixpt_t( inputWL, 2 );
else 
newInType = pir_ufixpt_t( inputWL,  - inputWL );
newOutType = pir_ufixpt_t( inputWL, 1 );
end 
newInSignals = hN.addSignal( newInType, 'dtc_recip' );
newOutSignals = hN.addSignal( newOutType, 'dtc_recip' );
pirelab.getDTCComp( hN, hInSignals, newInSignals, 'Floor', 'Wrap', 'SI' );
pirelab.getDTCComp( hN, newOutSignals, hOutSignals, 'Floor', 'Wrap', 'SI' );
hInSignals = newInSignals;
hOutSignals = newOutSignals;
end 
end 

recipComp = pircore.getReciprocalComp( hN, hInSignals, hOutSignals, newtonInfo, slbh, nfpOptions );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp4Yty2u.p.
% Please follow local copyright laws when handling this file.

