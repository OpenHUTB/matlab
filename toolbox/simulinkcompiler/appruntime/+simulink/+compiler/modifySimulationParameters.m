
function modifySimulationParameters( bdName, options )
R36
bdName
options.EnablePacing{ mustBeMember( options.EnablePacing, { 'on', 'off' } ) }
options.PacingRate{ mustBePositive }
options.PostStepFcnDecimation{ mustBePositive, mustBeInteger }
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


if ~Simulink.isRaccelDeployed && ~isequal( get_param( bdName, 'SimulationMode' ), 'rapid-accelerator' )
error( message( 'simulinkcompiler:runtime:UnsupportedSimulationModeForModifyPostStepFcn' ) );
end 


if simulink.compiler.getSimulationStatus( bdName ) == slsim.SimulationStatus.Inactive
error( message( 'simulinkcompiler:runtime:InvalidCallToModifySimulationParameters' ) );
end 

slsim.internal.modifySimulationParameters( bdName, options );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp3gOJJG.p.
% Please follow local copyright laws when handling this file.

