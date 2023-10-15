function resumeSimulation( model )

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

    slsim.internal.resumeSimulation( model );
else

    error( [ 'simulink.compiler.resumeSimulation is not supported in ',  ...
        get_param( model, 'SimulationMode' ), ' mode simulation' ] );
end

