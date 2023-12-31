function varSelComp = getVariableSelectorComp( hN, hInputSignals, hOutputSignals,  ...
zerOneIdxMode, idxMode, elements,  ...
fillValues, rowsOrCols, numInputs,  ...
compName )

if nargin < 10
compName = 'VariableSelector';
end 

varSelComp = pircore.getVariableSelectorComp( hN, hInputSignals, hOutputSignals,  ...
zerOneIdxMode, idxMode, elements,  ...
fillValues, rowsOrCols, numInputs,  ...
compName );

% Decoded using De-pcode utility v1.2 from file /tmp/tmp4sV43V.p.
% Please follow local copyright laws when handling this file.

