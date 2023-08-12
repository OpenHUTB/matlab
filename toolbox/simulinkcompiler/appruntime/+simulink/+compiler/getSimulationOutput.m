function simOut = getSimulationOutput( model )




















R36
model{ mustBeText }
end 

simOut = [  ];
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
error( message( 'simulinkcompiler:runtime:UnsupportedSimulationModeForGetSimulationOutput',  ...
get_param( model, 'SimulationMode' ) ) );
end 


if ~( simulink.compiler.getSimulationStatus( model ) == slsim.SimulationStatus.Running ||  ...
simulink.compiler.getSimulationStatus( model ) == slsim.SimulationStatus.Paused ||  ...
simulink.compiler.getSimulationStatus( model ) == slsim.SimulationStatus.Stopped )
error( message( 'simulinkcompiler:runtime:WrongContextForGetSimulationOutput' ) );
return ;
end 

buildData = slsim.internal.getBuildData( model );
assert( ~isempty( buildData ), 'buildData cannot be empty' );

if isequal( lower( buildData.logging.SaveFormat ), 'array' )
warning( message( 'simulinkcompiler:runtime:UnsupportedFormatForGetSimulationOutput',  ...
buildData.logging.SaveFormat ) );
return ;
end 

templateDatasetFileName = fullfile( buildData.buildDir, 'template_dataset.mat' );
if isequal( lower( buildData.logging.SaveFormat ), 'dataset' ) &&  ...
~exist( templateDatasetFileName, 'file' )
warning( message( 'simulinkcompiler:runtime:RapidAccelNotBuildWithDatasetFormat' ) );
return ;
end 

if strcmpi( get_param( buildData.mdl, 'LoggingToFile' ), 'on' )
warning( message( 'simulinkcompiler:runtime:LoggingToFileNotSupportedForGetSimulationOutput' ) );
return ;
end 

if strcmpi( get_param( buildData.mdl, 'ReturnWorkspaceOutputs' ), 'off' )
warning( message( 'simulinkcompiler:runtime:ReturnWorkspaceOutputsOffNotSupportedForGetSimulationOutput' ) );
return ;
end 

partialOutFile = 'partialOut.mat';
cleanPartialOut = onCleanup( @(  )cleanPartialOutFile( partialOutFile ) );


sdiRunId = slsim.internal.getSimulationOutputSDIRunID( model, partialOutFile );
simOut = sl( 'rapid_accel_target_utils', 'getSimulationOutput', buildData, sdiRunId, partialOutFile );
end 

function cleanPartialOutFile( partialOutFile )
if exist( partialOutFile, 'file' )
delete( partialOutFile );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmppmdGEy.p.
% Please follow local copyright laws when handling this file.

