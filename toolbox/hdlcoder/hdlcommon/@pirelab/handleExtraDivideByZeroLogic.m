function [ need_outsat, divbyzero_outsat ] = handleExtraDivideByZeroLogic(  ...
outSigned, outWordLen, outFracLen, resSigned, resWordLen, resFracLen,  ...
hOutType, rndMode, satMode, outtp_ex )








if outSigned
outIntLen = outWordLen - outFracLen - 1;
else 
outIntLen = outWordLen - outFracLen;
end 

if resSigned
resIntLen = resWordLen - resFracLen - 1;
else 
resIntLen = resWordLen - resFracLen;
end 



if outIntLen > resIntLen || outFracLen > resFracLen
need_outsat = true;
else 
need_outsat = false;
end 


divbyzero_outsat = pirelab.getTypeInfoAsFi( hOutType, rndMode, satMode, upperbound( outtp_ex ) );

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpG_8Hoj.p.
% Please follow local copyright laws when handling this file.

