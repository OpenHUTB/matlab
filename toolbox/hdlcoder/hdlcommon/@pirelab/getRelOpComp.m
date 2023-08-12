function relopComp = getRelOpComp( hN, hInSignals, hOutSignals, opName, sameDT, compName, desc, slHandle, nfpOptions )






if nargin < 9
nfpOptions.Latency = int8( 0 );
nfpOptions.MantMul = int8( 0 );
nfpOptions.Denormals = int8( 0 );
end 

if nargin < 8
slHandle =  - 1;
end 

if nargin < 7
desc = '';
end 

if nargin < 6
compName = 'relop';
end 

if nargin < 5
sameDT = false;
end 

if ~any( strcmp( opName, { 'isInf', 'isNaN', 'isFinite' } ) )
opName = upper( opName );
relopComp = pircore.getRelOpComp( hN, hInSignals, hOutSignals, opName, sameDT, compName, desc, slHandle, nfpOptions );
else 
[ ~, ~, isSingleType, ~, isHalfType ] = targetmapping.isValidDataType( hInSignals( 1 ).Type );








if isHalfType
ExpSize = 5;
ManSize = 10;
WordLength = 16;
ExpSaturate = 31;
elseif isSingleType
ExpSize = 8;
ManSize = 23;
WordLength = 32;
ExpSaturate = 255;
else 
ExpSize = 11;
ManSize = 52;
WordLength = 64;
ExpSaturate = 2047;
end 










[ dimLen, baseTypeIn ] = pirelab.getVectorTypeInfo( hInSignals );




complexCheckFlag = baseTypeIn.isComplexType;

if strcmp( opName, 'isNaN' ) || strcmp( opName, 'isInf' )



if strcmp( opName, 'isNaN' )
manOp = '~=';
else 
manOp = '==';
end 


if complexCheckFlag

if hInSignals.Type.isArrayType



internalSigType1 = pirelab.createPirArrayType( baseTypeIn.BaseType, dimLen );
internalSigTypeExp = pirelab.createPirArrayType( pir_unsigned_t( ExpSize ), dimLen );
internalSigTypeMan = pirelab.createPirArrayType( pir_ufixpt_t( ManSize, 0 ), dimLen );
internalSigUintWord = pirelab.createPirArrayType( pir_ufixpt_t( WordLength, 0 ), dimLen );
internalSigTypeBoolean = pirelab.createPirArrayType( pir_boolean_t, dimLen );
else 
internalSigType1 = hInSignals.Type.BaseType;
internalSigTypeExp = pir_unsigned_t( ExpSize );
internalSigTypeMan = pir_ufixpt_t( ManSize, 0 );
internalSigUintWord = pir_ufixpt_t( WordLength, 0 );
internalSigTypeBoolean = pir_boolean_t;
end 


realSig = hN.addSignal( internalSigType1, [ compName, '_real_sig' ] );
imagSig = hN.addSignal( internalSigType1, [ compName, '_imag_sig' ] );

realExp = hN.addSignal( internalSigTypeExp, [ compName, '_real_exp' ] );
realMan = hN.addSignal( internalSigTypeMan, [ compName, '_real_man' ] );
realUintWordSignal = hN.addSignal( internalSigUintWord, [ compName, '_real_uintWord' ] );

realExpBool = hN.addSignal( internalSigTypeBoolean, [ compName, '_real_exp_bool' ] );
realManBool = hN.addSignal( internalSigTypeBoolean, [ compName, '_real_man_bool' ] );
realBool = hN.addSignal( internalSigTypeBoolean, [ compName, '_real_bool' ] );

imagExp = hN.addSignal( internalSigTypeExp, [ compName, '_imag_exp' ] );
imagMan = hN.addSignal( internalSigTypeMan, [ compName, '_imag_man' ] );
imagUintWordSignal = hN.addSignal( internalSigUintWord, [ compName, '_imag_uintWord' ] );

imagExpBool = hN.addSignal( internalSigTypeBoolean, [ compName, '_imag_exp_bool' ] );
imagManBool = hN.addSignal( internalSigTypeBoolean, [ compName, '_imag_man_bool' ] );
imagBool = hN.addSignal( internalSigTypeBoolean, [ compName, '_imag_bool' ] );











constValExp = pirelab.getTypeInfoAsFi( internalSigTypeExp, 'Nearest', 'Saturate', ExpSaturate );

pirelab.getComplex2RealImag( hN, hInSignals, [ realSig;imagSig ] );



pirelab.getNFPReinterpretCastComp( hN, realSig, realUintWordSignal, [ compName, '_real_splitter' ] );
pirelab.getBitSliceComp( hN, realUintWordSignal, realExp, ( WordLength - 2 ), ManSize, [ compName, '_real_getExp' ] );
pirelab.getBitSliceComp( hN, realUintWordSignal, realMan, ( ManSize - 1 ), 0, [ compName, '_real_getMant' ] );

pirelab.getCompareToValueComp( hN, realExp, realExpBool, '==', constValExp, [ compName, '_real_exp_check' ], false, nfpOptions );
pirelab.getCompareToValueComp( hN, realMan, realManBool, manOp, 0, [ compName, '_real_man_check' ], true, nfpOptions );
pirelab.getLogicComp( hN, [ realExpBool;realManBool ], realBool, 'and', [ compName, '_real_check' ] );



pirelab.getNFPReinterpretCastComp( hN, imagSig, imagUintWordSignal, [ compName, '_imag_splitter' ] );
pirelab.getBitSliceComp( hN, imagUintWordSignal, imagExp, ( WordLength - 2 ), ManSize, [ compName, '_imag_getExp' ] );
pirelab.getBitSliceComp( hN, imagUintWordSignal, imagMan, ( ManSize - 1 ), 0, [ compName, '_imag_getMant' ] );

pirelab.getCompareToValueComp( hN, imagExp, imagExpBool, '==', constValExp, [ compName, '_imag_exp_check' ], false, nfpOptions );
pirelab.getCompareToValueComp( hN, imagMan, imagManBool, manOp, 0, [ compName, '_imag_man_check' ], true, nfpOptions );
pirelab.getLogicComp( hN, [ imagExpBool;imagManBool ], imagBool, 'and', [ compName, '_imag_check' ] );


relopComp = pirelab.getLogicComp( hN, [ realBool;imagBool ], hOutSignals, 'or', [ compName, '_final_check' ] );
else 


if hInSignals.Type.isArrayType



internalSigTypeExp = pirelab.createPirArrayType( pir_unsigned_t( ExpSize ), dimLen );
internalSigTypeMan = pirelab.createPirArrayType( pir_ufixpt_t( ManSize, 0 ), dimLen );
internalSigUintWord = pirelab.createPirArrayType( pir_ufixpt_t( WordLength, 0 ), dimLen );
internalSigTypeBoolean = pirelab.createPirArrayType( pir_boolean_t, dimLen );
else 
internalSigTypeExp = pir_unsigned_t( ExpSize );
internalSigTypeMan = pir_ufixpt_t( ManSize, 0 );
internalSigUintWord = pir_ufixpt_t( WordLength, 0 );
internalSigTypeBoolean = pir_boolean_t;
end 


expSignal = hN.addSignal( internalSigTypeExp, [ compName, '_exp' ] );
manSignal = hN.addSignal( internalSigTypeMan, [ compName, '_man' ] );
uintWordSignal = hN.addSignal( internalSigUintWord, [ compName, '_uintWord' ] );

expBool = hN.addSignal( internalSigTypeBoolean, [ compName, '_exp_bool' ] );
manBool = hN.addSignal( internalSigTypeBoolean, [ compName, '_man_bool' ] );


constValExp = pirelab.getTypeInfoAsFi( internalSigTypeExp, 'Nearest', 'Saturate', ExpSaturate );


pirelab.getNFPReinterpretCastComp( hN, hInSignals, uintWordSignal, [ compName, '_splitter' ] );
pirelab.getBitSliceComp( hN, uintWordSignal, expSignal, ( WordLength - 2 ), ManSize, [ compName, '_getExp' ] );
pirelab.getBitSliceComp( hN, uintWordSignal, manSignal, ( ManSize - 1 ), 0, [ compName, '_getMant' ] );



pirelab.getCompareToValueComp( hN, expSignal, expBool, '==', constValExp, [ compName, '_exp_check' ], false, nfpOptions );
pirelab.getCompareToValueComp( hN, manSignal, manBool, manOp, 0, [ compName, '_man_check' ], true, nfpOptions );
relopComp = pirelab.getLogicComp( hN, [ expBool;manBool ], hOutSignals, 'and', [ compName, '_final_check' ] );

end 

elseif strcmp( opName, 'isFinite' )

if complexCheckFlag

if hInSignals.Type.isArrayType



internalSigType1 = pirelab.createPirArrayType( baseTypeIn.BaseType, dimLen );
internalSigTypeExp = pirelab.createPirArrayType( pir_unsigned_t( ExpSize ), dimLen );
internalSigUintWord = pirelab.createPirArrayType( pir_ufixpt_t( WordLength, 0 ), dimLen );
internalSigTypeBoolean = pirelab.createPirArrayType( pir_boolean_t, dimLen );
else 
internalSigType1 = hInSignals.Type.BaseType;
internalSigTypeExp = pir_unsigned_t( ExpSize );
internalSigUintWord = pir_ufixpt_t( WordLength, 0 );
internalSigTypeBoolean = pir_boolean_t;
end 


realSig = hN.addSignal( internalSigType1, [ compName, '_real_sig' ] );
imagSig = hN.addSignal( internalSigType1, [ compName, '_imag_sig' ] );

realExp = hN.addSignal( internalSigTypeExp, [ compName, '_real_exp' ] );
realUintWordSignal = hN.addSignal( internalSigUintWord, [ compName, '_real_uintWord' ] );

realExpBool = hN.addSignal( internalSigTypeBoolean, [ compName, '_real_exp_bool' ] );

imagExp = hN.addSignal( internalSigTypeExp, [ compName, '_imag_exp' ] );
imagUintWordSignal = hN.addSignal( internalSigUintWord, [ compName, '_imag_uintWord' ] );

imagExpBool = hN.addSignal( internalSigTypeBoolean, [ compName, '_imag_exp_bool' ] );








constValExp = pirelab.getTypeInfoAsFi( internalSigTypeExp, 'Nearest', 'Saturate', ExpSaturate );

pirelab.getComplex2RealImag( hN, hInSignals, [ realSig;imagSig ] );



pirelab.getNFPReinterpretCastComp( hN, realSig, realUintWordSignal, [ compName, '_real_splitter' ] );
pirelab.getBitSliceComp( hN, realUintWordSignal, realExp, ( WordLength - 2 ), ManSize, [ compName, '_real_getExp' ] );

pirelab.getCompareToValueComp( hN, realExp, realExpBool, '~=', constValExp, [ compName, '_real_exp_check' ], false, nfpOptions );



pirelab.getNFPReinterpretCastComp( hN, imagSig, imagUintWordSignal, [ compName, '_imag_splitter' ] );
pirelab.getBitSliceComp( hN, imagUintWordSignal, imagExp, ( WordLength - 2 ), ManSize, [ compName, '_imag_getExp' ] );

pirelab.getCompareToValueComp( hN, imagExp, imagExpBool, '~=', constValExp, [ compName, '_imag_exp_check' ], false, nfpOptions );


relopComp = pirelab.getLogicComp( hN, [ realExpBool;imagExpBool ], hOutSignals, 'and', [ compName, '_finite_check' ] );
else 


if hInSignals.Type.isArrayType



internalSigTypeExp = pirelab.createPirArrayType( pir_unsigned_t( ExpSize ), dimLen );
internalSigUintWord = pirelab.createPirArrayType( pir_ufixpt_t( WordLength, 0 ), dimLen );
else 
internalSigTypeExp = pir_unsigned_t( ExpSize );
internalSigUintWord = pir_ufixpt_t( WordLength, 0 );
end 


expSignal = hN.addSignal( internalSigTypeExp, [ compName, '_exp' ] );
uintWordSignal = hN.addSignal( internalSigUintWord, [ compName, '_uintWord' ] );



constValExp = pirelab.getTypeInfoAsFi( internalSigTypeExp, 'Nearest', 'Saturate', ExpSaturate );


pirelab.getNFPReinterpretCastComp( hN, hInSignals, uintWordSignal, [ compName, '_splitter' ] );
pirelab.getBitSliceComp( hN, uintWordSignal, expSignal, ( WordLength - 2 ), ManSize, [ compName, '_getExp' ] );


relopComp = pirelab.getCompareToValueComp( hN, expSignal, hOutSignals, '~=', constValExp, [ compName, '_finite_check' ], false, nfpOptions );

end 
end 
end 

if hOutSignals.Type.isFloatType



relopBaseType = pir_boolean_t;
if hOutSignals.Type.isArrayType
relopType = pirelab.createPirArrayType( relopBaseType, hOutSignals.Type.getDimensions );
else 
relopType = relopBaseType;
end 
relopOutSig = hN.addSignal( relopType, [ hOutSignals.Name, '_bool' ] );
relopOutSig.SimulinkRate = hOutSignals.SimulinkRate;
relopOutSig.acquireDrivers( hOutSignals );

relopComp = pirelab.getDTCComp( hN, relopOutSig, hOutSignals );
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpckivVN.p.
% Please follow local copyright laws when handling this file.

