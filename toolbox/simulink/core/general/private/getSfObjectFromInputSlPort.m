function returnValue = getSfObjectFromInputSlPort( chartBlockH, portNumber )


returnValue = 0;
chartId = sfprivate( 'block2chart', chartBlockH );
chartH = sf( 'IdToHandle', chartId );
findResData = chartH.find( '-isa', 'Stateflow.Data', '-depth', 1, 'Port', portNumber, 'Scope', 'Input' );
findResMsg = chartH.find( '-isa', 'Stateflow.Message', '-depth', 1, 'Port', portNumber, 'Scope', 'Input' );
if isa( findResData, 'Stateflow.Data' )
returnValue = findResData;
elseif isa( findResMsg, 'Stateflow.Message' )
returnValue = findResMsg;
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpiyaQ33.p.
% Please follow local copyright laws when handling this file.

