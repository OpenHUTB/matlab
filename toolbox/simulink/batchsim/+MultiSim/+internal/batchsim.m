function job = batchsim( simIns, varargin, config )

arguments
    simIns Simulink.SimulationInput{ mustBeNonempty }
end

arguments( Repeating )
    varargin
end

arguments
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

