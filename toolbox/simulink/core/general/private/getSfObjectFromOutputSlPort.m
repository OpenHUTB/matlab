function returnValue = getSfObjectFromOutputSlPort( chartBlockH, portNumber )


chartId = sfprivate( 'block2chart', chartBlockH );
chartH = sf( 'IdToHandle', chartId );
findRes = chartH.find( '-isa', 'Stateflow.Object', '-depth', 1, 'Port', portNumber, 'Scope', 'Output' );
returnValue = findRes( 1 );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpA74qWB.p.
% Please follow local copyright laws when handling this file.

