function cgirComp = getSignToNumComp( hN, hInSignals, hOutSignals, compName, slbh, nfpOptions )




if ( nargin < 5 )
compName = 'signum';
end 

if ( nargin < 6 )
nfpOptions.Latency = int8( 0 );
nfpOptions.MantMul = int8( 0 );
nfpOptions.Denormals = int8( 0 );
end 


if getPirSignalBaseType( hInSignals.Type ).isComplexType

[ dimLen, baseTypeIn ] = pirelab.getVectorTypeInfo( hInSignals );
if hInSignals.Type.isArrayType
internalSigType = pirelab.createPirArrayType( baseTypeIn.BaseType, dimLen );

else 

internalSigType = hInSignals.Type.BaseType;
end 

realSig1 = hN.addSignal( internalSigType, [ compName, '_real_sig_before' ] );
imagSig1 = hN.addSignal( internalSigType, [ compName, '_imag_sig_before' ] );
absSig = hN.addSignal( internalSigType, [ compName, '_abs_sig' ] );
realSig2 = hN.addSignal( internalSigType, [ compName, '_real_sig_after' ] );
imagSig2 = hN.addSignal( internalSigType, [ compName, '_imag_sig_after' ] );



abscomp = pirelab.getAbsComp( hN, hInSignals, absSig, 'Nearest', 'Saturate', [ compName, '_abs' ], nfpOptions, true );
c2ricomp = pirelab.getComplex2RealImag( hN, hInSignals, [ realSig1;imagSig1 ] );

mulcomp1 = pirelab.getMulComp( hN, [ realSig1;absSig ], realSig2, 'Nearest', 'Saturate', [ compName, '_div_re' ], '*/', '',  - 1, int8( 0 ), nfpOptions );

mulcomp2 = pirelab.getMulComp( hN, [ imagSig1;absSig ], imagSig2, 'Nearest', 'Saturate', [ compName, '_div_im' ], '*/', '',  - 1, int8( 0 ), nfpOptions );
cgirComp = pirelab.getRealImag2Complex( hN, [ realSig2;imagSig2 ], hOutSignals );


else 
cgirComp = pircore.getSignToNumComp( hN, hInSignals, hOutSignals, compName );

end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpeVaOj6.p.
% Please follow local copyright laws when handling this file.

