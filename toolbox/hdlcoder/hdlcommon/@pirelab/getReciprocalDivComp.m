function recipComp = getReciprocalDivComp( hN, hInSignals, hOutSignals, rndMode, satMode, compName )




if ( nargin < 6 )
compName = 'recipdiv';
end 


if hInSignals.Type.isComplexType || hInSignals.Type.isArrayType
error( message( 'hdlcommon:hdlcommon:InputNeedRealScalar', compName ) );
end 


hInType = hInSignals.Type;
hOutType = hOutSignals.Type;

inSigned = hInType.Signed;
inWordLen = hInType.WordLength;
inFracLen =  - hInType.FractionLength;
outSigned = hOutType.Signed;
outWordLen = hOutType.WordLength;
outFracLen =  - hOutType.FractionLength;


ufix1_in = ~inSigned && ( inWordLen == 1 );
sfix2_in = inSigned && ( inWordLen == 2 );
ufix1_out = ~outSigned && ( outWordLen == 1 );
sfix2_out = outSigned && ( outWordLen == 2 );
if ( ufix1_in || sfix2_in || ufix1_out || sfix2_out )
recipComp = hdlarch.newton.handleReciprocalSpecialCase( hN,  ...
hInSignals, hOutSignals, rndMode, satMode, compName );
return ;
end 


oneSigned = inSigned;
oneFracLen = inFracLen + outFracLen;
if oneSigned
oneWordLen = max( oneFracLen + 2, 2 );
else 
oneWordLen = max( oneFracLen + 1, 1 );
end 
hOneType = pir_fixpt_t( oneSigned, oneWordLen,  - oneFracLen );


onetp_ex = pirelab.getTypeInfoAsFi( hOneType, rndMode, satMode );
outtp_ex = pirelab.getTypeInfoAsFi( hOutType, rndMode, satMode );


resSigned = inSigned;
resWordLen = oneWordLen;
resFracLen = outFracLen;




[ need_outsat, divbyzero_outsat ] = pirelab.handleExtraDivideByZeroLogic(  ...
outSigned, outWordLen, outFracLen, resSigned, resWordLen, resFracLen,  ...
hOutType, rndMode, satMode, outtp_ex );


recipComp = hN.addComponent2(  ...
'kind', 'cgireml',  ...
'Name', compName,  ...
'InputSignals', hInSignals,  ...
'OutputSignals', hOutSignals,  ...
'EMLFileName', 'hdleml_reciprocal',  ...
'EMLParams', { onetp_ex, outtp_ex, need_outsat, divbyzero_outsat },  ...
'EMLFlag_RunLoopUnrolling', false );
recipComp.runConcurrencyMaximizer( false );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpA0oH2e.p.
% Please follow local copyright laws when handling this file.

