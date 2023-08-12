function lookundermask( aSysHandles )













warning( message( 'Simulink:Masking:LookUnderMaskObsolete' ) );


if ~iscell( aSysHandles )
if ischar( aSysHandles )
aSysHandles = { aSysHandles };
else 
aSysHandles = num2cell( aSysHandles );
end 
end 

for i = 1:length( aSysHandles )
aSysHandle = aSysHandles{ i };
if ~strcmp( get_param( aSysHandle, 'type' ), 'block_diagram' ), 
open_system( aSysHandle, 'force' );
else 
open_system( aSysHandle )
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpSWgUmo.p.
% Please follow local copyright laws when handling this file.

