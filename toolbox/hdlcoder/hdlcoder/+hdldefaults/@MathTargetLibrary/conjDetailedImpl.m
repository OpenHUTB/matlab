function hNewC = conjDetailedImpl( ~, hN, blockComp, hInSignals, hOutSignals, outSigType )










[ dimLen, baseTypeIn ] = pirelab.getVectorTypeInfo( hInSignals );




complexCheckFlag = baseTypeIn.isComplexType;


if complexCheckFlag

if hInSignals.Type.isArrayType



internalSigType = pirelab.createPirArrayType( baseTypeIn.BaseType, dimLen );
else 
internalSigType = hInSignals.Type.BaseType;
end 


realSig = hN.addSignal( internalSigType, [ blockComp.Name, '_real_sig' ] );
imagSig1 = hN.addSignal( internalSigType, [ blockComp.Name, '_imag_sig_before' ] );
imagSig2 = hN.addSignal( internalSigType, [ blockComp.Name, '_imag_sig_after' ] );

hNewC = pirelab.getComplex2RealImag( hN, hInSignals, [ realSig;imagSig1 ] );
hNewC = pirelab.getUnaryMinusComp( hN, imagSig1, imagSig2 );
hNewC = pirelab.getRealImag2Complex( hN, [ realSig;imagSig2 ], hOutSignals );
else 




if ( strcmp( outSigType, 'auto' ) || strcmp( outSigType, 'real' ) )
hNewC = pirelab.getWireComp( hN, hInSignals, hOutSignals );


else 
hNewC = pirelab.getRealImag2Complex( hN, hInSignals, hOutSignals, 'real' );
end 
end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpMJBxc2.p.
% Please follow local copyright laws when handling this file.

