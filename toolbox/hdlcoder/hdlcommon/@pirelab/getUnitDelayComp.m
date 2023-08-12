function delayComp = getUnitDelayComp( hN, hInSignals, hOutSignals, compName, initVal, resetnone, desc, slHandle )




if nargin < 8
slHandle =  - 1;
end 

if nargin < 7
desc = '';
end 

if nargin < 6
resetnone = false;
end 

if nargin < 5
initVal = 0;
end 

if nargin < 4
compName = 'reg';
end 


delayComp = pircore.getUnitDelayComp( hN, hInSignals, hOutSignals, compName,  ...
initVal, resetnone, desc, slHandle );

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp1TfhJD.p.
% Please follow local copyright laws when handling this file.

