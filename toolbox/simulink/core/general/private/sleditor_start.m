function output = sleditor_start( mdlName )
output = false;
eval( mdlName );
set_param( mdlName, 'SimulationCommand', 'Start' );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpZKk8_S.p.
% Please follow local copyright laws when handling this file.

