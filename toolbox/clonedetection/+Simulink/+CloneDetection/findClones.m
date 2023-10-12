function cloneResults = findClones( modelNameFullPath, cloneDetectionSettings )

R36
modelNameFullPath = ''
cloneDetectionSettings = ''
end 

numArguments = nargin;
loadedModels = {  };
cloneDetectionExceptionObj = slEnginePir.util.CloneDetectionExceptionLog.getInstance;
try 
[ modelDirectory, modelName, cloneDetectionSettings, loadedModels, selectedBoundary ] =  ...
Simulink.CloneDetection.internal.util.validateInputToFindClones ...
( numArguments, modelNameFullPath, cloneDetectionSettings );
Simulink.CloneDetection.internal.util.checkoutLicenseForCloneDetection(  );

cloneResultsData = [  ];
cloneResultsData.Clones = [  ];
[ setupData, explicitlyLoadedModels ] = Simulink.CloneDetection.internal.Setup( modelName );
loadedModels = [ loadedModels;explicitlyLoadedModels ];
clonesRawData = setupData.ConfigurationData;

Simulink.CloneDetection.internal.util.updateConfigData( clonesRawData,  ...
cloneDetectionSettings );
clonesRawData.systemFullName = selectedBoundary;
clonesRawData.detectClonesCallBack(  );
cloneResultsData.ExceptionLog = cloneDetectionExceptionObj.ExceptionLoglist;
loadedModels = [ loadedModels;clonesRawData.m2mObj.loadedModels ];
if ~isempty( clonesRawData.historyVersions )

cloneResultsData.ClonesId = [ modelDirectory, ',', modelName, ',' ...
, clonesRawData.historyVersions{ end  } ];
else 
DAStudio.error( 'sl_pir_cpp:creator:CloneDetectionResultsSaveFailed' );
end 

cloneGroupsData = Simulink.CloneDetection.internal.CloneGroupsData( clonesRawData );
if ~isempty( cloneGroupsData.cloneGroupData )
cloneResultsData.Clones.Summary = cloneGroupsData.cloneGroupData.Summary;
metrics = Simulink.CloneDetection.internal.util.getMetrics( clonesRawData );
cloneResultsData.Clones.Summary.PotentialReusePercentage = metrics;
cloneResultsData.Clones.CloneGroups = cloneGroupsData.cloneGroupData.CloneGroups;
end 

if ~isempty( modelName )
systemHandle = get_param( modelName, 'Handle' );
clonesRawData.model = systemHandle;
end 

updatedObj = clonesRawData;

cloneResults = Simulink.CloneDetection.Results( cloneResultsData );
clonesRawData.CloneResults = cloneResults;
save( clonesRawData.objectFile, 'updatedObj' );
slEnginePir.util.closeBlockDiagramsInList( loadedModels );
delete( cloneDetectionExceptionObj );
catch exception
slEnginePir.util.closeBlockDiagramsInList( loadedModels );
if isvalid( cloneDetectionExceptionObj )
delete( cloneDetectionExceptionObj );
end 
exception.throwAsCaller(  );
end 
end 


