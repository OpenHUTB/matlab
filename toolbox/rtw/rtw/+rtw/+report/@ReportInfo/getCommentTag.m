function out = getCommentTag( block, systemMap )




narginchk( 2, 2 );
if ~ischar( block ) || ~isempty( strfind( block, '/' ) )
block = Simulink.ID.getSID( block );
end 

[ model, ssid ] = strtok( block, ':' );
if strcmp( get_param( model, 'BlockCommentType' ), 'BlockSIDComment' )
[ h, ~, blockH, ~, ~ ] = Simulink.ID.getHandle( block );
if isa( h, 'Stateflow.Object' )
name = get_param( blockH, 'Name' );
else 
name = get_param( h, 'Name' );
end 
name = strrep( name, '/', '//' );
name = strrep( name, newline, ' ' );
out = [ name, ' (''', ssid, ''')' ];
return 
end 


if ~isempty( strfind( block, '-' ) )
h = Simulink.ID.getHandle( block );
block = Simulink.ID.getSID( h );
end 
[ p, h ] = Simulink.ID.getSimulinkParent( block );
if strcmp( p, strtok( block, ':' ) )
sys = '<Root>';
else 
idx = find( strcmp( systemMap, p ) );
if ~isempty( idx )
sys = sprintf( '<S%d>', idx );
end 
end 
if isa( h, 'Stateflow.Object' )
out = [ sys, block( length( p ) + 1:end  ) ];
else 
name = get_param( block, 'Name' );
name = strrep( name, '/', '//' );
name = strrep( name, sprintf( '\n' ), ' ' );
out = [ sys, '/', name ];
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpPQSdOA.p.
% Please follow local copyright laws when handling this file.

