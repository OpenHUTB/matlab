function hNewC = squareDetailedImpl( ~, hN, blockComp, hInSignals, hOutSignals, nfpOptions, outSigType )











[ dimLen, baseTypeIn ] = pirelab.getVectorTypeInfo( hInSignals );




complexCheckFlag = baseTypeIn.isComplexType;


if complexCheckFlag

hNewC = pirelab.getMulComp( hN, [ hInSignals;hInSignals ], hOutSignals, 'Floor', 'Wrap', 'multiplier', '**', '',  - 1, int8( 0 ), nfpOptions );


else 


if ( strcmp( outSigType, 'auto' ) || strcmp( outSigType, 'real' ) )
hNewC = pirelab.getMulComp( hN, [ hInSignals;hInSignals ], hOutSignals, 'Floor', 'Wrap', 'multiplier', '**', '',  - 1, int8( 0 ), nfpOptions );


else 


if hInSignals.Type.isArrayType



internalSigType = pirelab.createPirArrayType( baseTypeIn.BaseType, dimLen );
else 
internalSigType = hInSignals.Type.BaseType;
end 


realSig = hN.addSignal( internalSigType, [ blockComp.Name, '_real_sig' ] );

hNewC = pirelab.getMulComp( hN, [ hInSignals;hInSignals ], realSig, 'Floor', 'Wrap', 'multiplier', '**', '',  - 1, int8( 0 ), nfpOptions );
hNewC = pirelab.getRealImag2Complex( hN, realSig, hOutSignals, 'real' );
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpVl790M.p.
% Please follow local copyright laws when handling this file.

