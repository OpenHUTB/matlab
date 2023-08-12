function varargout = variantmanager( varargin )





persistent DIALOG_USERDATA
persistent HILITE_DATA
persistent PARAM_EDITOR_DATA
persistent PARAM_HOLD_DATA
persistent PARAM_GARBAGE
persistent MODEL_HIERARCHY_VALIDATION_TEMP_DATA



mlock


narginchk( 1, Inf );


action = varargin{ 1 };
optArgs = varargin( 2:end  );

if ~strcmp( action, 'HasOpenVMs' )

Simulink.variant.utils.reportDiagnosticIfV2Enabled(  );
end 

topObjectName = [  ];
if numel( optArgs ) > 0


topObjectName = optArgs{ 1 };
end 

calledFromTool = true;
compileModeFeatOn = slfeature( 'VRedReduceForCodegen' ) > 0;
try 
switch ( action )
case 'Create'
i_checkJavaAvailability(  );
rootModelName = optArgs{ 1 };
calledFromTool = false;
modelHandle = get_param( rootModelName, 'Handle' );

blockDiagramType = get_param( rootModelName, 'BlockDiagramType' );
if any( strcmp( blockDiagramType, { 'subsystem', 'library' } ) )


excep = MException( message( 'Simulink:VariantManager:NoVariantManager', rootModelName, blockDiagramType ) );
throwAsCaller( excep );
end 


[ tool_exists, frameHandle, ~ ] = i_checkToolExistance( modelHandle, DIALOG_USERDATA );
if tool_exists
javaMethodEDT( 'BringToFront', frameHandle );
return ;
else 



ddSpec = get_param( rootModelName, 'DataDictionary' );
if ~isempty( ddSpec )
try 
Simulink.dd.open( ddSpec );
catch excep


if strcmp( excep.identifier, 'SLDD:sldd:DictionaryNotFound' )
ddErrorMessage = message( 'Simulink:Variants:VariantManagerSLDDNotFound', rootModelName, ddSpec );
else 
ddErrorMessage = message( 'Simulink:Variants:VariantManagerErrorWhileLaunching', rootModelName, i_convertMExceptionHierarchyToMessageAndWrap( excep ) );
end 
ddExcep = MException( ddErrorMessage );
throwAsCaller( ddExcep );
end 
end 

[ modelDirectory, modelExtension ] = i_getModelExtension( rootModelName );

modelExtension = java.lang.String( modelExtension );
modelDirectory = java.lang.String( modelDirectory );
matlabRootDir = java.lang.String( matlabroot );




isSLDVLicenseAvailableForCheckout = license( 'test', 'Simulink_Design_Verifier' );
isSLDVLicenseAvailableForCheckout = java.lang.Boolean( isSLDVLicenseAvailableForCheckout );
variableGroupSupportConfigAnalysis = java.lang.Boolean( slfeature( 'VariableGroupSupportConfigAnalysis' ) );
isReportLicenseAvailableForCheckout = license( 'test', 'SIMULINK_Report_Gen' );
isReportLicenseAvailableForCheckout = java.lang.Boolean( isReportLicenseAvailableForCheckout );
compileModeFeature = java.lang.Boolean( compileModeFeatOn );

args = java.util.Hashtable;
args.put( 'ModelDirectory', modelDirectory );
args.put( 'ModelExtension', modelExtension );
args.put( 'MatlabRootDir', matlabRootDir );
args.put( 'IsSLDVLicenseAvailableForCheckout', isSLDVLicenseAvailableForCheckout );
args.put( 'IsReportLicenseAvailableForCheckout', isReportLicenseAvailableForCheckout );
args.put( 'VariableGroupSupportConfigAnalysisFeature', variableGroupSupportConfigAnalysis );
args.put( 'CompileModeFeature', compileModeFeature );


frameHandle = javaMethodEDT( 'CreateVariantManager', 'com.mathworks.toolbox.simulink.variantmanager.VariantManager', rootModelName, args );

DIALOG_USERDATA( end  + 1 ).ObjectHandle = modelHandle;
DIALOG_USERDATA( end  ).ObjectName = rootModelName;
DIALOG_USERDATA( end  ).FrameHandle = frameHandle;




Simulink.addBlockDiagramCallback( modelHandle, 'PreClose', 'variantmanager', @(  )variantmanager( 'Delete', modelHandle ), true );
Simulink.addBlockDiagramCallback( modelHandle, 'PostNameChange', 'variantmanager', @(  )variantmanager( 'HandleModelSaveAs', modelHandle ), true );



ddSpec = get_param( rootModelName, 'DataDictionary' );
if ~isempty( ddSpec )
ddConn = i_openDataDictionary( ddSpec, frameHandle, true );

if isempty( ddConn ), return ;end 
configDataObjectsInGlobalSection = ddConn.getEntriesWithClass( 'Global', 'Simulink.VariantConfigurationData' );
if ~isempty( configDataObjectsInGlobalSection )


dlg = Simulink.dd.DictionaryVarConfigDataInDesignData(  ...
configDataObjectsInGlobalSection, ddSpec );
DAStudio.Dialog( dlg, '', 'DLG_STANDALONE' );
end 
end 
end 

[ ~, frameHandle, idx ] = i_checkToolExistance( modelHandle, DIALOG_USERDATA );
try 
DIALOG_USERDATA( idx ).ValidationLog = i_Create( rootModelName, frameHandle );
catch ME
errMessage = message( 'Simulink:Variants:VariantManagerErrorWhileLaunching',  ...
rootModelName, i_convertMExceptionHierarchyToMessageAndWrap( ME ) );
javaMethodEDT( 'HandleHardErrors', frameHandle, java.lang.String( errMessage.getString(  ) ), java.lang.Boolean( true ) );
variantmanager( 'Cancel', frameHandle );
end 

case 'HandleModelSaveAs'

modelHandle = optArgs{ 1 };
newModelName = get_param( modelHandle, 'Name' );
calledFromTool = false;


[ tool_exists, frameHandle, idx ] = i_checkToolExistance( modelHandle, DIALOG_USERDATA );
if tool_exists
[ modelDirectory, modelExtension ] = i_getModelExtension( newModelName );
modelExtension = java.lang.String( modelExtension );
modelDirectory = java.lang.String( modelDirectory );
javaMethodEDT( 'HandleModelSaveAs', frameHandle, newModelName, modelExtension, modelDirectory );

if isfield( DIALOG_USERDATA( idx ), 'AnalysisObject' )
DIALOG_USERDATA( idx ).AnalysisObject = [  ];
end 
else 
return ;
end 



variantmanager( 'i_updateParameterDDGTitlesAndData', frameHandle, newModelName );

case 'HandleModelOpen'



modelHandle = optArgs{ 1 };
topObjectName = get_param( modelHandle, 'Name' );
calledFromTool = false;


i_PushDefaultConfigToGlobalWS( topObjectName );

case 'HasOpenVMs'

varargout{ 1 } = ~isempty( DIALOG_USERDATA );

case 'HandleDataDictionaryChange'
modelHandle = optArgs{ 1 };
[ tool_exists, frameHandle, ~ ] = i_checkToolExistance( modelHandle, DIALOG_USERDATA );
if tool_exists
dataDictionary = java.lang.String( optArgs{ 2 } );
javaMethodEDT( 'HandleDataDictionaryChange', frameHandle, dataDictionary );
end 

case 'HandleDataDictionaryMigration'


modelHandle = optArgs{ 1 };
allModels = [ getfullname( modelHandle ),  ...
Simulink.variant.utils.i_find_mdlrefs( getfullname( modelHandle ), struct( 'RecurseIntoModelReferences', true ) ) ];
for i = 1:numel( allModels )
variantConfigurationObject = Simulink.variant.utils.getConfigurationDataNoThrow( allModels{ i } );
if ~isempty( variantConfigurationObject )
new_source = slvariants.internal.config.utils.getGlobalWorkspaceName( get_param( allModels{ i }, 'DataDictionary' ) );
variantConfigurationObject.updateSource( new_source );




Simulink.variant.manager.configutils.saveFor( allModels{ i }, get_param( allModels{ i }, 'VariantConfigurationObject' ), variantConfigurationObject );
end 
[ tool_exists, frameHandle, ~ ] = i_checkToolExistance( get_param( allModels{ i }, 'Handle' ), DIALOG_USERDATA );
if tool_exists
javaMethodEDT( 'HandleDataDictionaryMigration', frameHandle, new_source );
end 
end 

case 'HandleVariantConfigurationObjectChange'
modelHandle = optArgs{ 1 };
[ tool_exists, frameHandle, ~ ] = i_checkToolExistance( modelHandle, DIALOG_USERDATA );
if tool_exists


variantConfigurationObjectName = java.lang.String( optArgs{ 2 } );
javaMethodEDT( 'HandleVariantConfigurationObjectChange', frameHandle, variantConfigurationObjectName );
end 

case 'GetLazyRow'
rootModelName = optArgs{ 1 };
[ ~, ~, idx ] = i_checkToolExistance( get_param( rootModelName, 'Handle' ), DIALOG_USERDATA );
[ instantiatedLazyJavaRow, modelValidationResultsRows, isProtected, validationLog, refModelVariableUsage ] =  ...
i_GetLazyRow( optArgs, DIALOG_USERDATA( idx ).ValidationLog );
DIALOG_USERDATA( idx ).ValidationLog = validationLog;
varargout{ 1 } = { instantiatedLazyJavaRow, modelValidationResultsRows, java.lang.Boolean( isProtected ), refModelVariableUsage };

case 'GetRefreshHierarchyData'

rootModelName = optArgs{ 1 };
[ topJavaRow, modelValidationResultsRow, variableUsage, validationLog ] = i_GetRefreshHierarchyData( optArgs );
varargout{ 1 } = { topJavaRow, modelValidationResultsRow, variableUsage };
[ ~, ~, idx ] = i_checkToolExistance( get_param( rootModelName, 'Handle' ), DIALOG_USERDATA );
DIALOG_USERDATA( idx ).ValidationLog = validationLog;

case 'RefreshVCDOFromGwks'
topModelName = optArgs{ 1 };
variantConfigObjectName = optArgs{ 2 };
variantConfigObject = [  ];
[ exists, section ] = Simulink.variant.utils.existsScalarVCDO(  ...
topModelName, variantConfigObjectName );
ddSpec = get_param( topModelName, 'DataDictionary' );
dataLocation = slvariants.internal.config.utils.getGlobalWorkspaceName( ddSpec );
if exists
variantConfigObject = Simulink.variant.utils.evalExpressionInSection(  ...
topModelName, variantConfigObjectName, section );
variantConfigObject = i_convertVarConfigDataObjToJavaObj( variantConfigObject,  ...
i_getGlobalWorkspaceName( get_param( topModelName, 'DataDictionary' ) ) );
msg = message( 'Simulink:Variants:VariantManagerImportVCDOSuccess', variantConfigObjectName, dataLocation );
infoOrErrMessage = msg.getString(  );
else 
msg = message( 'Simulink:Variants:VariantManagerImportVCDOMissingDefinition', variantConfigObjectName, dataLocation );
infoOrErrMessage = msg.getString(  );
end 
varargout{ 1 } = java.lang.Boolean( exists );
varargout{ 2 } = variantConfigObject;
varargout{ 3 } = java.lang.String( infoOrErrMessage );
varargout{ 4 } = java.lang.String( '' );

case 'ImportVCDOFromFile'
variantConfigurationObjectName = optArgs{ 2 };
fileName = optArgs{ 3 };
[ ~, ~, extension ] = fileparts( fileName );
infoOrErrMessage = '';
if strcmpi( extension, '.mat' )
variablesInMatFileStruct = load( fileName );
variablesInMatFile = fieldnames( variablesInMatFileStruct );
variantConfigurationObjectIndices = cellfun( @( X )( isa( variablesInMatFileStruct.( X ), 'Simulink.VariantConfigurationData' ) ), variablesInMatFile );
variantConfigurationObjectNamesInFile = variablesInMatFile( variantConfigurationObjectIndices );
variantConfigurationObjectsInFile = cellfun( @( X )( variablesInMatFileStruct.( X ) ), variantConfigurationObjectNamesInFile, 'UniformOutput', false );
elseif strcmpi( extension, '.m' )
[ variantConfigurationObjectNamesInFile, variantConfigurationObjectsInFile, infoOrErrMessage ] = i_extractVCDOFromMatlabScript( fileName );
end 

if isempty( infoOrErrMessage )
if any( strcmp( variantConfigurationObjectName, variantConfigurationObjectNamesInFile ) )
msg = message( 'Simulink:Variants:VariantManagerImportVCDOSuccess', variantConfigurationObjectName, fileName );
else 
msg = message( 'Simulink:Variants:VariantManagerImportVCDOMissingDefinitions', fileName );
end 
infoOrErrMessage = msg.getString(  );
end 
varargout{ 1 } = variantConfigurationObjectNamesInFile;
dataDictionary = get_param( topObjectName, 'DataDictionary' );
varargout{ 2 } = cellfun( @( X )( i_convertVarConfigDataObjToJavaObj( X, i_getGlobalWorkspaceName( dataDictionary ) ) ), variantConfigurationObjectsInFile, 'UniformOutput', false );
varargout{ 3 } = java.lang.String( infoOrErrMessage );
varargout{ 4 } = java.lang.String( fileName );

case 'OpenStandAloneForModel'
modelName = optArgs{ 1 };
variantConfigurationObjectName = get_param( modelName, 'VariantConfigurationObject' );
variantConfigurationObject = evalinConfigurationsScope( modelName, variantConfigurationObjectName );
variantmanager( 'EditVarConfigDataObj', variantConfigurationObjectName, variantConfigurationObject );


case 'EditVarConfigDataObj'
i_checkJavaAvailability(  );
objectName = optArgs{ 1 };
objectHandle = optArgs{ 2 };
calledFromTool = false;

[ tool_exists, frameHandle, ~ ] = i_checkToolExistance( objectHandle, DIALOG_USERDATA );
if tool_exists
javaMethodEDT( 'BringToFront', frameHandle );
return ;
end 
args = java.util.Hashtable;

if ~tool_exists
frameHandle = javaMethodEDT( 'CreateVariantManagerStandAlone',  ...
'com.mathworks.toolbox.simulink.variantmanager.VariantManager', objectName, args );

DIALOG_USERDATA( end  + 1 ).ObjectHandle = objectHandle;
DIALOG_USERDATA( end  ).ObjectName = objectName;
DIALOG_USERDATA( end  ).FrameHandle = frameHandle;
end 

i_EditVarConfigDataObj( objectHandle, frameHandle );

case { 'Delete', 'Cancel' }
rootModelName = topObjectName;
try 
modelHandle = get_param( rootModelName, 'Handle' );
catch excep %#ok
modelHandle = [  ];
end 


if ~isempty( modelHandle )
[ tool_exists, frameHandle, idx ] = i_checkToolExistance( modelHandle, DIALOG_USERDATA );
if tool_exists


variantmanager( 'i_cancelEditingOfParameters', frameHandle );

HILITE_DATA = i_Unhilite( HILITE_DATA, frameHandle );
awtinvoke( frameHandle, 'dispose()' );
DIALOG_USERDATA( idx ) = [  ];
end 
if strcmp( action, 'Cancel' )


i_PushDefaultConfigToGlobalWS( rootModelName );
end 
elseif length( optArgs ) == 2

frameHandle = optArgs{ 2 };
awtinvoke( frameHandle, 'dispose()' );
end 

variantmanager( 'i_clearParameterGarbage' );

case 'CancelStandAlone'
objectName = topObjectName;

foundAndDisposed = false;

if ~isempty( DIALOG_USERDATA )
idx = find( strcmp( objectName, { DIALOG_USERDATA( : ).ObjectName } ) );

if ~isempty( idx )
frameHandle = DIALOG_USERDATA( idx ).FrameHandle;



variantmanager( 'i_cancelEditingOfParameters', frameHandle );

awtinvoke( frameHandle, 'dispose()' );
DIALOG_USERDATA( idx ) = [  ];
foundAndDisposed = true;
end 
end 

if ~foundAndDisposed
frameHandle = optArgs{ 2 };
awtinvoke( frameHandle, 'dispose()' );
end 


variantmanager( 'i_clearParameterGarbage' );

case 'DeleteAll'

calledFromTool = false;
if ~isempty( DIALOG_USERDATA )
for i = 1:length( DIALOG_USERDATA )
try 
frameHandle = DIALOG_USERDATA( i ).FrameHandle;
awtinvoke( frameHandle, 'dispose()' );
catch 
end 
end 
DIALOG_USERDATA = [  ];
HILITE_DATA = [  ];
end 



variantmanager( 'i_cancelEditingOfParameters' );


variantmanager( 'i_clearParameterGarbage' );

case 'Export'
i_Export( optArgs );

case 'ExportStandAlone'
i_Export_StandAlone( optArgs, DIALOG_USERDATA );


case 'ExportControlVars'
[ hasCollision, collindingVars ] = i_ExportControlVars( optArgs );
if hasCollision
varargout{ 1 } = java.lang.Boolean( false );
msg = message( 'Simulink:Variants:VariantManagerClashingVariables', strjoin( collindingVars, ', ' ) );
varargout{ 2 } = java.lang.String( msg.getString(  ) );
end 


case 'ExportAndSaveToMatFile'
[ configObject, varConfigDataName ] = i_Export( optArgs( 1:3 ) );
fileName = optArgs{ 4 };

extractVarNameFcn = @( X )inputname( 1 );


eval( [ varConfigDataName, '=', extractVarNameFcn( configObject ) ] );
try 

save( fileName, varConfigDataName );
varargout{ 1 } = java.lang.Boolean( true );
msg = message( 'Simulink:Variants:VariantManagerSaveVCDOOutputFilePrefix', fileName );
varargout{ 2 } = java.lang.String( msg.getString(  ) );
catch ME



varargout{ 1 } = java.lang.Boolean( false );
varargout{ 2 } = java.lang.String( i_convertMExceptionHierarchyToMessage( ME ) );
end 
varargout{ 3 } = java.lang.String( fileName );

case 'ExportAndSaveToMScript'
[ configObject, varConfigDataName ] = i_Export( optArgs( 1:3 ) );
fileName = optArgs{ 4 };
[ success, errMessage ] = Simulink.variant.manager.configutils.generateMATLABScript( configObject, varConfigDataName, fileName );
varargout{ 1 } = java.lang.Boolean( success );
msg = message( 'Simulink:Variants:VariantManagerSaveVCDOOutputFilePrefix', fileName );
infoMessage = msg.getString(  );
if ~success
infoMessage = [ infoMessage, newline, errMessage ];
end 
varargout{ 2 } = java.lang.String( infoMessage );
varargout{ 3 } = java.lang.String( fileName );

case 'OpenImportedFromOrExportedToMScript'
success = true;
errMessage = '';
try 
open( optArgs{ 1 } );
catch ME
success = false;
errMessage = i_convertMExceptionHierarchyToMessage( ME );
end 
varargout{ 1 } = java.lang.Boolean( success );
varargout{ 2 } = java.lang.String( errMessage );

case 'Help'
helpview( fullfile( docroot, 'toolbox', 'simulink', 'helptargets.map' ), 'variantmanager' );

case 'CreateAndNavigate'

rootModelName = optArgs{ 1 };
load_system( rootModelName );
variantmanager( 'Create', rootModelName );

modelHandle = get_param( rootModelName, 'Handle' );
[ tool_exists, frameHandle ] = i_checkToolExistance( modelHandle, DIALOG_USERDATA );

if ~tool_exists
return ;
end 

blockPathRootModel = optArgs{ 2 };
expandSelectedRow = false;
if numel( optArgs ) == 3
expandSelectedRow = optArgs{ 3 };
end 
pathComponentsInHierarchy = Simulink.variant.utils.splitPathInHierarchy( blockPathRootModel );
javaMethodEDT( 'NavigateToBlockInHierarchy', frameHandle, pathComponentsInHierarchy, java.lang.Boolean( expandSelectedRow ) );

case 'CheckObjectExistsForModel'
[ varargout{ 1:nargout } ] = i_CheckVarConfigDataExistsForModel( optArgs );

case 'ClearAssociation'
i_ClearAssociation( optArgs );

case 'GetUniqueKeyName'
[ varargout{ 1:nargout } ] = i_GetUniqueKeyName( optArgs );

case 'IsValidVarName'
varNameTobeChecked = char( optArgs{ 2 } );
isValid = isvarname( varNameTobeChecked );
varargout{ 1 } = java.lang.Boolean( isValid );

case 'IsValidControlVarValue'
ctrlVarInfoStruct = getCtrlVarInfoStruct(  );
ctrlVarInfoStruct.Value = char( optArgs{ 2 } );
ctrlVarInfoStruct.IsParam = optArgs{ 3 };
ctrlVarInfoStruct.IsParamValueExpression = optArgs{ 4 };
ctrlVarInfoStruct.IsAUTOSARParam = optArgs{ 5 };
ctrlVarInfoStruct.IsSimulinkVariantControl = optArgs{ 6 };
isValid = slvariants.internal.config.utils.isValidControlVarValue2( ctrlVarInfoStruct );
varargout{ 1 } = java.lang.Boolean( isValid );

case 'GetValueofExpression'
varargout{ 1 } = java.lang.String( i_getValueOfParamObjectUponConversionToNormalVar( optArgs ) );

case 'GetCopyOfConfiguration'
[ varargout{ 1:nargout } ] = i_GetCopyOfConfiguration( optArgs );

case 'GetCopyOfControlVariable'
[ varargout{ 1:nargout } ] = i_GetCopyOfControlVariable( optArgs );

case 'SetBlockVariantControl'
[ varargout{ 1:nargout } ] = i_SetBlockVariantControl( optArgs );

case 'SetVariantSFTransitionControl'
[ varargout{ 1:nargout } ] = i_SetVariantSFTransitionControl( optArgs );

case 'SetVariantCondition'
[ varargout{ 1:nargout } ] = i_SetVariantCondition( optArgs );

case 'SetActiveLabelChoice'
[ varargout{ 1:nargout } ] = i_SetActiveLabelChoice( optArgs );

case 'OpenBlockParameters'
[ varargout{ 1:nargout } ] = i_OpenBlockParameters( optArgs );

case 'OpenChartParameters'
[ varargout{ 1:nargout } ] = i_OpenChartParameters( optArgs );

case 'GetNamesAndValuesOfControlVariables'
modelHandle = get_param( char( optArgs{ 1 } ), 'Handle' );
[ ~, frameHandle, ~ ] = i_checkToolExistance( modelHandle, DIALOG_USERDATA );
[ varargout{ 1:nargout } ] = i_GetNamesAndValuesOfControlVariables( optArgs, frameHandle );

case 'BringEditingParameterToFront'
frameHandle = optArgs{ 2 };
for i = 1:numel( PARAM_EDITOR_DATA )
if frameHandle.equals( PARAM_EDITOR_DATA( i ).FrameHandle )
show( PARAM_EDITOR_DATA( i ).DialogHandle );
end 
end 

case 'EditParameter'

frameHandle = optArgs{ 2 };
configurationName = char( optArgs{ 3 } );
javaSimParamControlVar = optArgs{ 4 };

controlVariable = i_convertJavaObjToSimpleStructs( javaSimParamControlVar, { 'Name', 'Value' } );
controlVarName = controlVariable.Name;
value = controlVariable.Value;
if isa( value, 'Simulink.VariantControl' )
paramValue = value.Value;
else 
paramValue = value;
end 

dialogHandle = DAStudio.Dialog( paramValue );
if ishandle( dialogHandle )

paramClassName = class( paramValue );
title = [ paramClassName, ' : ', controlVarName, ' (', topObjectName, ', ', configurationName, ')' ];
dialogHandle.setTitle( title );

l = handle.listener( dialogHandle, 'ObjectBeingDestroyed', @( s, e )( variantmanager( 'PutEditedParameterOnHold', topObjectName, dialogHandle ) ) );

PARAM_EDITOR_DATA( end  + 1 ).DialogHandle = dialogHandle;
PARAM_EDITOR_DATA( end  ).FrameHandle = frameHandle;
PARAM_EDITOR_DATA( end  ).TopObjectName = topObjectName;
PARAM_EDITOR_DATA( end  ).ConfigurationName = configurationName;
PARAM_EDITOR_DATA( end  ).ControlVar = controlVariable;
assert( ~paramValue.CoderInfo.HasContext, 'Expected base workspace object only' );
PARAM_EDITOR_DATA( end  ).OriginalParamValue = Simulink.variant.utils.deepCopy( value );
PARAM_EDITOR_DATA( end  ).ListenerHandle = l;
PARAM_EDITOR_DATA( end  ).SendBackResults = true;
end 

case 'PutEditedParameterOnHold'

dialogHandle = optArgs{ 2 };

if isempty( PARAM_EDITOR_DATA )
return ;
end 

idx = find( [ PARAM_EDITOR_DATA.DialogHandle ] == dialogHandle );
if ~isempty( idx )
ed = PARAM_EDITOR_DATA( idx );
configurationName = ed.ConfigurationName;
if ( ed.SendBackResults )
if ishandle( ed.FrameHandle )
PARAM_HOLD_DATA( end  + 1 ).FrameHandle = ed.FrameHandle;
PARAM_HOLD_DATA( end  ).ConfigurationName = ed.ConfigurationName;
PARAM_HOLD_DATA( end  ).ControlVar = ed.ControlVar;
PARAM_HOLD_DATA( end  ).OriginalParamValue = ed.OriginalParamValue;
javaMethodEDT( 'RequestCallToGetEditedParameter', ed.FrameHandle, configurationName, ed.ControlVar.Name );
end 
end 
PARAM_EDITOR_DATA( idx ) = [  ];
end 

case 'GetEditedParameter'

frameHandle = optArgs{ 2 };
configurationName = optArgs{ 3 };
controlVarName = optArgs{ 4 };

numDataItems = length( PARAM_HOLD_DATA );
for di = 1:numDataItems
dataItem = PARAM_HOLD_DATA( di );
if ishandle( dataItem.FrameHandle ) && ( dataItem.FrameHandle == frameHandle )
controlVariable = dataItem.ControlVar;




if isa( controlVariable.Value, 'Simulink.VariantControl' )
isEdited = ~PARAM_HOLD_DATA( end  ).OriginalParamValue.Value.isequal( controlVariable.Value.Value );
else 
isEdited = ~PARAM_HOLD_DATA( end  ).OriginalParamValue.isequal( controlVariable.Value );
end 
if strcmp( dataItem.ConfigurationName, configurationName ) && strcmp( controlVariable.Name, controlVarName )
if isa( controlVariable.Value, 'Simulink.VariantControl' )
paramValue = controlVariable.Value.Value;
else 
paramValue = controlVariable.Value;
end 
if isempty( PARAM_GARBAGE )
PARAM_GARBAGE = paramValue;
else 
PARAM_GARBAGE( end  + 1 ) = paramValue;%#ok
end 
PARAM_HOLD_DATA( di ) = [  ];

eqJavaVar = i_convertSimpleStructsToJavaObj( controlVariable );

if ishandle( frameHandle )
javaMethodEDT( 'UpdateControlVariable', frameHandle, configurationName, eqJavaVar.get( 0 ), isEdited );
end 
return ;
end 
end 
end 

case 'GetConfigurationsInVCDOForModel'
[ varargout{ 1:nargout } ] = i_GetConfigurationsInVCDOForModel( optArgs );




case 'GetVariantConfigurationObjectNamesForModel'
modelHandle = get_param( topObjectName, 'Handle' );
tool_exists = i_checkToolExistance( modelHandle, DIALOG_USERDATA );
if tool_exists
[ varargout{ 1:nargout } ] = i_GetListOfVarConfigDataObjNamesForModel( optArgs );
end 

case 'OpenModel'


rootModelName = optArgs{ 1 };
blockPathAllLevels = optArgs{ 2 };
refModelName = optArgs{ 3 };
if ( numel( blockPathAllLevels ) == 1 ) && strcmp( blockPathAllLevels{ 1 }, rootModelName )

blockPathOrBlockPathObject = blockPathAllLevels{ 1 };
else 
blockPathOrBlockPathObject = Simulink.BlockPath( blockPathAllLevels );
end 
try 
isProtected = Simulink.variant.utils.getIsProtectedModelAndFullFile( refModelName );
if isProtected



Simulink.ProtectedModel.open( refModelName );
else 

i_openTopModelorBlockinSameStudio( blockPathOrBlockPathObject );
end 
catch excep
varargout{ 1 } = java.lang.Boolean( false );
varargout{ 2 } = java.lang.Boolean( true );
varargout{ 3 } = java.lang.String( i_convertMExceptionHierarchyToMessageAndWrap( excep ) );
return ;
end 

case 'OpenAndHighlightInEditor'


frameHandle = optArgs{ 2 };

blockPathAllLevels = optArgs{ 3 };

stateflowH = [  ];
if ~isempty( optArgs{ 4 } )
stateflowId = str2double( optArgs( 4 ) );
if ~isempty( stateflowId )
stateflowH = sf( 'IdToHandle', stateflowId );
end 
end 



if isa( stateflowH, 'Stateflow.Chart' )
stateflowH = [  ];
end 

if isempty( stateflowH )
blockPathOrBlockPathObject = Simulink.BlockPath( blockPathAllLevels );
parentBlockPathOrBlockPathObject = blockPathOrBlockPathObject.getParent(  );
end 


HILITE_DATA = i_Unhilite( HILITE_DATA, frameHandle );
try 




if isempty( stateflowH )
i_openTopModelorBlockinSameStudio( parentBlockPathOrBlockPathObject );
hilite_system( blockPathOrBlockPathObject, 'find' );
HILITE_DATA( end  + 1 ).FrameHandle = frameHandle;
HILITE_DATA( end  ).BlockPath = blockPathOrBlockPathObject;
HILITE_DATA( end  ).ParentSFChartId = [  ];
set_param( blockPathAllLevels{ end  }, 'Selected', 'on' );
else 


stateflowH.view(  );
stateflowH.highlight(  );
HILITE_DATA( end  + 1 ).FrameHandle = frameHandle;
HILITE_DATA( end  ).BlockPath = [  ];
HILITE_DATA( end  ).ParentSFChartId = stateflowH.getParent(  ).Id;
end 
catch excep
varargout{ 1 } = java.lang.Boolean( false );
varargout{ 2 } = java.lang.Boolean( false );
varargout{ 3 } = java.lang.String( i_convertMExceptionHierarchyToMessageAndWrap( excep ) );
return ;
end 
varargout{ 1 } = java.lang.Boolean( true );
varargout{ 2 } = java.lang.Boolean( false );
varargout{ 3 } = '';
varargout{ 4 } = '';



case 'ClearPersistentIfTopModelHasNoVCDO'





MODEL_HIERARCHY_VALIDATION_TEMP_DATA.TopModelName = optArgs{ 1 };
MODEL_HIERARCHY_VALIDATION_TEMP_DATA.ValidationLog = [  ];


case 'WarnIfVMHadUnexportedChanges'
modelName = optArgs{ 1 };
modelHandle = get_param( modelName, 'Handle' );
[ tool_exists, frameHandle, ~ ] = i_checkToolExistance( modelHandle, DIALOG_USERDATA );
if tool_exists && javaMethod( 'util_hasUnexportedChanges', frameHandle )
msgID = 'Simulink:VariantManager:VariantManagerUnexportedChanges';
warnState = warning( 'off', 'backtrace' );
warning( msgID, getString( message( msgID, modelName ) ) );
warning( warnState.state, 'backtrace' );
end 


case 'ValidateVariantConfigForModel'
parentModelName = optArgs{ 1 };
modelName = optArgs{ 2 };
calledFromTool = false;

isProtected = Simulink.variant.utils.getIsProtectedModelAndFullFile( modelName );
if isProtected

varargout{ 1 } = [  ];
varargout{ 2 } = '';
return ;
end 

varConfigDataName = get_param( modelName, 'VariantConfigurationObject' );
if ~isempty( varConfigDataName )
varConfigData = Simulink.variant.utils.getConfigurationDataNoThrow( modelName );
else 
varConfigData = [  ];
end 

validationLog = [  ];
configName = '';


if isempty( parentModelName )


MODEL_HIERARCHY_VALIDATION_TEMP_DATA.TopModelName = modelName;
MODEL_HIERARCHY_VALIDATION_TEMP_DATA.ValidationLog = validationLog;
else 
if ~isempty( MODEL_HIERARCHY_VALIDATION_TEMP_DATA )
validationLog = MODEL_HIERARCHY_VALIDATION_TEMP_DATA.ValidationLog;
end 
if ~isempty( validationLog )
idxOfParent = find( strcmp( parentModelName, { validationLog( : ).Model } ), 1, 'last' );
else 
idxOfParent = [  ];
end 
if ~isempty( idxOfParent )
previouslyValidatedConfiguration = validationLog( idxOfParent ).Configuration;
if ~isempty( previouslyValidatedConfiguration )
[ ~, configName ] = Simulink.variant.manager.configutils.getSubModelConfig( modelName, previouslyValidatedConfiguration );
end 
end 
end 


if ~isempty( varConfigData ) && isempty( configName )
configName = varConfigData.DefaultConfigurationName;
end 

errors = [  ];



if ~isempty( varConfigDataName ) || ~isempty( configName )
validateModelOptArgs = struct( 'RecurseIntoModelReferences', false, 'CalledFromTool', calledFromTool );
if ~isempty( configName )
validateModelOptArgs.ConfigurationName = configName;
validateModelOptArgs.UsedByDefaultConfig = true;
[ errorsInModel, validationLog ] = Simulink.variant.manager.configutils.validateModelEntry( modelName, validationLog, validateModelOptArgs );
else 
[ errorsInModel, validationLog ] = Simulink.variant.manager.configutils.validateModelEntry( modelName, validationLog, validateModelOptArgs );
end 

if ~isempty( errorsInModel )
errors = errorsInModel{ 1 }.Errors;
end 
end 

MODEL_HIERARCHY_VALIDATION_TEMP_DATA.ValidationLog = validationLog;

if ~isempty( errors )
varargout{ 1 } = errors;
else 
varargout{ 1 } = [  ];
end 
varargout{ 2 } = configName;

case 'ValidateStructInput'
ctrlVarNames = optArgs( 1:2:end  );
ctrlVarValues = optArgs( 2:2:end  );
isValidNames = checkVarNames( ctrlVarNames );
isValidValues = cellfun( @isValidCrtlValueFun, ctrlVarValues );
varargout{ 1 } = java.lang.Boolean( all( isValidNames ) && all( isValidValues ) );
varargout{ 2 } = ctrlVarNames( ~isValidNames );
varargout{ 3 } = ctrlVarValues( ~isValidValues );

case 'ReduceModelConfigMode'
modelName = optArgs{ 1 };
configInfos = optArgs( 2:end  - 5 );
compileMode = optArgs{ end  - 4 };
outDir = optArgs{ end  - 3 };
suffix = optArgs{ end  - 2 };
preserveSignalAttributes = optArgs{ end  - 1 };
generateReport = optArgs{ end  };
verbose = false;
modelHandle = get_param( modelName, 'Handle' );
[ tool_exists, frameHandle, ~ ] = i_checkToolExistance( modelHandle, DIALOG_USERDATA );

if ( tool_exists )
pvArgs = { 'OutputFolder', outDir,  ...
'ModelSuffix', suffix,  ...
'PreserveSignalAttributes', preserveSignalAttributes,  ...
'GenerateSummary', generateReport,  ...
'Verbose', verbose,  ...
'NamedConfigurations', configInfos,  ...
'FrameHandle', frameHandle };
if compileModeFeatOn
pvArgs = [ { 'CompileMode', compileMode }, pvArgs ];
end 

[ varargout{ 1 }, varargout{ 2 }, varargout{ 3 } ] = i_reduceModelAndCollateOutput( modelName, pvArgs );
end 

case 'ReduceModelStructMode'
modelName = optArgs{ 1 };
specifiedVars = getVariableGroups( optArgs{ 2 } );
fullrangeVars = getNameValuePairFromHashtable( optArgs{ 3 } );
compileMode = optArgs{ 4 };
outDir = optArgs{ 5 };
suffix = optArgs{ 6 };
preserveSignalAttributes = optArgs{ 7 };
generateReport = optArgs{ 8 };

verbose = false;
modelHandle = get_param( modelName, 'Handle' );
[ tool_exists, frameHandle, ~ ] = i_checkToolExistance( modelHandle, DIALOG_USERDATA );

if ( tool_exists )
pvArgs = { 'OutputFolder', outDir,  ...
'ModelSuffix', suffix,  ...
'PreserveSignalAttributes', preserveSignalAttributes,  ...
'GenerateSummary', generateReport,  ...
'Verbose', verbose,  ...
'VariableGroups', specifiedVars,  ...
'FrameHandle', frameHandle };
if compileModeFeatOn
pvArgs = [ { 'CompileMode', compileMode }, pvArgs ];
end 
if ~isempty( fullrangeVars )


pvArgs = [ pvArgs, { 'FullRangeVariables', fullrangeVars } ];
end 
[ varargout{ 1 }, varargout{ 2 }, varargout{ 3 } ] = i_reduceModelAndCollateOutput( modelName, pvArgs );
end 

case 'ReduceModelDefaultMode'
modelName = optArgs{ 1 };
compileMode = optArgs{ 2 };
outDir = optArgs{ 3 };
suffix = optArgs{ 4 };
preserveSignalAttributes = optArgs{ 5 };
generateReport = optArgs{ 6 };
verbose = false;
modelHandle = get_param( modelName, 'Handle' );
[ tool_exists, frameHandle, ~ ] = i_checkToolExistance( modelHandle, DIALOG_USERDATA );

if ( tool_exists )
pvArgs = { 'OutputFolder', outDir,  ...
'ModelSuffix', suffix,  ...
'PreserveSignalAttributes', preserveSignalAttributes,  ...
'GenerateSummary', generateReport,  ...
'Verbose', verbose,  ...
'FrameHandle', frameHandle };
if compileModeFeatOn
pvArgs = [ { 'CompileMode', compileMode }, pvArgs ];
end 
[ varargout{ 1 }, varargout{ 2 }, varargout{ 3 } ] = i_reduceModelAndCollateOutput( modelName, pvArgs );
end 

case 'CheckConditionsForLaunchingReducer'
optArgs{ end  + 1 } = false;
[ varargout{ 1 }, varargout{ 2 }, varargout{ 3 }, varargout{ 4 } ] = i_getVariantManagerPluginInfo( optArgs );

case 'CheckConditionsForLaunchingConfigurationAnalysis'
optArgs{ end  + 1 } = ( slfeature( 'VariableGroupSupportConfigAnalysis' ) < 1 );
[ varargout{ 1 }, varargout{ 2 }, varargout{ 3 }, varargout{ 4 } ] = i_getVariantManagerPluginInfo( optArgs );

case 'GenerateVariantConfigurationAnalysisReport'
modelName = optArgs{ 1 };
modelHandle = get_param( modelName, 'handle' );
configInfos = optArgs( 2:end  );
success = true;
errMsg = '';
try 
[ tool_exists, ~, idx ] = i_checkToolExistance( modelHandle, DIALOG_USERDATA );
if tool_exists
DIALOG_USERDATA( idx ).AnalysisObject = [  ];

DIALOG_USERDATA( idx ).AnalysisObject = Simulink.VariantConfigurationAnalysis( modelName, 'NamedConfigurations', configInfos );
DIALOG_USERDATA( idx ).AnalysisObject.showUI(  );
end 
catch ME
success = false;
errMsg = i_convertMExceptionHierarchyToMessage( ME );
end 
varargout{ 1 } = java.lang.Boolean( success );
varargout{ 2 } = java.lang.String( errMsg );

case 'GenerateVariantConfigurationAnalysisReportStructMode'
modelName = optArgs{ 1 };
modelHandle = get_param( modelName, 'handle' );
specifiedVars = getVariableGroups( optArgs{ 2 } );
success = true;
errMsg = '';
try 
[ tool_exists, ~, idx ] = i_checkToolExistance( modelHandle, DIALOG_USERDATA );
if tool_exists
DIALOG_USERDATA( idx ).AnalysisObject = [  ];

DIALOG_USERDATA( idx ).AnalysisObject = Simulink.VariantConfigurationAnalysis( modelName, 'VariableGroups', specifiedVars );
DIALOG_USERDATA( idx ).AnalysisObject.showUI(  );
end 
catch ME
success = false;
errMsg = i_convertMExceptionHierarchyToMessage( ME );
end 
varargout{ 1 } = java.lang.Boolean( success );
varargout{ 2 } = java.lang.String( errMsg );

case 'OpenReducedModel'
try 
open_system( optArgs{ 1 } );
varargout{ 1 } = java.lang.Boolean( true );
varargout{ 2 } = java.lang.String( '' );
catch ME
varargout{ 1 } = java.lang.Boolean( false );
varargout{ 2 } = java.lang.String( i_convertMExceptionHierarchyToMessageAndWrap( ME ) );
end 
case 'ChangeDirectoryAndOpenReducedModel'
try 
calledFromUI = true;
Simulink.variant.reducer.utils.cdAndOpenReducedModel( optArgs{ 1 }, calledFromUI );
varargout{ 1 } = java.lang.Boolean( true );
varargout{ 2 } = java.lang.String( '' );
catch ME
varargout{ 1 } = java.lang.Boolean( false );
varargout{ 2 } = java.lang.String( i_convertMExceptionHierarchyToMessageAndWrap( ME ) );
end 
case 'HelpForReducer'
helpview( fullfile( docroot, 'toolbox', 'simulink', 'helptargets.map' ), 'variantreduce' );
case 'HelpForConfigurationAnalysis'
helpview( fullfile( docroot, 'toolbox', 'simulink', 'helptargets.map' ), 'variantconfigurationanalysis' );
case 'i_cancelEditingOfParameters'
calledFromTool = false;


numDataItems = length( PARAM_EDITOR_DATA );
numOptArgs = length( optArgs );
if numOptArgs > 0
frameHandle = optArgs{ 1 };
end 
for ei = numDataItems: - 1:1
ed = PARAM_EDITOR_DATA( ei );
if ( numOptArgs > 0 ) && ( ed.FrameHandle ~= frameHandle )
continue ;
end 



controlVariable = ed.ControlVar;
dialogHandle = ed.DialogHandle;
ed.SendBackResults = false;
PARAM_EDITOR_DATA( ei ) = ed;
try 
delete( dialogHandle );
if isa( controlVariable.Value, 'Simulink.VariantControl' )
paramValue = controlVariable.Value.Value;
else 
paramValue = controlVariable.Value;
end 
if isempty( PARAM_GARBAGE )
PARAM_GARBAGE = paramValue;
else 
PARAM_GARBAGE( end  + 1 ) = paramValue;%#ok
end 
catch 
end 
end 

case 'i_updateParameterDDGTitlesAndData'
calledFromTool = false;


frameHandle = optArgs{ 1 };
topObjectName = optArgs{ 2 };
numDataItems = length( PARAM_EDITOR_DATA );
for ei = 1:numDataItems
ed = PARAM_EDITOR_DATA( ei );
if ed.FrameHandle ~= frameHandle

continue ;
end 
configName = ed.ConfigurationName;
dialogHandle = ed.DialogHandle;
controlVarName = ed.ControlVar.Name;
ed.TopObjectName = topObjectName;
paramClassName = class( ed.ControlVar.Value );
title = [ paramClassName, ' : ', controlVarName, ' (', topObjectName, ', ', configName, ')' ];


dialogHandle.setTitle( title );
PARAM_EDITOR_DATA( ei ) = ed;
end 

case 'OpenDataDictionaryorBaseWorkspace'
dataDictionary = optArgs{ 2 };
success = true;
errMessage = '';
try 
if isempty( dataDictionary )
daexplr;
else 
open( dataDictionary );
end 
catch ME
success = false;
errMessage = i_convertMExceptionHierarchyToMessageAndWrap( ME );
end 
varargout{ 1 } = java.lang.Boolean( success );
varargout{ 2 } = java.lang.String( errMessage );
case 'i_clearParameterGarbage'
calledFromTool = false;

numParamsInGarbage = length( PARAM_GARBAGE );
for gi = 1:numParamsInGarbage
paramHandle = PARAM_GARBAGE( gi );
try 
if isvalid( paramHandle )
delete( paramHandle );
end 
catch 
end 
end 
PARAM_GARBAGE = [  ];
case 'GetFrameHandle'

calledFromTool = false;
modelName = optArgs{ 1 };
modelHandle = get_param( modelName, 'Handle' );
[ ~, varargout{ 1 } ] = i_checkToolExistance( modelHandle, DIALOG_USERDATA );
case 'GetVariableUsage'

rootModelName = optArgs{ 1 };
varargout{ 1 } = i_getVariableUsageInfo( rootModelName );
end 
catch excep
if ~isempty( topObjectName ) && calledFromTool
if strncmp( excep.identifier, 'SLDD:sldd:', length( 'SLDD:sldd:' ) )
modelHandle = get_param( topObjectName, 'Handle' );
[ tool_exists, frameHandle, ~ ] = i_checkToolExistance( modelHandle, DIALOG_USERDATA );
if tool_exists
javaMethodEDT( 'HandleHardErrors', frameHandle, java.lang.String( i_convertMExceptionHierarchyToMessageAndWrap( excep ) ), java.lang.Boolean( false ) );
end 
elseif strcmp( excep.identifier, 'Simulink:dialog:VariantManagerToolNeedsJava' )
throwAsCaller( excep );
else 
i_ReportException( { topObjectName, i_convertMExceptionHierarchyToMessageAndWrap( excep ) }, DIALOG_USERDATA );
end 
else 
throwAsCaller( excep );
end 
end 
end 


function validationLog = i_Create( rootModelName, frameHandle )
variantConfigurationObjectName = get_param( rootModelName, 'VariantConfigurationObject' );
variantConfigurationObject = Simulink.variant.utils.getConfigurationDataNoThrow( rootModelName );

optArgsStruct.HotlinkErrors = false;
optArgsStruct.CalledFromTool = true;




optArgsStruct.RecurseIntoModelReferences = false;
validationLog = [  ];
[ validationErrorsForHierarchy, validationLog, createModelInfoLog ] = Simulink.variant.manager.configutils.validateModelEntry( rootModelName, validationLog, optArgsStruct );

dataDictionary = validationLog( strcmp( { validationLog.Model }, rootModelName ) ).( 'DataDictionary' );


if isempty( variantConfigurationObject )

variantConfigurationObject = Simulink.VariantConfigurationData;
end 
eqvVarConfigDataJavaObj = i_convertVarConfigDataObjToJavaObj( variantConfigurationObject, i_getGlobalWorkspaceName( dataDictionary ) );
validationInfo = i_convertToJavaValidationInfo( validationErrorsForHierarchy, validationLog, variantConfigurationObjectName, rootModelName );
configName = variantConfigurationObject.DefaultConfigurationName;

topJavaRow = createModelInfoLog.TopRow.getJavaRow(  );

args = java.util.Hashtable;
args.put( 'ConfigurationName', java.lang.String( configName ) );
args.put( 'TopRow', topJavaRow );
args.put( 'VariantConfigurationObjectName', java.lang.String( variantConfigurationObjectName ) );
args.put( 'VariantConfigurationObject', eqvVarConfigDataJavaObj );
args.put( 'ValidationInfo', validationInfo );
args.put( 'DataDictionaryName', java.lang.String( dataDictionary ) );
args.put( 'VariableUsage', java.util.Hashtable );

javaMethodEDT( 'Initialize', frameHandle, args );

awtinvoke( frameHandle, 'setVisible(Z)', true );
drawnow;
end 

function variableUsage = i_getVariableUsageInfo( rootModelName )
optArgs = Simulink.variant.utils.getControlVariableNamesFromVariantExpressionsOptArgs(  );
optArgs.ConsiderAllAsVariables = true;
optArgs.CalledFromTool = true;
optArgs.RecurseIntoModelReferences = true;
[ varNames, variableUsageInfo, sourceInfo ] =  ...
Simulink.variant.utils.getControlVariableNamesFromVariantExpressions( rootModelName, optArgs );
variableUsage = i_convertMapToTable( rootModelName, variableUsageInfo.ControlVarToBlockUsageMap, varNames, sourceInfo.ModelsToVarsMap );
end 

function [ isDirty, isSLDVLicenseCheckedOut, errMsg, ctrlVarsInfo ] = i_getVariantManagerPluginInfo( optArgs )
modelName = optArgs{ 1 };
skipImportControlVars = optArgs{ 2 };
isDirtyString = get_param( modelName, 'Dirty' );
isDirty = strcmp( isDirtyString, 'on' );
[ isSLDVLicenseCheckedOut, errMsg ] = i_getLicenseCheckoutInfo(  );
ctrlVarsInfo = java.util.Vector;
if ~skipImportControlVars && ~isDirty && isSLDVLicenseCheckedOut


recurseIntoModelReferences = true;
calledFromReducer = true;
ctrlVarsInfo = variantmanager( 'GetNamesAndValuesOfControlVariables',  ...
modelName, recurseIntoModelReferences, calledFromReducer );
end 
isDirty = java.lang.Boolean( isDirty );
isSLDVLicenseCheckedOut = java.lang.Boolean( isSLDVLicenseCheckedOut );
errMsg = java.lang.String( errMsg );
end 

function [ varControlVarsToBlocksMap, dataDictionary ] = i_translateRefModelVariableUsage( variableUsageInfo, rootPathPrefix )
varControlVarsToBlocksMap = containers.Map(  );
dataDictionary = variableUsageInfo.ControlVarToBlockUsageMap.keys;
dataDictionary = dataDictionary{ end  };
refModelControlVarToBlockUsageMap = variableUsageInfo.ControlVarToBlockUsageMap( dataDictionary );
refModelVarNames = refModelControlVarToBlockUsageMap.keys;
for i = 1:numel( refModelVarNames )
refModelBlockPath = refModelControlVarToBlockUsageMap( refModelVarNames{ i } );
usages = cell( 1, numel( refModelBlockPath ) );
for j = 1:numel( refModelBlockPath )
refModelBlockPathParts = Simulink.variant.utils.splitPathInHierarchy( refModelBlockPath{ j } );
rootModelPath = [ rootPathPrefix, '/', strjoin( refModelBlockPathParts( 2:end  ), '/' ) ];
usages{ j } = rootModelPath;
end 
varControlVarsToBlocksMap( refModelVarNames{ i } ) = usages;
end 
end 


function i_PushDefaultConfigToGlobalWS( rootModelName )
try 
varConfigData = Simulink.variant.utils.getConfigurationDataNoThrow( rootModelName );
if ~isempty( varConfigData )
defaultConfiguration = varConfigData.getDefaultConfiguration(  );
if ~isempty( defaultConfiguration )
if ~isfield( defaultConfiguration.ControlVariables, 'Source' )
for i = 1:numel( defaultConfiguration.ControlVariables )
defaultConfiguration.ControlVariables( i ).Source = get_param( rootModelName, 'DataDictionary' );
end 
end 


usedByDefaultConfig = true;
Simulink.variant.manager.configutils.pushControlVarsToGlobalOrTempWS( rootModelName, defaultConfiguration.Name, defaultConfiguration.ControlVariables, false, false, false, usedByDefaultConfig );
end 
end 
catch 
end 
end 



function [ validVars ] = checkVarNames( varNames )
validVars = ones( 1, length( varNames ) );
for index = 1:length( varNames )
splitVarName = regexp( varNames{ index }, '\.', 'split' );
isVarValid = cellfun( @isvarname, splitVarName );
if ~all( isVarValid )
validVars( index ) = 0;
end 
end 
end 

function [ topJavaRow, modelValidationResultsRows, isProtected, validationLog, refModelVariableUsage ] = i_GetLazyRow( optArgs, validationLog )
topJavaRow = [  ];
refModelVariableUsage = java.util.Hashtable;
refModelName = optArgs{ 2 };
optArgsStruct = struct( optArgs{ 3:end  } );


configurationName = optArgsStruct.ConfigurationName;
rootPathPrefix = optArgsStruct.RootPathPrefix;
ignoreErrors = optArgsStruct.IgnoreErrors;


isProtected = isvarname( refModelName ) && ~bdIsLoaded( refModelName ) && Simulink.variant.utils.getIsProtectedModelAndFullFile( refModelName );

subOptArgsStruct = struct(  );
if ~isempty( configurationName )

subOptArgsStruct.ConfigurationName = configurationName;
end 
subOptArgsStruct.HotlinkErrors = false;
subOptArgsStruct.CalledFromTool = true;
subOptArgsStruct.RootPathPrefix = rootPathPrefix;
subOptArgsStruct.IgnoreErrors = ignoreErrors;


subOptArgsStruct.RecurseIntoModelReferences = false;

[ validationErrorsForHierarchy, validationLog, createModelInfoLog ] = Simulink.variant.manager.configutils.validateModelEntry( refModelName, validationLog, subOptArgsStruct );

refModelValidationLog = validationLog( strcmp( refModelName, { validationLog(  ).Model } ) );

if isempty( refModelValidationLog )
refModelValidationLog = struct( 'Model', refModelName );
modelValidationResultsRows = i_convertToJavaValidationInfo( validationErrorsForHierarchy, refModelValidationLog, '', rootPathPrefix );
else 
variantConfigurationObjectName = get_param( refModelName, 'VariantConfigurationObject' );
modelValidationResultsRows = i_convertToJavaValidationInfo( validationErrorsForHierarchy, refModelValidationLog, variantConfigurationObjectName, rootPathPrefix );

topJavaRow = createModelInfoLog.TopRow.getJavaRow(  );
variantConfigurationObject = Simulink.variant.utils.getConfigurationDataNoThrow( refModelName );

if ~isempty( variantConfigurationObject ) && ( ~isempty( configurationName ) || ~isempty( variantConfigurationObject.DefaultConfigurationName ) )
if ~isempty( configurationName )
configUsedBySubmodel = configurationName;
else 
configUsedBySubmodel = variantConfigurationObject.DefaultConfigurationName;
end 
dataDictionary = get_param( refModelName, 'DataDictionary' );
try %#ok<TRYNC> % If the config does not exist in VCDO, this will result in error
validatedConfigMap = i_convertConfigToJavaObj( variantConfigurationObject.getConfiguration( configUsedBySubmodel ), dataDictionary );
topJavaRow.fHierarchyRow.setValidatedConfig( validatedConfigMap );
end 
end 
end 
end 


function [ topJavaRow, modelValidationResultsRow, variableUsage, validationLog ] = i_GetRefreshHierarchyData( optArgs )
rootModelName = optArgs{ 1 };
unsaved = optArgs{ 2 };
optArgsStruct = struct( optArgs{ 3:end  } );

variantConfigurationObject = i_convertJavaObjToVarConfigDataObj( optArgsStruct.VariantConfigDataObj );

if isfield( optArgsStruct, 'ControlVariables' )
controlVariables = i_convertJavaObjToSimpleStructs( optArgsStruct.( 'ControlVariables' ), { 'Name', 'Value', 'Source' } );
if ~isempty( controlVariables )
Simulink.variant.manager.configutils.pushControlVarsToGlobalOrTempWS( rootModelName, [  ], controlVariables, false, false, false, false );
end 
end 
configurationName = char( optArgsStruct.ConfigurationName );
ddSpec = get_param( rootModelName, 'DataDictionary' );
if ~isempty( ddSpec )


Simulink.dd.open( ddSpec );
end 

variantConfigurationObjectName = optArgsStruct.( 'VariantConfigurationObjectName' );
if unsaved && ~isempty( variantConfigurationObjectName )

variantConfigurationObjectName = strcat( variantConfigurationObjectName, '*' );
end 

subOptArgsStruct = struct(  );
subOptArgsStruct.ConfigurationName = configurationName;
subOptArgsStruct.HotlinkErrors = false;
subOptArgsStruct.CalledFromTool = true;
subOptArgsStruct.RecurseIntoModelReferences = false;
subOptArgsStruct.VariantConfigurationObject = variantConfigurationObject;
subOptArgsStruct.VariantConfigurationObjectName = variantConfigurationObjectName;

validationLog = [  ];
[ validationErrorsForHierarchy, validationLog, createModelInfoLog ] = Simulink.variant.manager.configutils.validateModelEntry( rootModelName, validationLog, subOptArgsStruct );

modelValidationResultsRow = i_convertToJavaValidationInfo( validationErrorsForHierarchy, validationLog, variantConfigurationObjectName, rootModelName );
variableUsage = java.util.Hashtable;
topJavaRow = createModelInfoLog.TopRow.getJavaRow(  );
end 


function i_EditVarConfigDataObj( objectHandle, frameHandle )

eqvVarConfigDataJavaObj = i_convertVarConfigDataObjToJavaObj( objectHandle, i_getGlobalWorkspaceName( objectHandle.DataDictionaryName ) );

javaMethodEDT( 'InitializeStandAlone', frameHandle,  ...
eqvVarConfigDataJavaObj, java.lang.String( objectHandle.DataDictionaryName ) );

awtinvoke( frameHandle, 'setVisible(Z)', true );
drawnow;
end 


function [ configObject, varConfigDataName ] = i_Export( optArgs )
rootModelName = optArgs{ 1 };
varConfigDataName = char( optArgs{ 2 } );
set_param( rootModelName, 'VariantConfigurationObject', varConfigDataName );
varConfigDataJavaObj = optArgs{ 3 };
configObject = i_convertJavaObjToVarConfigDataObj( varConfigDataJavaObj );
Simulink.variant.manager.configutils.saveFor( rootModelName, varConfigDataName, configObject );
end 



function [ hasCollision, collidingVars ] = i_ExportControlVars( optArgs )
hasCollision = false;
collidingVars = {  };
rootModelName = optArgs{ 1 };

controlVariables = i_convertJavaObjToSimpleStructs( optArgs{ 2 }, { 'Name', 'Value', 'Source' } );

if ~isempty( controlVariables )

[ hasCollision, collidingVars ] = Simulink.variant.manager.configutils.checkNameCollisions( controlVariables );
if ~hasCollision
pushToTempWorspace = false;reportErrors = false;skipAssigninGlobalWkspce = false;usedByDefaultConfig = false;
Simulink.variant.manager.configutils.pushControlVarsToGlobalOrTempWS( rootModelName, [  ], controlVariables,  ...
pushToTempWorspace, reportErrors, skipAssigninGlobalWkspce, usedByDefaultConfig );
end 
end 
end 


function [ configObject, objectName ] = i_Export_StandAlone( optArgs, DIALOG_USERDATA )
objectName = char( optArgs{ 1 } );
javaVarConfigDataObj = optArgs{ 2 };

configObject = i_convertJavaObjToVarConfigDataObj( javaVarConfigDataObj );

numEditors = length( DIALOG_USERDATA );
toolidx = [  ];
for idx = 1:numEditors
ed = DIALOG_USERDATA( idx );
if strcmp( objectName, ed.ObjectName )
toolidx = idx;
break ;
end 
end 



objectHandle = DIALOG_USERDATA( toolidx ).ObjectHandle;
objectHandle.setVariantConfigurations( configObject.VariantConfigurations );
objectHandle.setConstraints( configObject.Constraints );
objectHandle.setDefaultConfigurationName( configObject.DefaultConfigurationName );


if isempty( objectHandle.DataDictionaryName )
return ;
end 

ddConn = Simulink.dd.open( objectHandle.DataDictionaryName );
if ~ddConn.isOpen
return ;
end 



if isempty( objectHandle.DataDictionarySection )
objectHandle.DataDictionarySection = 'Configurations';
end 
ddConn.assignin( objectName, objectHandle, objectHandle.DataDictionarySection );
ddConn.close(  );
end 


function varargout = i_CheckVarConfigDataExistsForModel( optArgs )
rootModelName = optArgs{ 1 };
varConfigDataName = char( optArgs{ 2 } );
varConfigDataObject = [  ];
validName = isvarname( varConfigDataName );

if validName
[ varExists, varIsVarConfigDataObject, section ] =  ...
Simulink.variant.utils.existsVCDO( rootModelName, varConfigDataName );
if varExists
isScalarVarConfig = false;
if varIsVarConfigDataObject
isScalarVarConfig = Simulink.variant.utils.evalExpressionInSection(  ...
rootModelName, [ 'isscalar(', varConfigDataName, ') && ( ishandle(', varConfigDataName, ') || isvalid(', varConfigDataName, '))' ],  ...
section );
end 
varargout{ 2 } = java.lang.Boolean( true );
varargout{ 3 } = java.lang.Boolean( isScalarVarConfig );
if isScalarVarConfig
varConfigDataObject = Simulink.variant.utils.evalExpressionInSection(  ...
rootModelName, varConfigDataName, section );
end 
else 
varargout{ 2 } = java.lang.Boolean( false );
varargout{ 3 } = java.lang.Boolean( false );
end 
else 
varargout{ 2 } = java.lang.Boolean( false );
varargout{ 3 } = java.lang.Boolean( false );
end 
varargout{ 1 } = java.lang.Boolean( validName );
varargout{ 4 } = i_convertVarConfigDataObjToJavaObj( varConfigDataObject, i_getGlobalWorkspaceName( get_param( rootModelName, 'DataDictionary' ) ) );
end 


function i_ClearAssociation( optArgs )
rootModelName = optArgs{ 1 };



set_param( rootModelName, 'VariantConfigurationObject', '' );
end 


function varargout = i_GetUniqueKeyName( optArgs )
names = optArgs{ 2 };
exampleName = optArgs{ 3 };

generatedName = slvariants.internal.config.utils.generateName( exampleName, names );
varargout{ 1 } = generatedName;
end 




function varargout = i_getValueOfParamObjectUponConversionToNormalVar( optArgs )



modelorObjectName = optArgs{ 1 };
dataDictionary = optArgs{ 2 };
isStandAloneEditor = optArgs{ 3 };
ctrlVarValueAsHash = optArgs{ 4 };
value = ctrlVarValueAsHash.get( 'Value' );

if ~isStandAloneEditor
dataDictionary = get_param( modelorObjectName, 'DataDictionary' );
end 
if isempty( dataDictionary )
section = 'base';
else 
section = getSection( Simulink.data.dictionary.open( dataDictionary ), 'Design Data' );
end 




ctrlVarValue = value;
try 
if ctrlVarValueAsHash.containsKey( 'Parameter' )
ctrlVarValue = copy( handle( ctrlVarValueAsHash.get( 'Parameter' ) ) );
if strcmp( ctrlVarValue.DataType, 'auto' )
ctrlVarValue = value;
else 
if ( evalin( section, [ 'exist(''', ctrlVarValue.DataType, ''', ''var'')' ] ) == 1 ) &&  ...
evalin( section, [ 'isa(', ctrlVarValue.DataType, ', ''Simulink.AliasType'')' ] )
dataType = evalin( section, [ ctrlVarValue.DataType, '.BaseType' ] );
elseif ( evalin( section, [ 'exist(''', ctrlVarValue.DataType, ''', ''var'')' ] ) == 1 ) &&  ...
evalin( section, [ 'isa(', ctrlVarValue.DataType, ', ''Simulink.NumericType'')' ] )
dataType = lower( evalin( section, [ ctrlVarValue.DataType, '.DataTypeMode' ] ) );
else 
dataType = ctrlVarValue.DataType;
end 
if strcmp( dataType, 'boolean' )

dataType = 'logical';
end 
ctrlVarValue = i_num2str( cast( str2num( value ), dataType ) );%#ok<ST2NM> 
end 
end 
catch 
ctrlVarValue = value;
end 
ctrlVarValue = strtrim( ctrlVarValue );
if ( ( numel( ctrlVarValue ) > 0 ) && ( ctrlVarValue( 1 ) == '=' ) )
ctrlVarValue = ctrlVarValue( 2:end  );
end 
try 
ctrlVarInfoStruct = getCtrlVarInfoStruct(  );
ctrlVarInfoStruct.Value = ctrlVarValue;
isValidControlVarValue = slvariants.internal.config.utils.isValidControlVarValue2( ctrlVarInfoStruct );
if isValidControlVarValue
value = ctrlVarValue;
else 
value = i_num2str( evalin( section, ctrlVarValue ) );
end 
catch 
value = '0';
end 
varargout{ 1 } = value;
end 


function varargout = i_GetValueofControlVar( optArgs )
modelorObjectName = optArgs{ 1 };
dataDictionary = optArgs{ 2 };
isStandAloneEditor = optArgs{ 3 };
ctrlVar = optArgs{ 4 };
if ~isStandAloneEditor
dataDictionary = get_param( modelorObjectName, 'DataDictionary' );
end 
try 
if isempty( dataDictionary )
section = 'base';
else 
section = getSection( Simulink.data.dictionary.open( dataDictionary ), 'Design Data' );
end 
if isa( ctrlVar, 'Simulink.Parameter' )
value = ctrlVar.getPropValue( 'Value', false );
if ~isa( ctrlVar.Value, 'Simulink.data.Expression' )
value = num2str( evalin( section, value ) );
end 
elseif isa( ctrlVar, 'char' )
value = num2str( evalin( section, ctrlVar ) );
elseif isa( ctrlVar, 'Simulink.VariantControl' )



optArgs{ 4 } = ctrlVar.Value;
value = i_GetValueofControlVar( optArgs );
else 
value = num2str( evalin( section, num2str( ctrlVar ) ) );
end 
catch 
value = '0';
end 
varargout{ 1 } = value;
end 




function valueStr = i_num2str( value )
valueClass = class( value );
valueStr = num2str( value );
if ~isa( value, 'double' )
valueStr = [ valueClass, '(', valueStr, ')' ];
end 
end 


function varargout = i_GetCopyOfConfiguration( optArgs )
javaConfig = optArgs{ 2 };
configNames = optArgs{ 3 };

copyOfConfig = i_convertJavaObjToConfig( javaConfig );
copyOfConfig.Name = slvariants.internal.config.utils.generateName( copyOfConfig.Name, configNames );
varargout{ 1 } = i_convertConfigToJavaObj( copyOfConfig );
end 


function varargout = i_GetCopyOfControlVariable( optArgs )
javaControlVar = optArgs{ 2 };
controlVarNames = optArgs{ 3 };

copyOfControlVar = i_convertJavaObjToSimpleStructs( javaControlVar, { 'Name', 'Value', 'Source' } );
copyOfControlVar.Name = slvariants.internal.config.utils.generateName( copyOfControlVar.Name, controlVarNames );
copyOfControlVar = i_convertSimpleStructsToJavaObj( copyOfControlVar );
copyOfControlVar = copyOfControlVar.get( 0 );
varargout{ 1 } = copyOfControlVar;
end 


function varargout = i_SetBlockVariantControl( optArgs )
blockPath = optArgs{ 2 };
variantControl = char( optArgs{ 3 } );
parentModelName = optArgs{ 4 };
isVariantBlockWithIOPorts = optArgs{ 5 };
ioPortIndex = optArgs{ 6 };
rootModelBlockPath = optArgs{ 7 };
try 

if ~bdIsLoaded( parentModelName )
load_system( parentModelName );
end 
optArgs = Simulink.variant.utils.getControlVariableNamesFromVariantExpressionsOptArgs(  );
optArgs.CalledFromTool = true;
parentBlockPath = get_param( blockPath, 'Parent' );
if useParentBlockToDetermineVariableUsage( parentBlockPath )


varUsageBlockPath = parentBlockPath;
else 
varUsageBlockPath = blockPath;
end 
optArgs.DesiredVariableUsage = i_getDesiredVariableUsage( parentModelName, varUsageBlockPath, rootModelBlockPath );
varsBefore = Simulink.variant.utils.getControlVariableNamesFromVariantExpressions( varUsageBlockPath, optArgs );

[ handleSimCodegenMode, altVariantControl ] = i_handleSimCodegenMode( blockPath, parentBlockPath, variantControl );

if isVariantBlockWithIOPorts
val = get_param( blockPath, 'VariantControls' );
if handleSimCodegenMode
val = repmat( { altVariantControl }, size( val ) );
end 
val{ ioPortIndex } = variantControl;
set_param( blockPath, 'VariantControls', val );
else 
set_param( blockPath, 'VariantControl', variantControl )
if handleSimCodegenMode
variants = get_param( parentBlockPath, 'Variants' );
variants( strcmp( Simulink.variant.utils.replaceNewLinesWithSpaces( { variants.BlockName } ), blockPath ) ) = [  ];
cellfun( @( block )( set_param( block, 'VariantControl', altVariantControl ) ), { variants.BlockName } );
end 
end 
varsAfter = Simulink.variant.utils.getControlVariableNamesFromVariantExpressions( varUsageBlockPath, optArgs );
catch excep
varargout{ 1 } = java.lang.Boolean( true );
varargout{ 2 } = i_convertMExceptionHierarchyToMessageAndWrap( excep );
varargout{ 3 } = [  ];
varargout{ 4 } = [  ];
varargout{ 5 } = [  ];
varargout{ 6 } = [  ];
return ;
end 

[ varConditionToShow, isVarCondEditable ] = slInternal( 'getVariantControlInfoForVM', blockPath, variantControl );

varargout{ 1 } = java.lang.Boolean( false );
varargout{ 2 } = varConditionToShow;
varargout{ 3 } = java.lang.Boolean( isVarCondEditable );
[ varargout{ 4 }, varargout{ 5 } ] = i_getVariableUsageForRemovalAndAddition( parentModelName, get_param( parentModelName, 'DataDictionary' ), varsBefore, varsAfter, rootModelBlockPath );
varargout{ 6 } = variantControl;
end 



function useParentBlock = useParentBlockToDetermineVariableUsage( parentBlockPath )


useParentBlock = Simulink.variant.utils.isSingleChoiceVariantInfoBlock( parentBlockPath ) ||  ...
slInternal( 'isVariantSubsystem', get_param( parentBlockPath, 'handle' ) );
end 


function varargout = i_SetVariantSFTransitionControl( optArgs )
blockPath = optArgs{ 2 };
variantControl = char( optArgs{ 3 } );
parentModelName = optArgs{ 4 };
rootModelBlockPath = optArgs{ 5 };
vTransId = str2double( optArgs{ 6 } );
try 

if ~bdIsLoaded( parentModelName )
load_system( parentModelName );
end 
cvOptArgs = Simulink.variant.utils.getControlVariableNamesFromVariantExpressionsOptArgs(  );
cvOptArgs.CalledFromTool = true;
cvOptArgs.DesiredVariableUsage = i_getDesiredVariableUsage( parentModelName, blockPath, rootModelBlockPath );
varsBefore = Simulink.variant.utils.getControlVariableNamesFromVariantExpressions( blockPath, cvOptArgs );


variantControl = Stateflow.Variants.VariantMgr.setVariantTransitionCondExpr( vTransId, variantControl );

varsAfter = Simulink.variant.utils.getControlVariableNamesFromVariantExpressions( blockPath, cvOptArgs );
catch excep
varargout{ 1 } = java.lang.Boolean( true );
varargout{ 2 } = i_convertMExceptionHierarchyToMessageAndWrap( excep );
varargout{ 3 } = [  ];
varargout{ 4 } = [  ];
varargout{ 5 } = [  ];
varargout{ 6 } = [  ];
return ;
end 

[ varConditionToShow, isVarCondEditable ] = slInternal( 'getVariantControlInfoForVM', blockPath, variantControl );

varargout{ 1 } = java.lang.Boolean( false );
varargout{ 2 } = varConditionToShow;
varargout{ 3 } = java.lang.Boolean( isVarCondEditable );
[ varargout{ 4 }, varargout{ 5 } ] = i_getVariableUsageForRemovalAndAddition( parentModelName, get_param( parentModelName, 'DataDictionary' ), varsBefore, varsAfter, rootModelBlockPath );
varargout{ 6 } = variantControl;

end 


function varargout = i_SetVariantCondition( optArgs )
blockPath = char( optArgs{ 2 } );
parentModelName = char( optArgs{ 3 } );
rootModelBlockPath = char( optArgs{ 4 } );
varObjName = char( optArgs{ 5 } );
varCond = char( optArgs{ 6 } );
isCChart = optArgs{ 7 };
otherLangVarCond = varCond;%#ok<NASGU>
try 

if ~bdIsLoaded( parentModelName )
load_system( parentModelName );
end 
subOptArgs = Simulink.variant.utils.getControlVariableNamesFromVariantExpressionsOptArgs(  );
subOptArgs.CalledFromTool = true;
parentBlockPath = get_param( blockPath, 'Parent' );
if useParentBlockToDetermineVariableUsage( parentBlockPath )


varUsageBlockPath = parentBlockPath;
else 
varUsageBlockPath = blockPath;
end 
subOptArgs.DesiredVariableUsage = i_getDesiredVariableUsage( parentModelName, varUsageBlockPath, rootModelBlockPath );
varsBefore = Simulink.variant.utils.getControlVariableNamesFromVariantExpressions( varUsageBlockPath, subOptArgs );

if isCChart
varCond = slInternal( 'ConvertExprBetweenMandC', varCond, false, true );
otherLangVarCond = varCond;
else 
otherLangVarCond = slInternal( 'ConvertExprBetweenMandC', varCond, true, false );
end 




varCond = regexprep( varCond, '''', '''''' );
varCreateExpr = [ varObjName, ' = Simulink.Variant(''', varCond, ''')' ];
evalinGlobalScope( parentModelName, varCreateExpr );
subOptArgs.SpecialVarsInfoManagerMap = containers.Map(  );
varsAfter = Simulink.variant.utils.getControlVariableNamesFromVariantExpressions( varUsageBlockPath, subOptArgs );
catch excep
varargout{ 1 } = java.lang.Boolean( false );
varargout{ 2 } = java.lang.String( i_convertMExceptionHierarchyToMessageAndWrap( excep ) );
varargout{ 3 } = [  ];
varargout{ 4 } = [  ];
varargout{ 5 } = [  ];
return ;
end 
varargout{ 1 } = java.lang.Boolean( true );
varargout{ 2 } = [  ];
[ varargout{ 3 }, varargout{ 4 } ] = i_getVariableUsageForRemovalAndAddition( parentModelName, get_param( parentModelName, 'DataDictionary' ), varsBefore, varsAfter, rootModelBlockPath );
varargout{ 5 } = otherLangVarCond;
end 


function varargout = i_SetActiveLabelChoice( optArgs )
blockPath = char( optArgs{ 2 } );
parentModelName = char( optArgs{ 3 } );
varControl = char( optArgs{ 4 } );

try 

if ~bdIsLoaded( parentModelName )
load_system( parentModelName );
end 
set_param( blockPath, 'LabelModeActiveChoice', varControl );
catch excep
varargout{ 1 } = java.lang.Boolean( false );
varargout{ 2 } = java.lang.String( i_convertMExceptionHierarchyToMessageAndWrap( excep ) );
return ;
end 

varargout{ 1 } = java.lang.Boolean( true );
varargout{ 2 } = [  ];
end 


function varargout = i_OpenBlockParameters( optArgs )
blockPath = char( optArgs{ 2 } );
parentModelName = char( optArgs{ 3 } );
try 

if ~bdIsLoaded( parentModelName )
load_system( parentModelName );
end 
open_system( blockPath, 'parameter' );
catch excep
varargout{ 1 } = java.lang.Boolean( false );
varargout{ 2 } = java.lang.String( i_convertMExceptionHierarchyToMessageAndWrap( excep ) );
return ;
end 
varargout{ 1 } = java.lang.Boolean( true );
varargout{ 2 } = [  ];
end 


function varargout = i_OpenChartParameters( optArgs )
blockPath = char( optArgs{ 2 } );
parentModelName = char( optArgs{ 3 } );
try 

if ~bdIsLoaded( parentModelName )
load_system( parentModelName );
end 
chartObj = Simulink.variant.utils.getSFObj( blockPath,  ...
Simulink.variant.utils.StateflowObjectType.CHART );
if ~isempty( chartObj )
DAStudio.Dialog( chartObj );
end 
catch excep
varargout{ 1 } = java.lang.Boolean( false );
varargout{ 2 } = java.lang.String( i_convertMExceptionHierarchyToMessageAndWrap( excep ) );
return ;
end 
varargout{ 1 } = java.lang.Boolean( true );
varargout{ 2 } = [  ];
end 


function varargout = i_GetNamesAndValuesOfControlVariables( optArgs, frameHandle )





rootModelName = char( optArgs{ 1 } );
recurseIntoModelReferences = optArgs{ 2 };
calledFromReducer = optArgs{ 3 };


rOptsStruct = struct(  ...
'Verbose', false,  ...
'UIFrameHandle', frameHandle,  ...
'CalledFromUI', true );
verboseInfoObj = Simulink.variant.utils.VerboseInfoHandler( rOptsStruct );


optArgs = Simulink.variant.utils.getControlVariableNamesFromVariantExpressionsOptArgs(  );
optArgs.CalledFromTool = true;optArgs.RecurseIntoModelReferences = recurseIntoModelReferences;
optArgs.VerboseInfoObject = verboseInfoObj;
[ varNames, variableUsageInfo, sourceInfo, errs ] = Simulink.variant.utils.getControlVariableNamesFromVariantExpressions(  ...
rootModelName, optArgs );
variableUsage = java.util.Hashtable;
ctrlVarsInfo = i_GetValuesOfControlVariables( varNames, calledFromReducer, sourceInfo, variableUsageInfo );
varargout{ 1 } = ctrlVarsInfo;
varargout{ 2 } = variableUsage;
if ~calledFromReducer
warningMessages = java.util.Vector;
for i = 1:numel( errs )
warningMessages.add( java.lang.String( i_convertMExceptionHierarchyToMessageAndWrap( errs{ i } ) ) );
end 
varargout{ 3 } = warningMessages;
end 
end 

function usageTable = i_convertMapToTable( modelName, ctrlVarUsageMaps, varNames, modelsToVarsMap )

VariableUsageClass = @com.mathworks.toolbox.simulink.variantmanager.VariableUsage;

usageTable = java.util.Hashtable;
modelsUsingVar = ctrlVarUsageMaps.keys;
for modelIdx = 1:numel( modelsUsingVar )
dataDictionary = modelsUsingVar{ modelIdx };
ctrlVarUsageMap = ctrlVarUsageMaps( dataDictionary );
ctrlVars = ctrlVarUsageMap.keys;


for j = 1:numel( ctrlVars )
blockUsages = ctrlVarUsageMap( ctrlVars{ j } );
ctrlVarUsagesSetDirect = java.util.TreeSet;
for k = 1:numel( blockUsages )
blockUsages{ k } = Simulink.variant.utils.replaceNewLinesWithSpaces( blockUsages{ k } );
ctrlVarUsagesSetDirect.add( VariableUsageClass(  ...
Simulink.variant.utils.splitPathInHierarchy( blockUsages{ k } ) ) );
end 
allDataSources = i_getAllSourcesForDD( modelName, dataDictionary );
for sourceIdx = 1:numel( allDataSources )




ctrlVarNameWithSource = java.lang.String( Simulink.variant.utils.getControlVarNameWithSource(  ...
ctrlVars{ j }, i_getGlobalWorkspaceName( allDataSources{ sourceIdx } ) ) );
ctrlVarUsagesSet = java.util.TreeSet;
ctrlVarUsagesSet.addAll( ctrlVarUsagesSetDirect );


currentUsagesSet = usageTable.get( ctrlVarNameWithSource );
if ~isempty( currentUsagesSet )
ctrlVarUsagesSet.addAll( currentUsagesSet );
end 
usageTable.put( ctrlVarNameWithSource, ctrlVarUsagesSet );
end 
end 
end 

if nargin == 2



return ;
end 

for varNameIdx = 1:numel( varNames )



modelsUsingVar = modelsToVarsMap.keys(  );




usagesFromDDModelsWithNoWeakRefToBwks = {  };
for modelIdx = 1:numel( modelsUsingVar )
dataDictionary = get_param( modelsUsingVar{ modelIdx }, 'DataDictionary' );
if ~isempty( dataDictionary )
if any( strcmp( varNames{ varNameIdx }, modelsToVarsMap( modelsUsingVar{ modelIdx } ) ) )
if ~Simulink.data.dictionary.open( dataDictionary ).HasAccessToBaseWorkspace
ctrlVarUsageMap = ctrlVarUsageMaps( dataDictionary );
if ctrlVarUsageMap.isKey( varNames{ varNameIdx } )
usagesFromDDModelsWithNoWeakRefToBwks = [ usagesFromDDModelsWithNoWeakRefToBwks, ctrlVarUsageMap( varNames{ varNameIdx } ) ];%#ok<AGROW>
end 
end 
end 
end 
end 



if ~isempty( usagesFromDDModelsWithNoWeakRefToBwks )
ddmodelsWithUsages = unique( cellfun( @( X )( X{ 1 } ), Simulink.variant.utils.splitPathInHierarchy( usagesFromDDModelsWithNoWeakRefToBwks ), 'UniformOutput', false ) );
ddmodelsWithUsagesAndBWSAccess = ddmodelsWithUsages( strcmp( get_param( ddmodelsWithUsages, 'EnableAccessToBaseWorkspace' ), 'on' ) );
usagesFromDDModelsWithAccessToBaseWorkspaceThroughParam = {  };
for modelIdx = 1:numel( ddmodelsWithUsagesAndBWSAccess )


usagesFromDDModelsWithAccessToBaseWorkspaceThroughParam = [ usagesFromDDModelsWithAccessToBaseWorkspaceThroughParam, usagesFromDDModelsWithNoWeakRefToBwks( startsWith( usagesFromDDModelsWithNoWeakRefToBwks, [ ddmodelsWithUsages{ modelIdx }, '/' ] ) ) ];%#ok<AGROW>
end 
ctrlVarUsagesSet = java.util.TreeSet;
for usageIdx = 1:numel( usagesFromDDModelsWithAccessToBaseWorkspaceThroughParam )
usagesFromDDModelsWithAccessToBaseWorkspaceThroughParam{ usageIdx } = Simulink.variant.utils.replaceNewLinesWithSpaces( usagesFromDDModelsWithAccessToBaseWorkspaceThroughParam{ usageIdx } );%#ok<AGROW>
ctrlVarUsagesSet.add( VariableUsageClass(  ...
Simulink.variant.utils.splitPathInHierarchy( usagesFromDDModelsWithAccessToBaseWorkspaceThroughParam{ usageIdx } ) ) );
end 
ctrlVarNameWithSource = java.lang.String( Simulink.variant.utils.getControlVarNameWithSource(  ...
varNames{ varNameIdx }, i_getGlobalWorkspaceName( '' ) ) );
usageTable.put( ctrlVarNameWithSource, ctrlVarUsagesSet );
end 
end 
end 



function allSources = i_getAllSourcesForDD( modelName, dataDictionaryName )
allReferencedDataDictionaries = Simulink.variant.utils.slddaccess.getAllReferencedDataDictionaries( modelName );
allSources = [ { dataDictionaryName };allReferencedDataDictionaries' ];
if ~isempty( dataDictionaryName )
if Simulink.data.dictionary.open( dataDictionaryName ).HasAccessToBaseWorkspace


allSources = [ allSources;{ '' } ];
end 
end 
end 


function ctrlVarsInfo = i_GetValuesOfControlVariables( varNames, calledFromReducer, sourceInfo, variableUsageInfo )





ctrlVarsInfo = java.util.Vector;
namesSourcesMap = containers.Map;

varsToModelsMap = Simulink.variant.utils.i_invertMap( sourceInfo.ModelsToVarsMap );
for varIdx = 1:numel( varNames )
name = varNames{ varIdx };
modelsUsingVar = varsToModelsMap( name );
for modelIdx = 1:numel( modelsUsingVar )
modelName = modelsUsingVar{ modelIdx };
specialVarsInfoManager = sourceInfo.SpecialVarsInfoManagerMap( modelName );
try %#ok<TRYNC>


ctrlVarInfo = java.util.Hashtable;
ctrlVarInfo.put( 'Name', java.lang.String( name ) );
source = get_param( modelName, 'DataDictionary' );
found = false;
acceptable = false;
if specialVarsInfoManager.getIsSimulinkVariantObject( name )
valToReturn = '0';
found = true;
else 
acceptable = true;
if ( ~contains( name, '.' ) && specialVarsInfoManager.getIsVariable( name ) ) || ( Simulink.variant.utils.existsVarInSourceWSOf( modelName, name ) )
found = true;
if contains( name, '.' )
val = Simulink.variant.utils.slddaccess.evalExpressionInGlobalScope( modelName, name );
else 
val = specialVarsInfoManager.getVariableValue( name );
end 
if calledFromReducer

val = i_GetValueofControlVar( [ { modelName }, { '' }, { false }, { val } ] );
valToReturn = ii_convertM2JavaVarValue( val, false );
else 
if contains( name, '.' )
outerVarName = strsplit( name, '.' );
outerVarName = outerVarName{ 1 };
else 
outerVarName = name;
end 
source = specialVarsInfoManager.getVariableSource( outerVarName );
valToReturn = ii_convertM2JavaVarValue( val, true );
end 
if isa( valToReturn, 'java.lang.String' )
ctrlVarInfoStruct = getCtrlVarInfoStruct(  );
ctrlVarInfoStruct.Value = char( valToReturn );
ctrlVarInfoStruct.IsParamValueExpression = specialVarsInfoManager.getIsExpValueSimulinkParameter( name );
acceptable = ctrlVarInfoStruct.IsParamValueExpression || slvariants.internal.config.utils.isValidControlVarValue2( ctrlVarInfoStruct );
if ~acceptable
valToReturn = '0';
end 
end 
else 
if any( strcmp( variableUsageInfo.ControlVarsFromParams, name ) )


valToReturn = ii_convertM2JavaVarValue( Simulink.VariantControl( Value = 0 ), true );
else 
valToReturn = '0';
end 
end 
end 
if ~( namesSourcesMap.isKey( name ) && any( strcmp( namesSourcesMap( name ), source ) ) )





Simulink.variant.utils.i_addKeyValueToMap( namesSourcesMap, name, { source } );
ctrlVarInfo.put( 'Source', java.lang.String( i_getGlobalWorkspaceName( source ) ) );
ctrlVarInfo.put( 'Value', valToReturn );
ctrlVarInfo.put( 'Acceptable', java.lang.Boolean( acceptable ) );
ctrlVarInfo.put( 'Found', java.lang.Boolean( found ) );
ctrlVarsInfo.add( ctrlVarInfo );
end 
end 
end 
end 
end 


function varargout = i_GetConfigurationsInVCDOForModel( optArgs )
modelName = optArgs{ 2 };
configNames = {  };
try 

isModelLoaded = bdIsLoaded( modelName );
if ~isModelLoaded
load_system( modelName );
end 
vc = Simulink.variant.utils.getConfigurationDataNoThrow( modelName );
if ~isempty( vc )
configNames = { vc.VariantConfigurations( : ).Name };
end 
catch excep %#ok
end 

varargout{ 1 } = configNames;
end 


function varargout = i_GetListOfVarConfigDataObjNamesForModel( optArgs )
rootModelName = optArgs{ 1 };
configDataObjectNames = {  };
try %#ok<TRYNC>
configDataObjectNames = i_getConfigDataObjectNames( rootModelName );
end 
varargout{ 1 } = configDataObjectNames;
end 

function configDataObjectNames = i_getConfigDataObjectNames( rootModelName )
configDataObjectNames = {  };
try %#ok<TRYNC>
allVarsInConfigurationsScope = evalinConfigurationsScope( rootModelName, 'whos' );
configDataObjectIndices = arrayfun( @( var )( isscalar( var ) && strcmp( var.class, 'Simulink.VariantConfigurationData' ) ), allVarsInConfigurationsScope );
configDataObjectVars = allVarsInConfigurationsScope( logical( configDataObjectIndices ) );
configDataObjectNames = arrayfun( @( var )( var.name ), configDataObjectVars, 'UniformOutput', false );




end 
end 


function data = i_Unhilite( data, frameHandle )

numHiliteData = length( data );
for idx = 1:numHiliteData
if data( idx ).FrameHandle == frameHandle
try %#ok<TRYNC>
if ~isempty( data( idx ).BlockPath )
blockPathAllLevels = data( idx ).BlockPath.convertToCell(  );


if all( cellfun( @( blockPath )( getSimulinkBlockHandle( blockPath ) ), blockPathAllLevels ) >  - 1 )


hilite_system( data( idx ).BlockPath, 'none' );
else 
for i = 1:numel( blockPathAllLevels )
if getSimulinkBlockHandle( blockPathAllLevels{ i } ) >  - 1


hilite_system( blockPathAllLevels{ i }, 'none' );
end 
end 
end 
highlightedBlock = blockPathAllLevels{ end  };
if getSimulinkBlockHandle( highlightedBlock ) >  - 1
set_param( highlightedBlock, 'Selected', 'off' );
end 
elseif ~isempty( data( idx ).ParentSFChartId )
sf( 'Highlight', data( idx ).ParentSFChartId, [  ] );
end 
end 
data( idx ) = [  ];
end 
end 
end 


function i_ReportException( optArgs, DIALOG_USERDATA )
try 
objectName = optArgs{ 1 };
if isempty( objectName )
objectName = '';
end 
message = optArgs{ 2 };


toolidx = find( strcmp( objectName, { DIALOG_USERDATA( : ).ObjectName } ), 1 );

if ~isempty( toolidx )
frameHandle = DIALOG_USERDATA( toolidx ).FrameHandle;

awtinvoke( frameHandle, 'show()' );
javaMethodEDT( 'HandleExceptionFromMCallback', frameHandle, objectName, message );

awtinvoke( frameHandle, 'setVisible(Z)', true );
drawnow;
end 
catch 
end 
end 


function objHashTable = i_convertVarConfigDataObjToJavaObj( varConfigDataObj, defaultDataSource )
objHashTable = java.util.Hashtable;

if exist( 'defaultDataSource', 'var' ) == 0
defaultDataSource = '';
end 


if ~exist( 'varConfigDataObj', 'var' ) || isempty( varConfigDataObj )
return ;
end 

numConfigurations = length( varConfigDataObj.VariantConfigurations );
configHashtables = java.util.Vector;
for i = 1:numConfigurations
config = varConfigDataObj.VariantConfigurations( i );
configHashtables.addElement( i_convertConfigToJavaObj( config, defaultDataSource ) );
end 
if ~isempty( varConfigDataObj.DefaultConfigurationName )
objHashTable.put( 'DefaultConfigurationName', java.lang.String( varConfigDataObj.DefaultConfigurationName ) );
end 
objHashTable.put( 'VariantConfigurations', configHashtables );
objHashTable.put( 'Constraints', i_convertSimpleStructsToJavaObj( varConfigDataObj.Constraints ) );
objHashTable.put( 'DataDictionaryName', java.lang.String( varConfigDataObj.DataDictionaryName ) );
end 


function varConfigDataObj = i_convertJavaObjToVarConfigDataObj( hashtable )
configHashtables = hashtable.get( 'VariantConfigurations' );
numConfigurations = configHashtables.size;
configs = [  ];
for i = 1:numConfigurations
javaConfig = configHashtables.elementAt( i - 1 );

if isempty( configs )
configs = i_convertJavaObjToConfig( javaConfig );
else 
configs( end  + 1 ) = i_convertJavaObjToConfig( javaConfig );%#ok
end 
end 


varConfigDataObj = Simulink.VariantConfigurationData( configs,  ...
i_convertJavaObjToSimpleStructs( hashtable.get( 'Constraints' ), { 'Name', 'Condition', 'Description' } ),  ...
hashtable.get( 'DefaultConfigurationName' ) );
varConfigDataObj.DataDictionaryName = hashtable.get( 'DataDictionaryName' );
end 


function objHashTable = i_convertConfigToJavaObj( config, defaultDataSource )

if exist( 'defaultDataSource', 'var' ) == 0
defaultDataSource = '';
end 

objHashTable = java.util.Hashtable;
objHashTable.put( 'Name', java.lang.String( config.Name ) );
if ~isempty( config.Description )
objHashTable.put( 'Description', java.lang.String( config.Description ) );
end 

for i = 1:numel( config.ControlVariables )
if ~isfield( config.ControlVariables( i ), 'Source' ) || isempty( config.ControlVariables( i ).Source )
config.ControlVariables( i ).Source = defaultDataSource;
elseif strcmp( config.ControlVariables( i ).Source, slvariants.internal.config.utils.getGlobalWorkspaceName_R2020b( '' ) )
config.ControlVariables( i ).Source = slvariants.internal.config.utils.getGlobalWorkspaceName( '' );
end 
end 
objHashTable.put( 'ControlVariables', i_convertSimpleStructsToJavaObj( config.ControlVariables ) );
objHashTable.put( 'SubModelConfigurations', i_convertSimpleStructsToJavaObj( config.SubModelConfigurations ) );
end 


function configuration = i_convertJavaObjToConfig( hashtable )
configuration = [  ];
configuration.Name = char( hashtable.get( 'Name' ) );
configuration.Description = char( hashtable.get( 'Description' ) );
configuration.ControlVariables = i_convertJavaObjToSimpleStructs( hashtable.get( 'ControlVariables' ), { 'Name', 'Value', 'Source' } );
configuration.SubModelConfigurations = i_convertJavaObjToSimpleStructs( hashtable.get( 'SubModelConfigurations' ), { 'ModelName', 'ConfigurationName' } );
end 


function value = ii_convertM2JavaVarValue( v, considerAllTypes )
if isa( v, 'Simulink.VariantControl' )
subObjHashTable = java.util.Hashtable;
subObjHashTable.put( 'IsSimulinkVariantControl', true );
subObjHashTable.put( 'ActivationTime', java.lang.String( v.ActivationTime ) );
if isa( v.Value, 'Simulink.Parameter' )


isEditMode = false;
val = java.lang.String( v.Value.getPropValue( 'Value', isEditMode ) );
subObjHashTable.put( 'IsParameterValue', true );
v = v.Value.java;
v.acquireReference;
subObjHashTable.put( 'Parameter', v );
elseif Simulink.data.isSupportedEnumObject( v.Value )
val = java.lang.String( DAStudio.MxStringConversion.convertToString( v.Value ) );
else 


val = java.lang.String( i_num2str( v.Value ) );
end 
subObjHashTable.put( 'Value', val );
value = subObjHashTable;
elseif isa( v, 'Simulink.Parameter' )
isEditMode = false;
val = java.lang.String( v.getPropValue( 'Value', isEditMode ) );
subObjHashTable = java.util.Hashtable;
subObjHashTable.put( 'Value', val );



subObjHashTable.put( 'IsParamValueExpression', isa( v.Value, 'Simulink.data.Expression' ) );
if isa( v, 'AUTOSAR.Parameter' )
subObjHashTable.put( 'IsAUTOSARParam', true );
end 
v = v.java;
v.acquireReference;
subObjHashTable.put( 'Parameter', v );

value = subObjHashTable;
elseif Simulink.data.isSupportedEnumObject( v )
value = java.lang.String( DAStudio.MxStringConversion.convertToString( v ) );
else 
if considerAllTypes




value = java.lang.String( DAStudio.MxStringConversion.convertToString( v ) );
elseif isa( v, 'char' ) || isstring( v )
value = java.lang.String( v );
else 
value = java.lang.String( DAStudio.MxStringConversion.convertToString( v ) );
end 
end 
end 


function nameValuePair = getNameValuePairFromHashtable( jVal )
ctrlVarNames = jVal.keySet.toArray;
nameValuePair = {  };
for i = 1:numel( ctrlVarNames )
nameValuePair{ end  + 1 } = char( ctrlVarNames( i ) );%#ok<AGROW>
valueStr = strtrim( jVal.get( java.lang.String( ctrlVarNames( i ) ) ) );
isParamValueExpression = numel( valueStr ) > 0 && ( valueStr( 1 ) == '=' );
if isParamValueExpression
varValueTobeChecked = valueStr( 2:end  );
nameValuePair{ end  + 1 } = Simulink.Parameter( slexpr( varValueTobeChecked ) );%#ok<AGROW>
else 
nameValuePair{ end  + 1 } = str2num( jVal.get( java.lang.String( ctrlVarNames( i ) ) ) );%#ok<AGROW,ST2NM>
end 
end 
end 


function variableGroups = getVariableGroups( jVal )

nameIdx = 0;variantControlsIdx = 1;
numVariableGroups = numel( jVal );
variableGroups = struct( 'Name', {  }, 'VariantControls', {  } );
for i = 1:numVariableGroups
variableGroups( i ).Name = jVal{ i }.get( nameIdx );
variableGroups( i ).VariantControls = getNameValuePairFromHashtable( jVal{ i }.get( variantControlsIdx ) );
end 
end 


function mVal = ii_convertJava2MValue( jVal )
if isa( jVal, 'java.util.Hashtable' )
isSimulinkVariantControl = jVal.containsKey( 'IsSimulinkVariantControl' );
hasParamData = jVal.containsKey( 'Parameter' );
isParam = hasParamData ||  ...
( jVal.containsKey( 'IsParameterValue' ) && jVal.get( 'IsParameterValue' ) );
isParamValueExpression = isParam && jVal.containsKey( 'IsParamValueExpression' ) &&  ...
jVal.get( 'IsParamValueExpression' );



if isSimulinkVariantControl
mVal = Simulink.VariantControl;

mVal.ActivationTime = char( jVal.get( 'ActivationTime' ) );
elseif hasParamData
jmVal = jVal.get( 'Parameter' );
assert( ~handle( jmVal ).CoderInfo.HasContext, 'Expected base workspace object only' );
mVal = copy( handle( jmVal ) );
else 
mVal = Simulink.Parameter;
end 

vStr = char( jVal.get( 'Value' ) );
if isSimulinkVariantControl && hasParamData
jmPrmVal = jVal.get( 'Parameter' );
assert( ~handle( jmPrmVal ).CoderInfo.HasContext, 'Expected base workspace object only' );
mPrmVal = copy( handle( jmPrmVal ) );
mVal.Value = mPrmVal;
if isParamValueExpression
vStr = vStr( 1 + find( vStr == '=', 1 ):end  );
valueSetStr = [ 'mVal.Value.Value = slexpr(''', vStr, ''');' ];
else 
valueSetStr = [ 'mVal.Value.Value = ', vStr, ';' ];
end 
elseif isSimulinkVariantControl &&  ...
isParam && ~hasParamData
mVal = Simulink.VariantControl;
mVal.ActivationTime = char( jVal.get( 'ActivationTime' ) );
mVal.Value = Simulink.Parameter;
if isParamValueExpression
vStr = vStr( 1 + find( vStr == '=', 1 ):end  );
valueSetStr = [ 'mVal.Value.Value = slexpr(''', vStr, ''');' ];
else 
valueSetStr = [ 'mVal.Value.Value = ', vStr, ';' ];
end 
elseif isParamValueExpression



vStr = vStr( 1 + find( vStr == '=', 1 ):end  );
valueSetStr = [ 'mVal.Value = slexpr(''', vStr, ''');' ];
else 
valueSetStr = [ 'mVal.Value = ', vStr, ';' ];
end 
try 
eval( valueSetStr );
catch 
end 
else 

mVal = char( jVal );
end 
end 


function eqvStructs = i_convertSimpleStructsToJavaObj( structs )
eqvStructs = java.util.Vector;
if ~isempty( structs )
numElems = length( structs );
fieldNames = fieldnames( struct( structs ) );
for s = 1:numElems
objHashTable = java.util.Hashtable;
tempStruct = structs( s );
for i = 1:length( fieldNames )
fieldVal = ii_convertM2JavaVarValue( tempStruct.( fieldNames{ i } ), false );

if ~isempty( fieldVal )
objHashTable.put( fieldNames{ i }, fieldVal );
end 
end 
eqvStructs.addElement( objHashTable );
end 
end 
end 


function structs = i_convertJavaObjToSimpleStructs( objs, fields )
structs = [  ];
if ~isempty( objs )
if isa( objs, 'java.util.Hashtable' )
numElems = 1;
isSingleHashObject = true;
else 
numElems = objs.size;
isSingleHashObject = false;
end 
for s = 1:numElems
if isSingleHashObject
objHashtable = objs;
else 
objHashtable = objs.elementAt( s - 1 );
end 
numKeys = length( fields );
str = [  ];
for i = 1:numKeys
key = fields{ i };
try 
str.( key ) = ii_convertJava2MValue( objHashtable.get( key ) );
catch excep
rethrow( excep );
end 
end 
if isempty( structs )
structs = str;
else 
structs( end  + 1 ) = str;%#ok
end 
end 
end 
end 




function errorType = i_convertString2ErrorType( str )

if any( strcmp( str, { 'Model', 'Configuration', 'ControlVariable', 'SubModelConfiguration', 'Constraint' } ) )
errorType = com.mathworks.toolbox.simulink.variantmanager.ErrorType.( str );
else 
errorType = com.mathworks.toolbox.simulink.variantmanager.ErrorType.Uncategorized;
end 
end 


function modelValidationResultsRow = i_convertToJavaValidationInfo( validationErrorsForHierarchy, validationLog, varConfigDataName, modelPathInHierarchy )

validationLog = validationLog( end  );

modelName = validationLog.Model;
valid = ~any( strcmp( modelName, cellfun( @( X )( X.Model ), validationErrorsForHierarchy, 'UniformOutput', false ) ) );

if isfield( validationLog, 'Configuration' )
if isempty( validationLog.Configuration )
configName = '';
else 
configName = validationLog.Configuration.( 'Name' );
end 

if isempty( configName )
configName = i_getGlobalWorkspaceLabel( validationLog.DataDictionary );
end 

if ~( isempty( varConfigDataName ) || isempty( configName ) )
configName = strcat( configName, [ ' in ''', varConfigDataName, '''' ] );
end 

modelValidationResultsRow = com.mathworks.toolbox.simulink.variantmanager.ModelValidationHeaderRow( modelName, valid,  ...
configName, validationLog.DataDictionary, Simulink.variant.utils.splitPathInHierarchy( modelPathInHierarchy ), modelPathInHierarchy );
else 
modelValidationResultsRow = com.mathworks.toolbox.simulink.variantmanager.ModelValidationHeaderRow( modelName, valid,  ...
'', '', Simulink.variant.utils.splitPathInHierarchy( modelPathInHierarchy ), modelPathInHierarchy );
end 


numModelElems = length( validationErrorsForHierarchy );

for mi = 1:numModelElems
modelErrorsData = validationErrorsForHierarchy{ mi };
modelName = modelErrorsData.Model;
modelErrors = modelErrorsData.Errors;
numModelErrors = length( modelErrors );

for ei = 1:numModelErrors
e = modelErrors{ ei };
errMessage = strtrim( i_removeHL( Simulink.variant.utils.i_convertMExceptionHierarchyToMessage( e.Exception ) ) );
if isfield( e, 'PathInModel' )

pathInModel = e.PathInModel;
pathInHierarchy = Simulink.variant.utils.splitPathInHierarchy( e.PathInHierarchy );
pathWithoutModelName = pathInModel( length( modelName ) + 2:end  );
childRow = com.mathworks.toolbox.simulink.variantmanager.ErrorRowChildBlock( pathWithoutModelName, errMessage, pathInHierarchy );
elseif isfield( e, 'Type' )
javaErrType = i_convertString2ErrorType( e.Type );
if strcmp( e.Type, 'Model' )
pathInHierarchy = Simulink.variant.utils.splitPathInHierarchy( e.PathInHierarchy );
childRow = com.mathworks.toolbox.simulink.variantmanager.ErrorRowChildOtherModel( errMessage, javaErrType, '', pathInHierarchy );
else 
if isfield( e, 'SourceConfiguration' ) && ~isempty( e.SourceConfiguration )
childRow = com.mathworks.toolbox.simulink.variantmanager.ErrorRowChildOtherConfiguration( errMessage, javaErrType, e.Source,  ...
e.SourceConfiguration, e.SourceModel );
else 
childRow = com.mathworks.toolbox.simulink.variantmanager.ErrorRowChildOther( errMessage, javaErrType, e.Source );
end 
end 
else 

childRow = com.mathworks.toolbox.simulink.variantmanager.ErrorRowChildOther( errMessage );
end 
modelValidationResultsRow.addErrorRow( childRow );
end 
end 
end 


function i_checkJavaAvailability

if ~usejava( 'swing' )
error( message( 'Simulink:dialog:VariantManagerToolNeedsJava' ) );
end 
end 



function i_openTopModelorBlockinSameStudio( blockPathOrBlockPathObject )
if isa( blockPathOrBlockPathObject, 'Simulink.BlockPath' )
blockPathOrBlockPathObject.open( 'force', 'on' );
else 

open_system( blockPathOrBlockPathObject );
end 
end 


function [ tool_exists, frameHandle, idx ] = i_checkToolExistance( bdHandle, DIALOG_USERDATA )
tool_exists = false;
frameHandle = [  ];
idx = [  ];
bdHandleClass = class( bdHandle );
if ~isempty( DIALOG_USERDATA )
idx = [  ];



for ii = 1:length( DIALOG_USERDATA )
if ( isa( DIALOG_USERDATA( ii ).ObjectHandle, bdHandleClass ) &&  ...
DIALOG_USERDATA( ii ).ObjectHandle == bdHandle )
idx = ii;
break ;
end 
end 
if ~isempty( idx )
frameHandle = DIALOG_USERDATA( idx ).FrameHandle;
tool_exists = true;
end 
end 
end 


function [ handleSimCodegenMode, altVariantControl ] = i_handleSimCodegenMode( blockPath, parentBlockPath, variantControl )








handleSimCodegenMode = ( slInternal( 'isVariantSubsystem', get_param( parentBlockPath, 'handle' ) ) &&  ...
strcmp( get_param( parentBlockPath, 'VariantControlMode' ), 'sim codegen switching' ) ) ||  ...
( any( strcmp( get_param( blockPath, 'BlockType' ), { 'VariantSource', 'VariantSink' } ) ) &&  ...
strcmp( get_param( blockPath, 'VariantControlMode' ), 'sim codegen switching' ) );
altVariantControl = [  ];
if handleSimCodegenMode
if strcmp( variantControl, Simulink.variant.keywords.getSimVariantKeyword(  ) )
altVariantControl = Simulink.variant.keywords.getCodegenVariantKeyword(  );
elseif strcmp( variantControl, Simulink.variant.keywords.getCodegenVariantKeyword(  ) )
altVariantControl = Simulink.variant.keywords.getSimVariantKeyword(  );
else 
handleSimCodegenMode = false;
end 
end 
end 


function [ dir, ext ] = i_getModelExtension( model )
fileName = get_param( model, 'FileName' );
[ dir, ~, ext ] = fileparts( fileName );
end 




function [ successFailureMessage, warningMessage, reducerCommand ] = i_reduceModelAndCollateOutput( modelName, pvArgs )
[ errorMsg, warningMsg, reducerCommand ] = i_reduceModel( modelName, pvArgs );
[ successFailureMessage, warningMessage ] = i_collateReducerOutput( errorMsg, warningMsg );
end 



function [ errorMsg, warnings, reducerCommand ] = i_reduceModel( modelName, pvArgs )
reducerCommand = java.lang.String( '' );
warnings = [  ];
errId = 'Simulink:VariantManagerUI:VariantReducerPromptUnhandledexception';
errorMsg = MException( errId, getString( message( errId ) ) );%#ok<NASGU>
try 


[ ~, errorMsg, warnings, reducerCommand ] = Simulink.VariantManager.reduceModel( modelName, pvArgs{ : } );
catch errorMsg
end 
end 




function [ successFailureMessage, warningMessage ] = i_collateReducerOutput( errorMsg, warningMsgs )

success = isempty( errorMsg );
status = num2str( success );
if isempty( errorMsg )
failureMessageHeader = {  };
else 
failureMessageHeader = { i_removeHL( errorMsg.message ) };
end 



failureMessageDetails = {  };
if ~success
ifCauseExists = isprop( errorMsg, 'cause' );


if ( ifCauseExists && ~isempty( errorMsg.cause ) )
failureMessageDetails = cell( 1, numel( errorMsg.cause ) );
for i = 1:numel( errorMsg.cause )
cause = errorMsg.cause{ i };
failureMessageDetails{ 1, i } = i_convertMExceptionHierarchyToMessage( cause );
end 
end 
end 
successFailureMessage = [ status, failureMessageHeader, failureMessageDetails ];

warningMessage = cell( 1, numel( warningMsgs ) );

for ii = 1:numel( warningMsgs )


warningMessage{ ii } = i_convertMExceptionHierarchyToMessage( warningMsgs{ ii } );
end 
end 


function isValid = isValidCrtlValueFun( str )
str = strtrim( str );
isParamValueExpression = numel( str ) > 0 && ( str( 1 ) == '=' );
ctrlVarInfoStruct = getCtrlVarInfoStruct(  );
if isParamValueExpression
ctrlVarInfoStruct.IsParamValueExpression = true;
ctrlVarInfoStruct.IsParam = true;
try 
varValueTobeChecked = str( 2:end  );
ctrlVarInfoStruct.Value = varValueTobeChecked;
isValid = slvariants.internal.config.utils.isValidControlVarValue2( ctrlVarInfoStruct );
catch 
isValid = false;
end 
else 


ctrlVarValue = str2num( str );%#ok<ST2NM>
isValid = Simulink.variant.reducer.utils.isValidControlVariableValue( ctrlVarValue );
end 
end 




function [ ddConn, excep ] = i_openDataDictionary( ddSpec, frameHandle, killTool )



ddConn = [  ];
excep = [  ];
try 
ddConn = Simulink.dd.open( ddSpec );
catch excep
if isa( excep, 'MSLException' ) && strncmp( excep.identifier, 'SLDD:sldd:', length( 'SLDD:sldd:' ) )
javaMethodEDT( 'HandleHardErrors', frameHandle, java.lang.String( i_convertMExceptionHierarchyToMessageAndWrap( excep ) ), java.lang.Boolean( killTool ) );
end 
end 
end 



function msgWrapped = i_wrapMessage( msg )
msgWrapped = i_removeHL( msg );






msgWrapped = matlab.internal.display.printWrapped( msgWrapped, 75 );
end 





function msg = i_convertMExceptionHierarchyToMessageAndWrap( excep )
msg = i_wrapMessage( Simulink.variant.utils.i_convertMExceptionHierarchyToMessage( excep ) );
end 







function [ isSLDVLicenseCheckedOut, errMsg ] = i_getLicenseCheckoutInfo(  )
[ isSLDVLicenseCheckedOut, err ] = slvariants.internal.utils.getSLDVLicenseCheckoutInfo(  );
if isSLDVLicenseCheckedOut
errMsg = '';
else 
errMsg = i_convertMExceptionHierarchyToMessage( err );
end 
end 




function msg = i_convertMExceptionHierarchyToMessage( excep )
msg = i_removeHL( Simulink.variant.utils.i_convertMExceptionHierarchyToMessage( excep ) );
end 





function desiredVariableUsage = i_getDesiredVariableUsage( parentModelName, blockPath, rootModelBlockPath )
blockPathsParentModelParts = Simulink.variant.utils.splitPathInHierarchy( blockPath );
blockPathRootModelParts = Simulink.variant.utils.splitPathInHierarchy( rootModelBlockPath );
desiredVariableUsage = strjoin( [ parentModelName, blockPathRootModelParts( end  - numel( blockPathsParentModelParts ) + 1:end  ) ], '/' );
end 





function [ variableUsageForRemoval, variableUsageForAddition ] = i_getVariableUsageForRemovalAndAddition( modelName, dataDictionary, varsBefore, varsAfter, blockPathRootModel )

removedCtrlVars = setdiff( varsBefore, varsAfter );
addedCtrlVars = setdiff( varsAfter, varsBefore );

removedCtrlVarsUsageMap = containers.Map;
removedCtrlVarsToBlocksMap = containers.Map;
for i = 1:numel( removedCtrlVars )
removedCtrlVarsToBlocksMap( removedCtrlVars{ i } ) = { blockPathRootModel };
end 
addedCtrlVarsUsageMap = containers.Map;
addedCtrlVarsToBlocksMap = containers.Map;
for i = 1:numel( addedCtrlVars )
addedCtrlVarsToBlocksMap( addedCtrlVars{ i } ) = { blockPathRootModel };
end 
addedCtrlVarsUsageMap( dataDictionary ) = addedCtrlVarsToBlocksMap;
removedCtrlVarsUsageMap( dataDictionary ) = removedCtrlVarsToBlocksMap;
variableUsageForRemoval = i_convertMapToTable( modelName, removedCtrlVarsUsageMap );
variableUsageForAddition = i_convertMapToTable( modelName, addedCtrlVarsUsageMap );
end 



function msgNoHotLinks = i_removeHL( msg )
msgNoHotLinks = slprivate( 'removeHyperLinksFromMessage', msg );
end 



function globalWksLabel = i_getGlobalWorkspaceLabel( dataDictionary )
if isempty( dataDictionary )
globalWksLabel = 'Base workspace';
else 
globalWksLabel = dataDictionary;
end 
end 



function globalWksName = i_getGlobalWorkspaceName( dataDictionary )
globalWksName = slvariants.internal.config.utils.getGlobalWorkspaceName( dataDictionary );
end 




function [ variantConfigurationObjectNamesInFile, variantConfigurationObjectsInFile, errMessage ] = i_extractVCDOFromMatlabScript( fileName )
errMessage = '';
variantConfigurationObjectNamesInFile = {  };
variantConfigurationObjectsInFile = {  };

[ ~, tempVarName ] = fileparts( tempname );
eval( [ tempVarName, '= fileName;' ] );
tempFileName = eval( tempVarName );

try 
run( fileName );
variablesInMFileStruct = whos;
variantConfigurationObjectIndices = strcmp( { variablesInMFileStruct.class }, 'Simulink.VariantConfigurationData' );
variantConfigurationObjectNamesInFile = { variablesInMFileStruct( variantConfigurationObjectIndices ).name };
for i = 1:numel( variantConfigurationObjectNamesInFile )

variantConfigurationObjectsInFile{ end  + 1 } = eval( variantConfigurationObjectNamesInFile{ i } );%#ok<AGROW>
end 
catch ME
msg = message( 'Simulink:Variants:VariantManagerImportVCDOSyntaxErrors', tempFileName, i_convertMExceptionHierarchyToMessage( ME ) );
errMessage = msg.getString(  );
end 
end 




function ctrlVarInfo = getCtrlVarInfoStruct(  )
ctrlVarInfo = struct( 'Value', [  ], 'IsParam', false,  ...
'IsParamValueExpression', false, 'IsAUTOSARParam', false,  ...
'IsSimulinkVariantControl', false );
end 







% Decoded using De-pcode utility v1.2 from file /tmp/tmpPJmsqs.p.
% Please follow local copyright laws when handling this file.

