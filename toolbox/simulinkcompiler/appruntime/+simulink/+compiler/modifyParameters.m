function modifyParameters( model, variables )

arguments
    model{ mustBeText }
    variables( 1, : )Simulink.Simulation.Variable{ mustBeNonempty }
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

isDeployed = Simulink.isRaccelDeployed;
isRapidAccelMode = strcmp( get_param( model, 'SimulationMode' ), 'rapid-accelerator' );

if ~( isDeployed || isRapidAccelMode )
    error( message( 'simulinkcompiler:runtime:UnsupportedSimulationModeForModifyParameter' ) );
end


if ~( simulink.compiler.getSimulationStatus( model ) == slsim.SimulationStatus.Running ||  ...
        simulink.compiler.getSimulationStatus( model ) == slsim.SimulationStatus.Paused )
    error( message( 'simulinkcompiler:runtime:WrongContextForModifyParameter' ) );
end

buildData = slsim.internal.getBuildData( model );
prmFile = [ buildData.buildDir, filesep, 'pr', buildData.tmpVarPrefix{ 1 }, '.mat' ];


rtp = load( prmFile );

for i = 1:length( variables )
    modelParameterIdentifier = variables( i ).Name;
    modelParameterValue = variables( i ).Value;

    rtp = sl(  ...
        'modifyRTP',  ...
        rtp,  ...
        modelParameterIdentifier,  ...
        modelParameterValue );
end

delete( prmFile );
modelChecksum = rtp.modelChecksum;
parameters = rtp.parameters;
globalParameterInfo = rtp.globalParameterInfo;
save( prmFile, '-v7', 'modelChecksum', 'parameters', 'globalParameterInfo' );


slsim.internal.modifyParameters( model, variables );

end

