function job = batchsim( simIns, varargin, config )




R36
simIns Simulink.SimulationInput{ mustBeNonempty }
end 

R36( Repeating )
varargin
end 

R36
config.PCTLicensedChecker( 1, 1 )function_handle = @matlab.internal.parallel.isPCTLicensed
config.PCTInstalledChecker( 1, 1 )function_handle = @matlab.internal.parallel.isPCTInstalled
config.BatchSimulator( 1, 1 )function_handle = @MultiSim.internal.BatchSimulator
end 

checkPCTIsLicensedAndInstalled( config );

bs = config.BatchSimulator( simIns );
job = bs.run( varargin{ : } );
end 

function checkPCTIsLicensedAndInstalled( config )
if ~config.PCTLicensedChecker(  )
error( message( 'Simulink:batchsim:PCTLicenseRequired' ) );
end 

if ~config.PCTInstalledChecker(  )
error( message( 'Simulink:batchsim:PCTInstallRequired' ) );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpqM3Yl1.p.
% Please follow local copyright laws when handling this file.

