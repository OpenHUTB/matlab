function cloneDetectionData = getSavedResultsForVersion( versionId, modelName )




R36
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


% Decoded using De-pcode utility v1.2 from file /tmp/tmpEZ63eg.p.
% Please follow local copyright laws when handling this file.

