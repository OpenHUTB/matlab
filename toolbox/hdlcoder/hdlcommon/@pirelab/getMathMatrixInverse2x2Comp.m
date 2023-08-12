function hMatInvComp = getMathMatrixInverse2x2Comp( this, hN, hC, hInSignals, hOutSignals )




[ ~, ~, ~, ~, nfpOptions, ~ ] = this.getBlockInfo( hC );

slRate = hInSignals( 1 ).SimulinkRate;


if isDoubleType( hC.PirInputSignals( 1 ).Type.BaseType )
pirTyp1 = pir_double_t;
elseif isSingleType( hC.PirInputSignals( 1 ).Type.BaseType )
pirTyp1 = pir_single_t;
elseif isHalfType( hC.PirInputSignals( 1 ).Type.BaseType )
pirTyp1 = pir_half_t;
else 
end 


for ii = 1:numel( hN.PirOutputSignals )
hN.PirOutputSignals( ii ).SimulinkRate = slRate;
end 



hInSigs = hInSignals;


Xsplit = hInSigs.split;
Xsig1 = Xsplit.PirOutputSignals( 1 );
Xsig2 = Xsplit.PirOutputSignals( 2 );
s1 = Xsig1.split;
s2 = Xsig2.split;
aS = s1.PirOutputSignals( 1 );
bS = s1.PirOutputSignals( 2 );
cS = s2.PirOutputSignals( 1 );
dS = s2.PirOutputSignals( 2 );



minusbS = l_addSignal( hN, 'minusb', pirTyp1, slRate );
minuscS = l_addSignal( hN, 'minusc', pirTyp1, slRate );
product1S = l_addSignal( hN, 'product1', pirTyp1, slRate );
product2S = l_addSignal( hN, 'product2', pirTyp1, slRate );
sumS = l_addSignal( hN, 'ad-bc', pirTyp1, slRate );
recipDetS = l_addSignal( hN, 'recipDet', pirTyp1, slRate );
detProduct1S = l_addSignal( hN, 'product1', pirTyp1, slRate );
detProduct2S = l_addSignal( hN, 'product2', pirTyp1, slRate );
detProduct3S = l_addSignal( hN, 'product3', pirTyp1, slRate );
detProduct4S = l_addSignal( hN, 'product4', pirTyp1, slRate );



pirelab.getUnaryMinusComp( hN,  ...
bS,  ...
minusbS,  ...
'Wrap', '-b' );

pirelab.getUnaryMinusComp( hN,  ...
cS,  ...
minuscS,  ...
'Wrap', '-c' );

pirelab.getMulComp( hN,  ...
[ aS, dS ],  ...
product1S,  ...
'Floor', 'Wrap', 'a*d', '**', '',  - 1, 0, nfpOptions );

pirelab.getMulComp( hN,  ...
[ bS, cS ],  ...
product2S,  ...
'Floor', 'Wrap', 'b*c', '**', '',  - 1, 0, nfpOptions );

pirelab.getAddComp( hN,  ...
[ product1S, product2S ],  ...
sumS,  ...
'Floor', 'Wrap', 'ad-bc', pirTyp1, '+-',  ...
'',  - 1, nfpOptions );

pirelab.getMathComp( hN,  ...
sumS,  ...
recipDetS,  ...
'recipDet',  ...
 - 1,  ...
'reciprocal', nfpOptions );

pirelab.getMulComp( hN,  ...
[ aS, recipDetS ],  ...
detProduct1S,  ...
'Floor', 'Wrap', 'a*det', '**', '',  - 1, 0, nfpOptions );

pirelab.getMulComp( hN,  ...
[ minusbS, recipDetS ],  ...
detProduct2S,  ...
'Floor', 'Wrap', '-b*det', '**', '',  - 1, 0, nfpOptions );

pirelab.getMulComp( hN,  ...
[ minuscS, recipDetS ],  ...
detProduct3S,  ...
'Floor', 'Wrap', '-c*det', '**', '',  - 1, 0, nfpOptions );

pirelab.getMulComp( hN,  ...
[ dS, recipDetS ],  ...
detProduct4S,  ...
'Floor', 'Wrap', 'd*det', '**', '',  - 1, 0, nfpOptions );

hMatInvComp = pirelab.getConcatenateComp( hN,  ...
[ detProduct4S, detProduct2S, detProduct3S, detProduct1S ],  ...
hOutSignals,  ...
'Multidimensional array', '2' );

end 

function hS = l_addSignal( hN, sigName, pirTyp, simulinkRate )
hS = hN.addSignal;
hS.Name = sigName;
hS.Type = pirTyp;
hS.SimulinkHandle =  - 1;
hS.SimulinkRate = simulinkRate;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpO930bc.p.
% Please follow local copyright laws when handling this file.

