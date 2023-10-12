
function cloneReplacementResults = replaceClones( cloneResults,  ...
libraryNameToAddSubsystemsTo, ignoredClones )

R36
cloneResults
libraryNameToAddSubsystemsTo = 'newLibraryFile'
ignoredClones = {  }
end 

loadedModels = {  };
try 
Simulink.CloneDetection.internal.util.checkoutLicenseForCloneDetection(  );

cloneReplacementResults = [  ];
if ~isa( cloneResults, 'Simulink.CloneDetection.Results' ) || isempty( cloneResults ) ...
 || ~isprop( cloneResults, 'ClonesId' ) || isempty( cloneResults.ClonesId )
DAStudio.error( 'sl_pir_cpp:creator:InvalidCloneResultsObject' );
end 

if isempty( cloneResults.Clones )
DAStudio.error( 'sl_pir_cpp:creator:NoClonesToReplace' );
end 

if isa( libraryNameToAddSubsystemsTo, 'Simulink.CloneDetection.ReplacementConfig' )
cloneReplacementConfig = libraryNameToAddSubsystemsTo;
else 
cloneReplacementConfig = Simulink.CloneDetection.ReplacementConfig(  ...
libraryNameToAddSubsystemsTo, ignoredClones );
end 

clonesId = split( cloneResults.ClonesId, "," );





if ~( length( clonesId ) >= 3 )
DAStudio.error( 'sl_pir_cpp:creator:InvalidCloneResultsObject' );
end 

modelDirectory = clonesId{ 1 };
modelName = clonesId{ 2 };
clonesDataId = clonesId{ 3 };

if isempty( modelName )
DAStudio.error( 'sl_pir_cpp:creator:ReplaceClonesAcrossFoldersNotSupported' );
end 
if slEnginePir.util.loadBlockDiagramIfNotLoaded( fullfile( modelDirectory, modelName ) )
loadedModels = [ loadedModels;{ modelName } ];
end 

clonesRawData = Simulink.CloneDetection.internal.ClonesData(  );
clonesSavedData = Simulink.CloneDetection.internal.util.getSavedResultsForVersion(  ...
clonesDataId, modelName );
clonesRawData = Simulink.CloneDetection.internal.util.savedDataToClonesDataClassAdapter(  ...
clonesRawData, clonesSavedData );
clonesRawData.model = get_param( modelName, 'handle' );
set_param( modelName, 'CloneDetectionUIObj', clonesRawData );

clonesRawData = Simulink.CloneDetection.internal.util.updateReplaceClonesConfig(  ...
clonesRawData, cloneReplacementConfig );
cloneReplaceResults = clonesRawData.refactorCallBack(  );
replaceCloneResults = [  ];
replaceCloneResults.ExcludedClones = struct( [  ] );
replaceCloneResults.ReplacedClones = cloneReplaceResults.ReplacedClones;

if ( clonesRawData.m2mObj.excluded_sysclone.Count > 0 )
excludedClones = keys( clonesRawData.m2mObj.excluded_sysclone );
for cloneIndex = 1:length( clonesRawData.m2mObj.excluded_sysclone )
replaceCloneResults.ExcludedClones( cloneIndex ).Name =  ...
excludedClones{ cloneIndex };
replaceCloneResults.ExcludedClones( cloneIndex ).ReasonForExclusion =  ...
clonesRawData.m2mObj.excluded_sysclone( excludedClones{ cloneIndex } );
end 
end 

replaceCloneResults.ClonesId = cloneResults.ClonesId;
cloneReplacementResults = Simulink.CloneDetection.ReplacementResults( replaceCloneResults );

updatedObj = clonesRawData;
save( clonesRawData.objectFile, 'updatedObj' );
set_param( modelName, 'CloneDetectionUIObj', clonesRawData );
slEnginePir.util.closeBlockDiagramsInList( loadedModels );
catch exception
slEnginePir.util.closeBlockDiagramsInList( loadedModels );
exception.throwAsCaller(  );
return ;
end 
end 



