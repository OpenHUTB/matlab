function viewer = createSimulationManagerFromSimInputOutputPair( simIn, simOut )

arguments
    simIn Simulink.SimulationInput{ mustBeNonempty }
    simOut Simulink.SimulationOutput{ mustHaveSameSize( simOut, simIn ) }
end

validateModelNamesMatch( simIn, simOut );

simMgr = Simulink.SimulationManager( simIn );
[ simData, simMetaData ] = simOut.getInternalSimulationDataAndMetadataStructs(  );
simMgr.setSimulationData( simData );
simMgr.setSimulationMetadata( simMetaData );

job = MultiSim.internal.MultiSimJob( simMgr, false );
jobData = MultiSim.internal.getJobDataFromSimulationOutput( simOut );
cleanupJobData = onCleanup( @(  )delete( jobData ) );
job.JobStatusDB.updateData( jobData, simMetaData )

viewer = MultiSim.internal.MultiSimJobViewer( job );
end

function mustHaveSameSize( simOut, simIn )
expectedSize = size( simIn );
validateattributes( simOut, { 'Simulink.SimulationOutput' }, { 'size', expectedSize } );
end

function validateModelNamesMatch( simIn, simOut )
modelNamesSimIn = arrayfun( @( x )string( x.ModelName ), simIn );
modelNamesSimOut = arrayfun( @( x )string( x.SimulationMetadata.ModelInfo.ModelName ), simOut );

if any( modelNamesSimIn ~= modelNamesSimOut )
    error( message( 'Simulink:MultiSim:ModelNameMismatch' ) );
end
end

