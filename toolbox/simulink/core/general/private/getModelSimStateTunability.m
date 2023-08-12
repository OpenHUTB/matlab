function out = getModelSimStateTunability( mdl )







out = true;

simMode = get_param( mdl, 'SimulationMode' );
isExternOrAccel = ( strcmp( simMode, 'external' ) ||  ...
strcmp( simMode, 'accelerator' ) );
runStatus = ( strcmp( get_param( mdl, 'SimulationStatus' ), 'running' ) ...
 || strcmp( get_param( mdl, 'SimulationStatus' ), 'paused' ) ...
 || strcmp( get_param( mdl, 'SimulationStatus' ), 'initializing' ) ...
 || strcmp( get_param( mdl, 'SimulationStatus' ), 'external' ) );

inLineParamsOn = strcmp( get_param( mdl, 'InlineParams' ), 'on' );
if ( isExternOrAccel && runStatus && inLineParamsOn )
out = false;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpF8ZMiL.p.
% Please follow local copyright laws when handling this file.

