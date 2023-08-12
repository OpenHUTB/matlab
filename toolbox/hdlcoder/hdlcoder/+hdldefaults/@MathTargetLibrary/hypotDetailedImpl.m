function hNewC = hypotDetailedImpl( ~, hN, blockComp, hInSignals, hOutSignals, nfpOptions, outSigType )










if ( ( targetcodegen.targetCodeGenerationUtils.isNFPMode(  ) ) &&  ...
targetmapping.isValidDataType( hInSignals( 1 ).Type.getLeafType(  ) ) && targetmapping.isValidDataType( hInSignals( 2 ).Type.getLeafType(  ) ) )

hNewC = pirelab.getMathComp( hN, hInSignals, hOutSignals, blockComp.Name,  ...
blockComp.SimulinkHandle, 'hypot', nfpOptions );

else 

uSquareType = hInSignals( 1 ).Type;
vSquareType = hInSignals( 2 ).Type;



if hInSignals( 1 ).Type.isArrayType
addOutType = hInSignals( 1 ).Type;





else 
addOutType = hInSignals( 2 ).Type;
end 


uSquare = hN.addSignal( uSquareType, [ blockComp.Name, '_u_square' ] );
vSquare = hN.addSignal( vSquareType, [ blockComp.Name, '_v_square' ] );
addOut = hN.addSignal( addOutType, [ blockComp.Name, '_add_out' ] );

hNewC = pirelab.getMulComp( hN, [ hInSignals( 1 );hInSignals( 1 ) ], uSquare, 'Floor', 'Wrap', 'multiplier', '**', '',  - 1, int8( 0 ), nfpOptions );
hNewC = pirelab.getMulComp( hN, [ hInSignals( 2 );hInSignals( 2 ) ], vSquare, 'Floor', 'Wrap', 'multiplier', '**', '',  - 1, int8( 0 ), nfpOptions );

hNewC = pirelab.getAddComp( hN, [ uSquare;vSquare ], addOut, 'Floor', 'Wrap', 'adder', [  ], '++', '',  - 1, nfpOptions );


if ( strcmp( outSigType, 'auto' ) || strcmp( outSigType, 'real' ) )
hNewC = pirelab.getSqrtComp( hN, addOut, hOutSignals, [ blockComp.Name, ' Sqrt' ], blockComp.SimulinkHandle, 'sqrt', nfpOptions );
else 

realSigOut = hN.addSignal( addOutType, [ blockComp.Name, '_real_out' ] );

hNewC = pirelab.getSqrtComp( hN, addOut, realSigOut, [ blockComp.Name, ' Sqrt' ], blockComp.SimulinkHandle, 'sqrt', nfpOptions );
hNewC = pirelab.getRealImag2Complex( hN, realSigOut, hOutSignals, 'real' );
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp7S17d7.p.
% Please follow local copyright laws when handling this file.

