function simTime = getSimulationTime( modelName )

arguments
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
    simTime = slsim.internal.getSimulationTime( modelName );
else

    simMode = get_param( modelName, 'SimulationMode' );
    isRaccel = strcmp( simMode, 'rapid-accelerator' );

    if isRaccel
        simTime = slsim.internal.getSimulationTime( modelName );
        return ;
    end

    simTime = get_param( modelName, 'SimulationTime' );
    simStatus = simulink.compiler.getSimulationStatus( modelName );
    if ( simStatus ~= slsim.SimulationStatus.Running &&  ...
            simStatus ~= slsim.SimulationStatus.Paused )
        simTime = nan;
    end
end

end
