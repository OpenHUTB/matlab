function newComp = getMultiportSelectorComp( hN, hInSignals, hOutSignals,  ...
rowsOrCols, idxCellArray, idxErrMode, compName )


if nargin < 8
compName = 'MultiportSelector';
end 

newComp = pircore.getMultiportSelectorComp( hN, hInSignals, hOutSignals,  ...
rowsOrCols, idxCellArray, idxErrMode, compName );

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp8miMRW.p.
% Please follow local copyright laws when handling this file.

