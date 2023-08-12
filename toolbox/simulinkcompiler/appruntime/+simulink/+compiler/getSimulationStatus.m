
function simStatus = getSimulationStatus( modelName )



R36
modelName( 1, 1 )string
end 

product = "Simulink_Compiler";
[ status, msg ] = builtin( 'license', 'checkout', product );
if ~status
product = extractBetween( msg, 'Cannot find a license for ', '.' );
if ~isempty( product )
error( message( 'simulinkcompiler:build:LicenseCheckoutError', product{ 1 } ) );
end 
error( msg );
end 

if ismcc || isdeployed
simStatus = slsim.internal.getSimulationStatus( modelName );
else 

try 
simMode = get_param( modelName, 'SimulationMode' );
catch 

simStatus = slsim.SimulationStatus.Inactive;
return ;
end 

isRaccel = strcmp( simMode, 'rapid-accelerator' );
if isRaccel
simStatus = slsim.internal.getSimulationStatus( modelName );
return ;
end 

oldSimStatus = get_param( modelName, 'SimulationStatus' );
switch ( oldSimStatus )
case 'stopped'
simStatus = slsim.SimulationStatus.Inactive;
case 'updating'
simStatus = slsim.SimulationStatus.Running;
case 'initializing'
simStatus = slsim.SimulationStatus.Initializing;
case 'running'
simStatus = slsim.SimulationStatus.Running;
case 'paused-in-debugger'
simStatus = slsim.SimulationStatus.Paused;
case 'paused'
simStatus = slsim.SimulationStatus.Paused;
case 'terminating'
simStatus = slsim.SimulationStatus.Terminating;
case 'complied'
simStatus = slsim.SimulationStatus.Initialized;
case 'external'
simStatus = slsim.SimulationStatus.Running;
otherwise 
simStatus = slsim.SimulationStatus.Inactive;
end 
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpYDfg4x.p.
% Please follow local copyright laws when handling this file.

