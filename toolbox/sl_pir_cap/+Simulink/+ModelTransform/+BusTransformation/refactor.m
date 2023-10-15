function refactor( identificationResult )
arguments
    identificationResult
end

Simulink.ModelTransform.BusTransformation.internal.verifyCandidateResultsToRefactor( identificationResult );


modelName = identificationResult.TopModel;
isModelExplicitlyLoaded = false;
if ~bdIsLoaded( modelName )
    load_system( modelName );
    isModelExplicitlyLoaded = true;
end


slEnginePir.util.createBackupModel( modelName );


rawResults = identificationResult.getRawResults(  );
Simulink.ModelRefactor.BusPortsTransform.refactor( rawResults );

save_system( modelName, 'SaveDirtyReferencedModels', 'on' );

if ( isModelExplicitlyLoaded )
    close_system( modelName, 0 );
end
end
