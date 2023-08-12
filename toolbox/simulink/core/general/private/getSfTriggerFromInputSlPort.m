function returnValue = getSfTriggerFromInputSlPort( chartBlockH, portNumber )


chartId = sfprivate( 'block2chart', chartBlockH );
chartH = sf( 'IdToHandle', chartId );
findResEvent = chartH.find( '-isa', 'Stateflow.Event', '-depth', 1, 'Port', portNumber, 'Scope', 'Input' );
findResTrigger = chartH.find( '-isa', 'Stateflow.Trigger', '-depth', 1, 'Port', portNumber, 'Scope', 'Input' );
if isa( findResEvent, 'Stateflow.Event' )
returnValue = findResEvent;
elseif isa( findResTrigger, 'Stateflow.Trigger' )
returnValue = findResTrigger;
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp1JlrzB.p.
% Please follow local copyright laws when handling this file.

