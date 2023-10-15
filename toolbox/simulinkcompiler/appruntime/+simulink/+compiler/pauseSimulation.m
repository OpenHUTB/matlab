function pauseSimulation( model )

arguments
    model( 1, : )char
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

if Simulink.isRaccelDeployed || strcmp( get_param( model, 'SimulationMode' ), 'rapid-accelerator' )

    slsim.internal.pauseSimulation( model );
else

    error( [ 'simulink.compiler.pauseSimulation is not supported in ',  ...
        get_param( model, 'SimulationMode' ), ' mode simulation' ] );
end

