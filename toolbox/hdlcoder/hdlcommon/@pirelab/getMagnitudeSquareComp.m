function hcComp = getMagnitudeSquareComp( hN, hInSignals, hOutSignals, satMode, rndMode, compName, outSigStrType )





if ( nargin < 6 )
compName = 'magnitude^2';
end 

if ( nargin < 7 )
outSigStrType = 'auto';
end 



[ dimLenIn, baseTypeIn ] = pirelab.getVectorTypeInfo( hInSignals, true );
[ dimLenOut, baseTypeOut ] = pirelab.getVectorTypeInfo( hOutSignals, true );
complexCheckFlag = baseTypeIn.isComplexType;


if ( complexCheckFlag && baseTypeIn.BaseType.isFloatType )


if hInSignals.Type.isArrayType
inSigType = pirelab.createPirArrayType( baseTypeIn.BaseType, dimLenIn );
temp_Type = inSigType;
else 
inSigType = baseTypeIn.BaseType;
temp_Type = inSigType;
end 
else 

temp_Type_base = pir_fixpt_t( baseTypeIn.BaseType.Signed, 2 * baseTypeIn.BaseType.WordLength, 2 * baseTypeIn.BaseType.FractionLength );
if hInSignals.Type.isArrayType
temp_Type = pirelab.createPirArrayType( temp_Type_base, dimLenIn );
inSigType = pirelab.createPirArrayType( baseTypeIn.BaseType, dimLenIn );
else 
temp_Type = temp_Type_base;
inSigType = baseTypeIn.BaseType;
end 
end 
if hInSignals.Type.isArrayType
outSigType = pirelab.createPirArrayType( baseTypeOut.BaseType, dimLenOut );
else 
outSigType = baseTypeOut.BaseType;
end 


if complexCheckFlag


realSigIn = hN.addSignal( inSigType, [ compName, '_real_in' ] );
imagSigIn = hN.addSignal( inSigType, [ compName, '_imag_in' ] );

imagSigSquare = hN.addSignal( temp_Type, [ compName, '_imag_square' ] );
realSigSquare = hN.addSignal( temp_Type, [ compName, '_real_square' ] );



pirelab.getComplex2RealImag( hN, hInSignals, [ realSigIn;imagSigIn ] );


pirelab.getMulComp( hN, [ realSigIn, realSigIn ], realSigSquare, rndMode, satMode );
pirelab.getMulComp( hN, [ imagSigIn, imagSigIn ], imagSigSquare, rndMode, satMode );


if ( strcmp( outSigStrType, 'auto' ) || strcmp( outSigStrType, 'real' ) )
hcComp = pirelab.getAddComp( hN, [ realSigSquare, imagSigSquare ], hOutSignals, rndMode, satMode );
else 

realSigOut = hN.addSignal( outSigType, [ compName, '_real_out' ] );
hcComp = pirelab.getAddComp( hN, [ realSigSquare, imagSigSquare ], realSigOut, rndMode, satMode );
hcComp = pirelab.getRealImag2Complex( hN, realSigOut, hOutSignals, 'real' );
end 
else 
if ( strcmp( outSigStrType, 'auto' ) || strcmp( outSigStrType, 'real' ) )
hcComp = pirelab.getMulComp( hN, [ hInSignals, hInSignals ], hOutSignals, rndMode, satMode );
else 

realSigOut = hN.addSignal( outSigType, [ compName, '_real_out' ] );
hcComp = pirelab.getMulComp( hN, [ hInSignals, hInSignals ], realSigOut, rndMode, satMode );
hcComp = pirelab.getRealImag2Complex( hN, realSigOut, hOutSignals, 'real' );
end 

end 





% Decoded using De-pcode utility v1.2 from file /tmp/tmpnlYD5S.p.
% Please follow local copyright laws when handling this file.

