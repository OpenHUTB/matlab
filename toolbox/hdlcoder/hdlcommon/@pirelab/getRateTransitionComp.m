function rtComp = getRateTransitionComp( hN, hInSignals, hOutSignals, outputRate, initVal, compName, desc, slHandle, integrity, deterministic )

















if nargin < 10
integrity = true;
end 

if nargin < 9
deterministic = true;
end 

if nargin < 8
slHandle =  - 1;
end 

if nargin < 7
desc = '';
end 

if nargin < 6
compName = 'rt';
end 

if nargin < 5 || isempty( initVal )
initVal = pirelab.getTypeInfoAsFi( hInSignals.Type );
end 

inputRate = hInSignals.SimulinkRate;

if inputRate ~= outputRate
rtComp = pircore.getRateTransitionComp( hN, hInSignals, hOutSignals, outputRate, initVal, compName, desc, slHandle, integrity, deterministic );
else 



rtComp = pirelab.getWireComp( hN, hInSignals, hOutSignals, compName, desc, slHandle );
end 





% Decoded using De-pcode utility v1.2 from file /tmp/tmplvHkVd.p.
% Please follow local copyright laws when handling this file.

