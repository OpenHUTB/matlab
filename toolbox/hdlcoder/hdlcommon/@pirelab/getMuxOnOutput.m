function newComp = getMuxOnOutput( hN, hOutSignal )








outType = hOutSignal.Type;
if hOutSignal.Type.isArrayType
outLen = outType.getDimensions;
inType = outType.BaseType;
inSigs = hdlhandles( outLen, 1 );
for ii = 1:outLen
inName = sprintf( '%s_%d', hOutSignal.Name, ii - 1 );
inSigs( ii ) = hN.addSignal( inType, inName );
end 
newComp = pirelab.getMuxComp( hN, inSigs, hOutSignal );
else 
inSig = hN.addSignal( outType, hOutSignal.Name );
newComp = pirelab.getWireComp( hN, inSig, hOutSignal );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpPFNt33.p.
% Please follow local copyright laws when handling this file.

