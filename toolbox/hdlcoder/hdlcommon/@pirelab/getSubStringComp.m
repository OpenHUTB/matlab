function strinLenComp = getSubStringComp( hN, hInSignals, hOutSignals, compName )






outTpEx = pirelab.getTypeInfoAsFi( hOutSignals( 1 ).Type );

strinLenComp = pireml.getSubStringComp( hN, hInSignals, hOutSignals, compName, outTpEx );

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpavBly5.p.
% Please follow local copyright laws when handling this file.

