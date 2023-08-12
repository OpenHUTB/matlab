function strinLenComp = getStringLengthComp( hN, hInSignals, hOutSignals, compName )


outTpEx = pirelab.getTypeInfoAsFi( hOutSignals( 1 ).Type );

strinLenComp = pireml.getStringLengthComp( hN, hInSignals, hOutSignals, compName, outTpEx );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpy69qNp.p.
% Please follow local copyright laws when handling this file.

