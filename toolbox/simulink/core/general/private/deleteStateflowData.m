function deleteStateflowData( blockHandle, isInputPort, portIndex )



chartId = sfprivate( 'block2chart', blockHandle );
chartH = sf( 'IdToHandle', chartId );
if isInputPort
dataH = chartH.find( '-isa', 'Stateflow.Data', '-depth', 1, 'Port', portIndex, 'Scope', 'Input' );
else 
dataH = chartH.find( '-isa', 'Stateflow.Data', '-depth', 1, 'Port', portIndex, 'Scope', 'Output' );
end 
delete( dataH );

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp_0A6a4.p.
% Please follow local copyright laws when handling this file.

