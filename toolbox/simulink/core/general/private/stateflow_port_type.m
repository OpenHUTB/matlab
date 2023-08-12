function portType = stateflow_port_type( blockHandle, portName, searchOutput )









NONE_TYPE = 0;
DATA_TYPE = 1;
NON_FUNCTION_EVENT = 2;
FUNCTION_CALL_EVENT = 3;

chartID = sf( 'Private', 'block2chart', blockHandle );

r = sfroot;
chart = r.idToHandle( chartID );
if ( searchOutput )
dirString = 'Output';
else 
dirString = 'Input';
end 

if ( ~isempty( find( chart, '-isa', 'Stateflow.Data', 'Scope', dirString, 'Name', portName ) ) )
portType = DATA_TYPE;
return ;
end 




if strcmp( portName( end  - 1:end  ), '()' )
fcncall_portName = portName( 1:end  - 2 );
else 
fcncall_portName = portName;
end 

if ( ~isempty( find( chart, '-isa', 'Stateflow.Event', 'Scope', dirString,  ...
'Name', fcncall_portName, 'Trigger', 'Function call' ) ) )
portType = FUNCTION_CALL_EVENT;
return ;
end 


if ( ~isempty( find( chart, '-isa', 'Stateflow.Event', 'Scope', dirString, 'Name', portName ) ) )
portType = NON_FUNCTION_EVENT;
return ;
end 

portType = NONE_TYPE;
return ;
% Decoded using De-pcode utility v1.2 from file /tmp/tmp6syQc6.p.
% Please follow local copyright laws when handling this file.

