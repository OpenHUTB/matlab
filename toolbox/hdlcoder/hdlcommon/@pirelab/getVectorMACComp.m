function macComp = getVectorMACComp( hN, hInSignals, hOutSignals, rndMode, ovMode, compName, desc, slbh, initialValue, elabMode )










if nargin < 10
elabMode = 'Auto';
end 

if nargin < 9
initialValue = 0;
end 

if nargin < 8
slbh =  - 1;
end 

if nargin < 7
desc = '';
end 

if nargin < 6
compName = 'multiply accumulate';
end 


inSigs = pirelab.convertRowVecsToUnorderedVecs( hN, hInSignals );
macComp = pircore.getVectorMACComp( hN, inSigs, hOutSignals,  ...
rndMode, ovMode,  ...
compName, desc, slbh, initialValue, elabMode );

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpUP5Xru.p.
% Please follow local copyright laws when handling this file.

