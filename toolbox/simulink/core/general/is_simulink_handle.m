





function result = is_simulink_handle( handles )
result = false;
if isa( handles, 'double' ) && isvector( handles )
numHandles = length( handles );
result = false( size( handles ) );
for idx = 1:numHandles
h = handles( idx );
if ( ishandle( h ) )
try 
type = get( h, 'type' );
switch ( type )
case { 'block', 'block_diagram', 'line', 'annotation', 'port' }
result( idx ) = slInternal( 'isValidSimulinkHandleForCLAPI', h );
end 
catch 



end 
end 
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpdM65X_.p.
% Please follow local copyright laws when handling this file.

