function cloneDetectionData = getSavedResultsForVersion( versionId, modelName )

arguments
    versionId
    modelName = ''
end

cloneDetectionData = [  ];
resultsFolder = Simulink.CloneDetection.internal.util.getResultsFolderName( modelName );
if exist( resultsFolder, 'dir' )
    cloneResultsFile = dir( fullfile( resultsFolder, [ versionId, '.mat' ] ) );
    if ~isempty( cloneResultsFile )
        loadedObject = load( fullfile( resultsFolder, cloneResultsFile.name ) );
        cloneDetectionData = loadedObject.updatedObj;
    end
end
end

