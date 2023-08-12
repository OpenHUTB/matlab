classdef JSProjectService < handle




events 
OpenProject
CloseProject
end 

properties ( Access = private )
mIdToFilePath = containers.Map( 'KeyType', 'char', 'ValueType', 'char' );
mFilePathToId = containers.Map( 'KeyType', 'char', 'ValueType', 'char' );
end 

properties ( SetAccess = private, GetAccess = public )
currentProject = [  ];
metricTemplate = fullfile( matlabroot, 'toolbox', 'experiments', 'dl_templates', 'experiments', '+experiments', '+internal', '+experimentTemplates', 'templates', 'template_createNewMetricFunction.m' );
defaultSetupTemplate = fullfile( matlabroot, 'toolbox', 'experiments', 'dl_templates', 'experiments', '+experiments', '+internal', '+experimentTemplates', 'templates', 'template_blankSetupFunction.m' );
defaultTrainingTemplate = fullfile( matlabroot, 'toolbox', 'experiments', 'templates', 'template_blankTrainingFunction.m' );
end 

methods 

function this = JSProjectService(  )
this.addlistener( 'AddToProject',  ...
@( ~, evtData )this.currentProject.addFileToProject( evtData.data ) );
this.addlistener( 'RemoveFromProject',  ...
@( ~, evtData )this.currentProject.removeFileOrFolderFromProject( evtData.data ) );
end 

end 





methods 
function out = prjCreate( this, prjPath )
prj = this.constructNewProject( prjPath );
out = this.setCurrentProject( prj );
end 

function prjNotifyImportSuccess( this, isSuccessful )


importHandler = this.setGetImportHandler(  );
if isSuccessful
importHandler.Status = 'Successful';
else 
importHandler.Status = 'Failed';
end 
end 

function out = prjOpen( this, fullPath )
import experiments.internal.*;
[ prjRootFolder, prjFilePath ] = JSProjectService.getCurrentProjectPath(  );
if strcmp( prjRootFolder, fullPath ) || strcmp( prjFilePath, fullPath )


prj = experiments.internal.Project.createFromCurrentProject(  );
else 
cleanupKeepInFront = this.keepInFront(  );
prj = experiments.internal.Project.open( fullPath );
delete( cleanupKeepInFront );
end 

out = this.setCurrentProject( prj );




prj.addPath( this.currentProject.rootDir );
end 

function prjClose( this )
this.closeCurrentProject(  );
end 

function out = expCreateDefaultName( this, template, parentFolderPath )
[ ~, ~, path ] = getUniqueName( fullfile( parentFolderPath, 'Experiment' ), '.mat' );
out = this.createNewExperiment( template, path, {  } );
end 

function out = expCreate( this, expTemplate, path )
out = this.createNewExperiment( expTemplate, path, {  } );
end 

function out = expCreateForExport( this, path )
exportedData = this.setGetImportHandler(  );
template = exportedData.Data{ 1 };
SourceTemplateFuncContent = this.copyAndGenerateMLXFile( template.HelperFunctions, template.SourceTemplate );
out = this.createNewExperiment( template, path, SourceTemplateFuncContent );
end 

function out = expCreateSetupFunction( this, expName )


out = this.createNewSetupFunction( expName, this.defaultSetupTemplate );


this.addToProjectTree( out.treeInfo );
end 

function out = expCreateTrainingFunction( this, expName )


out = this.createNewTrainingFunction( expName, this.defaultTrainingTemplate );


this.addToProjectTree( out.treeInfo );
end 

function expCreateMetricFunction( this, metricName, createFile )



if ~isvarname( metricName )
error( message( 'experiments:editor:InvalidMatlabIdentifier', metricName ) );
end 
if ~createFile
return ;
end 
this.checkProjectLoaded(  );
prj = this.currentProject;
newFileName = [ prj.rootDir, filesep, metricName, '.mlx' ];

if ~isfile( newFileName )
this.createMLXFile( newFileName, this.metricTemplate, metricName );
end 


prj.addFileToProject( newFileName );
end 

function experiment = expLoad( this, fileName )
prj = this.currentProject;
assert( ~isempty( prj ) );


if ~prj.isLoaded(  )
[ ~, name, ~ ] = fileparts( prj.rootDir );
error( message( 'experiments:editor:CannotLoadExperiment', name ) );
end 

assert( this.isValidExperimentFile( fileName ), 'Did not find a valid experiment file' );
experiment = this.loadExperimentFile( fileName );
end 

function out = expCreateDuplicate( this, expId )
import experiments.internal.*;
prj = this.currentProject;

expDef = matfile( this.prjGetFilePathById( expId ) ).Experiment;

[ name, nameWithExt ] = this.getUniqueExpName( fullfile( prj.rootDir, expDef.Name ), '.mat', "Copy_of_", "" );
expDef.Name = name;
expDef = JSProjectService.updateExpDefForClone( expDef );
prj.saveExperiment( expDef, nameWithExt );

out.expDef = expDef;
out.treeInfo = this.getSubTreeInfo( prj, nameWithExt );
end 

function id = expGetFileIdandPathMap( this, path )
try 
id = this.mFilePathToId( path );
catch 
id = "";
end 
end 

function path = prjGetFilePathById( this, id )
path = this.mIdToFilePath( id );
end 

function expSave( this, expDef, path )
prj = this.currentProject;
assert( ~isempty( prj ) );


if ~prj.isLoaded(  )
[ ~, name, ~ ] = fileparts( prj.rootDir );
error( message( 'experiments:editor:CannotSaveExperiment', name ) );
end 

if ( isempty( path ) )
filePath = this.mIdToFilePath( expDef.ExperimentId );



assert( startsWith( filePath, prj.rootDir ), 'Experiment not in the current open project' );
else 
filePath = path;



if ~( startsWith( filePath, prj.rootDir ) )
error( message( 'experiments:editor:CannotSaveExperimentNotInsideProject' ) );
end 
end 
prj.saveExperiment( expDef, filePath );
end 


function res = prjGetDefaultFullPathForPrj( ~ )



defaultDir = matlab.internal.project.util.getDefaultProjectFolder;
[ path, name ] = getUniqueName( fullfile( defaultDir, 'TrainNetworkProject' ), '', 'dir' );
res = fullfile( path, name );
end 

function res = prjGetValidFileNameForDir( ~, dir, name, ext )
[ ~, ~, res ] = getUniqueName( fullfile( dir, name ), ext );
end 





function res = prjGetProjectOpenLocation( ~, currentProjectRoot )
import experiments.internal.*;
[ prjFolder, prjFilePath ] = JSProjectService.getCurrentProjectPath(  );
if strcmp( prjFolder, currentProjectRoot )
res = '';
else 
res = prjFilePath;
end 
end 



function prjDeleteFileorFolder( this, fullPathOfArtifact )
prj = this.currentProject;
try 
treeInfo = this.getSubTreeInfo( this.currentProject, fullPathOfArtifact );

prj.removeFileOrFolderFromProject( fullPathOfArtifact );

if ( isfolder( fullPathOfArtifact ) )

rmdir( fullPathOfArtifact, 's' );
else 

delete( fullPathOfArtifact );
end 
for idx = 1:length( treeInfo )
this.removeFromIdMaps( treeInfo( idx ).path );
end 
catch ME
errME = MException( message( 'experiments:project:DeleteOperationError' ) );
errME = errME.addCause( ME );
throw( errME );
end 
end 

function out = prjRename( this, origPath, newLabel )
if strcmp( origPath, this.currentProject.rootDir )
error( message( 'experiments:project:CannotRenameProjectRoot' ) );
end 
parentDir = fileparts( origPath );

[ ~, origLabel, origExt ] = fileparts( origPath );
[ ~, namePart, newExt ] = fileparts( newLabel );

if ~isempty( newExt )
if ~strcmp( origExt, newExt )
warning( message( 'experiments:project:ExtensionAdjusted', origExt ) );
newLabel = [ namePart, origExt ];
end 
newPath = fullfile( parentDir, newLabel );
else 
newPath = fullfile( parentDir, [ newLabel, origExt ] );
end 

if exist( newPath, 'file' )
if this.isValidExperimentFile( newPath )
errME = MException( message( 'experiments:project:ExperimentAlreadyExists', newLabel, newPath ) );
else 
errME = MException( message( 'experiments:project:FileFolderAlreadyExists', newPath ) );
end 
throw( errME );
end 

try 
out = this.moveFileOrFolder( origPath, newPath );
catch Mex
errME = MException( message( 'experiments:project:RenameOperationError', origLabel, newLabel, Mex.message ) );
throw( errME );
end 
out.newLabel = newLabel;
out.name = namePart;
out.newPath = newPath;
end 

function prjOpenFile( this, path )
import matlab.internal.lang.capability.Capability
assert( ~isfolder( path ) );
escapedPath = strrep( path, "'", "''" );



if ismac
commandwindow(  );
end 
if ~Capability.isSupported( Capability.LocalClient )
this.cef.minimize(  );
end 
evalin( "base", "uiopen('" + escapedPath + "',1)" );
end 

function prjSyncProjectChanges( this, projectTreeInfo )
this.syncProjectChanges( projectTreeInfo );
end 

function checkProjectLoaded( this )
if isempty( this.currentProject ) || ~this.currentProject.isLoaded(  )
errorMex = MException( message( 'experiments:project:ProjectNotLoaded' ) );
throw( errorMex );
end 
end 
end 

methods ( Access = private )
function out = setCurrentProject( this, prj )
assert( ~isempty( prj ) );
this.currentProject = prj;

parentDir = fileparts( prj.rootDir );
this.notify( 'OpenProject',  ...
experiments.internal.ExpMgrEventData( prj.rootDir ) );
this.mIdToFilePath( '0' ) = parentDir;
this.mFilePathToId( parentDir ) = '0';

out.treeInfo = this.getSubTreeInfo( prj, prj.rootDir );
out.rootId = out.treeInfo( 1 ).id;
out.projectRootPath = prj.rootDir;
end 

function prj = constructNewProject( this, prjDir )
[ ~, prjName ] = fileparts( prjDir );
cleanupKeepInFront = this.keepInFront(  );
prj = experiments.internal.Project.create( prjDir, prjName );
delete( cleanupKeepInFront );
end 

function closeCurrentProject( this )
if ~isempty( this.currentProject )
this.mIdToFilePath.remove( this.mIdToFilePath.keys );
this.mFilePathToId.remove( this.mFilePathToId.keys );
this.notify( 'CloseProject' );
cleanupKeepInFront = this.keepInFront(  );
this.currentProject.delete(  );
delete( cleanupKeepInFront );
this.currentProject = [  ];
this.emit( 'clearCurrentProject' );
end 
end 

function addToProjectTree( this, treeInfo )
this.emit( 'addToProjectTree', treeInfo );
end 

function [ isValid, expType ] = isValidExperimentFile( ~, filepath )




isValid = false;
expType = '';
[ ~, ~, ext ] = fileparts( filepath );
if strcmp( ext, '.mat' )
mf = matfile( filepath );
members = whos( mf );
if length( members ) == 1 &&  ...
strcmp( members.name, 'Experiment' ) &&  ...
strcmp( members.class, 'experiments.internal.Experiment' )
isValid = true;
expDef = mf.Experiment;
expType = expDef.Process.Type;
end 
end 
end 

function expDef = loadExperimentFile( ~, filepath )
mf = matfile( filepath );
expDef = mf.Experiment;
end 

function out = createNewExperiment( this, expTemplate, path, templateFuncContent )
if nargin < 4
templateFuncContent = '';
end 
this.checkProjectLoaded(  );












[ filedir, filename, fileext ] = fileparts( path );
filedir = builtin( '_canonicalizepath', filedir );
path = fullfile( filedir, strcat( filename, fileext ) );
if isfolder( path )
folderPath = path;
[ ~, ~, fileName ] = getUniqueName( fullfile( path, 'Experiment' ), '.mat' );
else 
folderPath = fileparts( path );
fileName = path;
end 

if ~( exist( folderPath, 'file' ) &&  ...
startsWith( folderPath, builtin( '_canonicalizepath', this.currentProject.rootDir ) ) )
mex = MException( message( 'experiments:project:LocationOutsideProjectError' ) );
throw( mex );
end 

prj = this.currentProject;
expDef = experiments.internal.Experiment( expTemplate, fileName );
if ~isempty( templateFuncContent )
sourceTemplate = templateFuncContent;
else 
sourceTemplate = expDef.SourceTemplate;
end 

switch ( expDef.Process.Type )
case 'StandardTraining'
fcnOut = this.createNewSetupFunction( expDef.Name, sourceTemplate );
expDef.Process.SetupFcn = fcnOut.FunctionName;
case 'CustomTraining'
fcnOut = this.createNewTrainingFunction( expDef.Name, sourceTemplate );
expDef.Process.TrainingFcn = fcnOut.FunctionName;
end 

out.expDef = expDef;
prj.saveExperiment( expDef, fileName );
out.treeInfo = [ this.getSubTreeInfo( prj, fileName );fcnOut.treeInfo ];
out.rootId = out.treeInfo( 1 ).id;
end 

function out = createNewSetupFunction( this, expName, srcTemplate )
this.checkProjectLoaded(  );





[ ~, newSetupFcnName, newSetupFilePath ] = getUniqueName( fullfile( this.currentProject.rootDir, strcat( expName, '_setup' ) ), '.mlx' );
[ newSetupFcnName, newSetupFilePath ] = this.createMLXFile( newSetupFilePath, srcTemplate, newSetupFcnName, 'CreateMFile', experiments.internal.View.feature.createMFiles );
this.currentProject.addFileToProject( newSetupFilePath );

out.treeInfo = this.getSubTreeInfo( this.currentProject, newSetupFilePath );
out.FunctionName = newSetupFcnName;

end 

function out = createNewTrainingFunction( this, expName, trainingTemplate )
this.checkProjectLoaded(  );





[ ~, newFcnName, newFcnFilePath ] = getUniqueName( fullfile( this.currentProject.rootDir, strcat( expName, '_training' ) ), '.mlx' );
[ newFcnName, newFcnFilePath ] = this.createMLXFile( newFcnFilePath, trainingTemplate, newFcnName, 'CreateMFile', experiments.internal.View.feature.createMFiles );

this.currentProject.addFileToProject( newFcnFilePath );
out.treeInfo = this.getSubTreeInfo( this.currentProject, newFcnFilePath );
out.FunctionName = newFcnName;

end 

function sourceExpTemplate = copyAndGenerateMLXFile( this, helperFcns, sourceExpTemplate )
if ~isempty( helperFcns )
this.checkProjectLoaded(  );
helperFcnMap = containers.Map;

for k = keys( helperFcns )
oldHelperFunc = k{ 1 };
[ ~, oldHelperFuncName, ext ] = fileparts( oldHelperFunc );
[ ~, newHelperFcnName, newHelperFcnFilePath ] = getUniqueName( fullfile( this.currentProject.rootDir, oldHelperFuncName ), ext );
newHelperFcnData = struct( 'newHelperFunctionName', newHelperFcnName, 'newHelperFunctionPath', newHelperFcnFilePath );
helperFcnMap( oldHelperFuncName ) = newHelperFcnData;
end 

origHelperFuncNames = string( helperFcnMap.keys );


newHelperFuncStruct = helperFcnMap.values;
newHelperFuncStruct = vertcat( newHelperFuncStruct{ : } );
newHelperFuncNames = convertCharsToStrings( { newHelperFuncStruct.newHelperFunctionName } );
for k = keys( helperFcns )
origFcnName = k{ 1 };
origHelperFunStr = helperFcns( origFcnName );
if isstring( origHelperFunStr )
replacedHelperFunStr = regexprep( origHelperFunStr, origHelperFuncNames, newHelperFuncNames );

helperFcns( origFcnName ) = replacedHelperFunStr;
end 
end 
sourceExpTemplate = regexprep( sourceExpTemplate, origHelperFuncNames, newHelperFuncNames );


for k = keys( helperFcns )
[ ~, origFcnNameKey, ~ ] = fileparts( k{ 1 } );
if isstruct( helperFcns( k{ 1 } ) )
newHelperFilePath = helperFcnMap( origFcnNameKey ).newHelperFunctionPath;
matfileContent = helperFcns( k{ 1 } );
try 
save( newHelperFilePath, '-struct', 'matfileContent', '-v7.3' );
catch ME
errME = MException( message( 'experiments:manager:ML_INT_ErrorMsgCreateExp' ) );
errME = errME.addCause( ME );
throw( errME );
end 
else 
[ ~, newHelperFilePath ] = this.createMLXFile( helperFcnMap( origFcnNameKey ).newHelperFunctionPath, helperFcns( k{ 1 } ), helperFcnMap( origFcnNameKey ).newHelperFunctionName, 'CreateSupportingFile', true );
end 
this.currentProject.addFileToProject( newHelperFilePath );
end 

delete( helperFcnMap );
end 

end 

function out = moveFileOrFolder( this, sourcePathArtifact, destinationPathArtifact )
this.checkProjectLoaded(  );
prj = this.currentProject;



treeInfo = this.getSubTreeInfo( this.currentProject, sourcePathArtifact );
if isfolder( destinationPathArtifact )

pathPrefixToRemove = fileparts( sourcePathArtifact );
else 

pathPrefixToRemove = sourcePathArtifact;
end 



prj.removeFileOrFolderFromProject( sourcePathArtifact );

[ status, errMsg, errMsgId ] = movefile( sourcePathArtifact, destinationPathArtifact );

if status == 0
if exist( sourcePathArtifact, 'file' )


prj.addFileToProject( sourcePathArtifact );
end 
errME = MException( errMsgId, errMsg );
throw( errME );
end 

treeInfo = this.restoreSubtreeProjectStatusAfterMove( treeInfo,  ...
pathPrefixToRemove, destinationPathArtifact );

prj.updateDependencies(  );
out.treeInfo = treeInfo;
out.rootId = treeInfo( 1 ).id;
end 

function id = getIdForFile( this, fullPath )
if isKey( this.mFilePathToId, fullPath )
id = this.mFilePathToId( fullPath );
else 
if this.isValidExperimentFile( fullPath )


id = this.getExperimentFileId( fullPath );
elseif isfolder( fullPath ) && startsWith( fullPath, fullfile( this.currentProject.rootDir, 'Results' ) )



id = fullPath;
else 
id = char( matlab.lang.internal.uuid(  ) );
end 

this.updateMapWithNewValue( fullPath, id );
end 
end 

function id = getExperimentFileId( ~, fullPath )
exp = matfile( fullPath ).Experiment;
id = exp.ExperimentId;
end 

function removeFromIdMaps( this, fullPath )
id = this.mFilePathToId( fullPath );
this.mFilePathToId.remove( fullPath );
this.mIdToFilePath.remove( id );
end 

function updateMapForId( this, id, newPath )
oldPath = this.mIdToFilePath( id );
this.mIdToFilePath( id ) = newPath;
this.mFilePathToId.remove( oldPath );
this.mFilePathToId( newPath ) = id;
end 

function updateMapWithNewValue( this, fileName, expId )
this.mIdToFilePath( expId ) = fileName;
this.mFilePathToId( fileName ) = expId;
end 

function treeInfo = restoreSubtreeProjectStatusAfterMove( this, treeInfo,  ...
pathPrefixToRemove, destinationPathArtifact )
this.checkProjectLoaded(  );
prj = this.currentProject;
for idx = 1:length( treeInfo )
subPath = treeInfo( idx ).path( length( pathPrefixToRemove ) + 1:end  );
newPath = [ destinationPathArtifact, subPath ];


prj.addFileToProject( newPath );

if treeInfo( idx ).isDirectory &&  ...
treeInfo( idx ).inProjectPath
prj.addPath( newPath );
end 

if strcmp( treeInfo( idx ).type, 'Experiment' )

expDef = this.loadExperimentFile( newPath );

[ ~, expDef.Name ] = fileparts( newPath );
prj.saveExperiment( expDef, newPath )
end 
id = treeInfo( idx ).id;
this.updateMapForId( id, newPath );
treeInfo( idx ).path = newPath;
end 
end 
treeInfo = getSubTreeInfo( this, prj, rootDir );
cleanup = keepInFront( this );
syncProjectChanges( this, projectTreeInfo );
end 

methods ( Static )
function [ newName, fullPath ] = getUniqueExpName( baseFileName, ext, prefix, attempt )
[ path, name ] = fileparts( baseFileName );
newName = strcat( prefix, name );

fullPath = strcat( path, filesep, newName, ext );

if exist( fullPath, 'file' )
if attempt == ""
attempt = 2;
else 
attempt = str2double( attempt ) + 1;
end 
newPrefix = strcat( "Copy_", num2str( attempt ), "_of_" );
[ newName, fullPath ] = experiments.internal.JSProjectService.getUniqueExpName( baseFileName, ext, newPrefix, num2str( attempt ) );
end 
end 

function out = setGetImportHandler( obj )
persistent importHandler;
if nargin
importHandler = obj;
end 
out = importHandler;
end 

function expDef = updateExpDefForClone( expDef )




expDef.ExperimentId = char( matlab.lang.internal.uuid(  ) );
end 


function [ rootFolderPath, prjFilePath ] = getCurrentProjectPath(  )
rootFolderPath = '';
prjFilePath = '';
try 
p = currentProject;
catch 

return ;
end 
if exist( p.RootFolder, 'dir' )
rootFolderPath = char( p.RootFolder );


f = dir( fullfile( rootFolderPath, '*.prj' ) );
prjFilePath = fullfile( rootFolderPath, f.name );
end 
end 

function [ fcnName, dstFilePath ] = createMLXFile( dstFilePath, srcFile, fcnName, options )
R36
dstFilePath char{ mustBeTextScalar }
srcFile string{ mustBeTextScalar }
fcnName char{ mustBeTextScalar }
options.CreateMFile( 1, 1 )logical = false
options.CreateSupportingFile( 1, 1 )logical = false
end 
tmpFileName = tempname;
fid = fopen( fullfile( tmpFileName ), 'w' );
cleanup = onCleanup( @(  )delete( tmpFileName ) );
if ~isempty( srcFile )
if isfile( srcFile )
fileText = fileread( srcFile );
else 
fileText = srcFile;
end 
dstFileContent = strrep( fileText, '{functionName}', fcnName );
fprintf( fid, '%s', dstFileContent );
end 
fclose( fid );
if options.CreateMFile
[ ~, fcnName, dstFilePath ] = getUniqueName( regexprep( dstFilePath, '\d*\.mlx$', '' ), '.m' );
copyfile( tmpFileName, dstFilePath );
elseif options.CreateSupportingFile
copyfile( tmpFileName, dstFilePath );
else 
matlab.internal.liveeditor.openAndSave( tmpFileName, dstFilePath );
end 
end 
end 
end 

function [ path, name, nameWithExt ] = getUniqueName( baseFileName, ext, type )
if nargin < 3
type = 'file';
end 

baseFileName = char( baseFileName );
attempt = 1;
uniqueFileName = strcat( baseFileName, num2str( attempt ) );

while exist( [ uniqueFileName, ext ], type )
attempt = attempt + 1;
uniqueFileName = strcat( baseFileName, num2str( attempt ) );
end 
[ path, name ] = fileparts( uniqueFileName );
nameWithExt = [ uniqueFileName, ext ];
end 





% Decoded using De-pcode utility v1.2 from file /tmp/tmpcdHKa5.p.
% Please follow local copyright laws when handling this file.

