classdef AppGenerator




properties 
modelName
opts = [  ];
appDir;
modelImage = '';
inputMatFileName = '';
slObjPrmsToRestore = [  ];
end 

properties ( Access = private )
TemplateType = 'Old'
TemplatePrefix = '@';
end 

properties ( Hidden )
ModelDataSvc
SignalLoggingUtilities
ModelChecker
ModelConditioner
end 

properties ( Constant, Access = private )
AppUtilsPkgName = "+AppUtils"
end 

methods 

function obj = AppGenerator( modelName, options )
R36
modelName( 1, 1 )string{ mustBeValidModelName }
options.AppName( 1, 1 )string = baseModelName( modelName ) + "_SLSimApp"
options.Template( 1, 1 )string = "MultiPaneSimApp"
options.OutputDir( 1, 1 )string = pwd
options.TunableParameters string = ""
options.InputMATFiles string{ fileMustExist } = ""
options.MaxDataPoints( 1, 1 )double = 50000
options.MaxScopeDataPoints( 1, 1 )double = 50000
end 

import simulink.compiler.internal.SignalLoggingUtils
import simulink.compiler.internal.ModelDataService

modelName = baseModelName( modelName );
obj.modelName = modelName;
open_system( obj.modelName );

obj.opts = options;
obj.SignalLoggingUtilities = SignalLoggingUtils( obj.modelName );
obj.ModelDataSvc = ModelDataService( obj.modelName );


appTmpl = which( obj.opts.Template );
if ~isempty( appTmpl )
appTmpl = fileparts( appTmpl );
else 
appTmpl = obj.opts.Template;
templatesPath = fullfile( fileparts( mfilename( 'fullpath' ) ), "templates" );


appTmpl = fullfile( templatesPath, ( obj.TemplatePrefix + appTmpl ) );


if ~exist( appTmpl, 'dir' )
appTmpl = fullfile( templatesPath, obj.opts.Template );
end 
end 

if ~exist( appTmpl, 'dir' )
error( message( "simulinkcompiler:genapp:DirectoryNotFound", obj.opts.Template ) );
end 

if ~contains( appTmpl, '@' )
obj.TemplatePrefix = "";
obj.TemplateType = 'New';
end 

obj.opts.Template = appTmpl;


if isequal( obj.TemplateType, 'Old' )
obj.appDir = fullfile( obj.opts.OutputDir, ( obj.TemplatePrefix + obj.opts.AppName ) );
if exist( obj.appDir, 'dir' ) == 7
error( message( "simulinkcompiler:genapp:AppDirectoryExists", obj.appDir ) );
end 
else 
obj.appDir = obj.opts.OutputDir;
end 

if isequal( obj.TemplateType, 'Old' )
imgFile = obj.opts.AppName + "_image.svg";
imgFile = fullfile( obj.opts.OutputDir, ( obj.TemplatePrefix + obj.opts.AppName ), imgFile );
else 
imgFile = "modelImage.svg";
imgFile = fullfile( obj.opts.OutputDir, obj.TemplatePrefix, 'assets', 'images', imgFile );
end 
obj.modelImage = imgFile;

if isequal( obj.TemplateType, 'Old' )
matFile = obj.opts.AppName + "_inputs.mat";
matFile = fullfile( obj.opts.OutputDir, ( obj.TemplatePrefix + obj.opts.AppName ), matFile );
else 
matFile = "modelData.mat";
matFile = fullfile( obj.opts.OutputDir, obj.TemplatePrefix, 'assets', 'data', matFile );
end 

obj.inputMatFileName = matFile;

end 

function generateTheApp( obj )
import simulink.compiler.internal.util.checkMATLABInstallDir


if isempty( obj.ModelChecker )
obj.ModelChecker =  ...
simulink.compiler.internal.genapp.ModelChecker(  ...
obj.ModelDataSvc, obj.SignalLoggingUtilities );
end 

obj.ModelChecker.checkDirtyState(  );
obj.ModelChecker.checkRunningSim(  );

checkMATLABInstallDir(  );

if isempty( obj.ModelConditioner )
obj.ModelConditioner =  ...
simulink.compiler.internal.genapp.ModelConditioner(  ...
obj.ModelDataSvc, obj.SignalLoggingUtilities );
end 

try 
obj.ModelConditioner.ensureOutputSavingIsOn(  );
obj.ModelChecker.checkSaveFormat(  );
obj.ModelConditioner.limitDataPoints( obj.opts.MaxDataPoints );
obj.ModelConditioner.limitLoggedSignalDataPoints( obj.opts.MaxDataPoints );
obj.ModelConditioner.logRootScopeData(  );
obj.ModelConditioner.limitRootScopeDataPoints( obj.opts.MaxScopeDataPoints );
catch ME
delete( obj.ModelConditioner );
rethrow( ME );
end 

obj.ModelChecker.checkSignalAvailability(  );




dsi = simulink.compiler.internal.getDefaultSimulationInput( obj.modelName );

if ~isempty( obj.opts.TunableParameters )

end 


obj.createAppCopy(  );

if isequal( obj.TemplateType, 'Old' )


obj.createDefaultArgCallbacks(  );
end 



obj.createPragmaFunctions(  );


obj.createModelImage(  );

if isequal( obj.TemplateType, 'Old' )

obj.saveInputMATFile( dsi );
else 
obj.generateModelDataMATFile( dsi );
end 

if isequal( obj.TemplateType, 'New' )
obj.createRunDeployScripts(  );
end 

delete( obj.ModelConditioner );
end 

function app = launchApp( obj )
obj.printMsg( "simulinkcompiler:genapp:LaunchingTheApp", obj.opts.AppName );

outDirDifferentFromPWD = ~strcmp( obj.opts.OutputDir, pwd );

if outDirDifferentFromPWD
addpath( obj.opts.OutputDir );
end 

mdlName = obj.modelName;

if isequal( obj.TemplateType, 'Old' )
inFileName = obj.baseFileName( obj.inputMatFileName );
imgFileName = obj.baseFileName( obj.modelImage );

args = { 'ModelName', mdlName, 'InputMATFileName',  ...
inFileName, 'ModelImage', imgFileName };

app = feval( obj.opts.AppName, args{ : } );
else 
app = feval( obj.opts.AppName );
obj.showUserTips(  );
end 
end 

function openApp( obj )

obj.printMsg( "simulinkcompiler:genapp:OpeningTheApp", obj.opts.AppName );
appdesigner( obj.opts.AppName );
end 
end 

methods ( Access = private )
function backupModel( obj )

modelBackupDir = pwd;
modelBackupName = obj.modelName + "_backup.slx";
modelPath = which( obj.modelName );
obj.printMsg( "simulinkcompiler:genapp:SavingModelBackup", modelBackupName );
copyfile( modelPath, fullfile( modelBackupDir, modelBackupName ), "f" );
end 

function baseName = baseFileName( ~, filePath )
dir = strcat( fileparts( filePath ), filesep );
baseName = strrep( filePath, dir, '' );
end 

function saveInputMATFile( obj, dsi )

varsToSave = struct( "modelName", obj.modelName );


defExtInpsSet = dsi.ExternalInput;
if ~isempty( defExtInpsSet )
varName = get_param( obj.modelName, 'ExternalInput' );
if ~isvarname( varName )
varName = "defExtInpsSet"';
end 
varsToSave.( varName ) = defExtInpsSet;
end 


if isequal( get_param( obj.modelName, 'LoadInitialState' ), 'on' )
defInitialState = dsi.InitialState;
if ~isempty( defInitialState )

if ( isstruct( defInitialState ) &&  ...
isfield( defInitialState, 'signals' ) &&  ...
isstruct( defInitialState.signals ) &&  ...
isfield( defInitialState.signals, 'values' ) )



defInitialState.description = 'InitialState';
varName = get_param( obj.modelName, 'InitialState' );
if ~isvarname( varName )
varName = "defInitialState";
end 
varsToSave.( varName ) = defInitialState;
else 
warning( message( "simulinkcompiler:genapp:IgnoringInitialState" ) );
end 
end 
end 

saveOptions = "-struct";
if exist( obj.inputMatFileName, "file" )
saveOptions = "-append " + saveOptions;
end 
save( obj.inputMatFileName, saveOptions, "varsToSave" );


defMdlPrmsSet = dsi.ModelParameters;
if ~isempty( defMdlPrmsSet )
save( obj.inputMatFileName, "-append", "defMdlPrmsSet" );
end 


defaultParameterSet = dsi.Variables;
if ~isempty( defaultParameterSet )
save( obj.inputMatFileName, "-append", "defaultParameterSet" );
end 

if ~isempty( obj.opts.TunableParameters )


end 


fileNames = obj.opts.InputMATFiles;
if ( fileNames ~= "" )
for fileName = fileNames
vars = load( fileName );
save( obj.inputMatFileName, "-append", "-struct", "vars" );
end 
end 
end 

function generateModelDataMATFile( obj, dsi )

modelData.modelName = obj.modelName;
modelData.modelWebView = "modelWebView.html";


modelData.inputSignals = dsi.ExternalInput;


modelData.loggedSignals = [  ];


modelData.tunableVariables = obj.getTunableVariables( dsi );


modelData.modelParameters.StopTime = dsi.getModelParameter( 'StopTime' );

varsToSave.modelData = modelData;

saveOptions = "-struct";
tplDir = obj.TemplatePrefix;
dataDir = fullfile( obj.opts.OutputDir, tplDir, 'assets', 'data' );
if ~exist( dataDir, 'dir' )
mkdir( dataDir );
end 
save( obj.inputMatFileName, saveOptions, "varsToSave" );
end 

function tunableVars = getTunableVariables( obj, dsi )
tv = simulink.compiler.getTunableVariables( obj.modelName );

if ~isstruct( tv )
tunableVars = [  ];
return ;
end 

tvVarNames = [ tv.QualifiedName ];

siVarNames = string( { dsi.Variables.Name } );
siWksps = string( { dsi.Variables.Workspace } );

[ ~, idx ] = intersect( siVarNames, tvVarNames, 'stable' );
tvWksps = cellstr( siWksps( idx ) );

for tVarIdx = 1:numel( tvVarNames )
if ( ismember( tVarIdx, idx ) )
tv( tVarIdx ).Workspace = tvWksps{ idx };
else 
tv( tVarIdx ).Workspace = 'global-workspace';
end 
end 

tunableVars = tv;
end 

function obj = createModelImage( obj )

load_system( obj.modelName );
imgFile = obj.modelImage;

[ ~, ~, ext ] = fileparts( imgFile );ext = extractAfter( ext, 1 );
print( ( "-s" + obj.modelName ), ( "-d" + ext ), imgFile );
end 

function codeout = replaceToken( ~, codein, token, content )
if ~isempty( content )
codeout = strrep( codein, token, content );
else 
codeout = strrep( codein, token, '' );
end 
end 

function obj = createAppCopy( obj )


obj.printMsg( "simulinkcompiler:genapp:CreatingTheApp", obj.opts.AppName );
srcAppDir = obj.opts.Template;




destDir = fullfile( obj.appDir, srcAppDir );
if exist( destDir, 'dir' )
copyfile( srcAppDir, obj.appDir );
else 
copyfile( srcAppDir, obj.appDir, 'f' );
end 


if isunix
[ success, msg, msgId ] = fileattrib( obj.appDir, '+w', 'u', 's' );
if success ~= 1, error( msg, msgId );end 
end 


[ ~, tmplAppName, ~ ] = fileparts( obj.opts.Template );
if isequal( obj.TemplateType, 'Old' )
tmplAppName = extractAfter( tmplAppName, 1 );
locAppDir = fullfile( obj.opts.OutputDir,  ...
obj.TemplatePrefix + obj.opts.AppName );
else 
locAppDir = fullfile( obj.opts.OutputDir, obj.TemplatePrefix );
end 

classDefOld = fullfile( locAppDir, tmplAppName + ".mlapp" );
classDefNew = fullfile( locAppDir, obj.opts.AppName + ".mlapp" );
[ success, msg, msgId ] = movefile( classDefOld, classDefNew );
if success ~= 1, error( msg, msgId );end 



zipDir = fullfile( obj.opts.OutputDir, strrep( tempname, tempdir, '' ) );
unzip( classDefNew, zipDir );


xmlFileName = fullfile( zipDir, 'matlab', 'document.xml' );
[ fXML, errmsg ] = fopen( xmlFileName );
if fXML < 0, error( errmsg );end 












docXMLContentsCell = textscan( fXML, '%s', 'Delimiter', '\r\n', 'Whitespace', '' );
docXMLLinesCell = docXMLContentsCell{ 1 };
status = fclose( fXML );
if status ~= 0, error( "Error closing " + xmlFileName + " after read" );end 
docXMLLinesCell = strrep( docXMLLinesCell, tmplAppName, obj.opts.AppName );

[ fXML, errmsg ] = fopen( xmlFileName, 'wt' );
if fXML < 0, error( errmsg );end 
fprintf( fXML, '%s\n', docXMLLinesCell );
status = fclose( fXML );
if status ~= 0, error( "Error closing " + xmlFileName + " after write" );end 


appModelDotMat = fullfile( zipDir, 'appdesigner', 'appModel.mat' );
tmpVar = load( appModelDotMat, 'code' );
code = tmpVar.code;
code.ClassName = obj.opts.AppName;
save( appModelDotMat, 'code', '-append' );


corePropsFileName = fullfile( zipDir, 'metadata', 'coreProperties.xml' );
[ fXML, errmsg ] = fopen( corePropsFileName );
if fXML < 0, error( errmsg );end 
corePropsXMLContentsCell = textscan( fXML, '%s', 'Delimiter', '\r\n', 'Whitespace', '' );
corePropsXMLLinesCell = corePropsXMLContentsCell{ 1 };
status = fclose( fXML );
if status ~= 0, error( "Error closing " + corePropsFileName + " after read" );end 
corePropsXMLLinesCell = strrep( corePropsXMLLinesCell, '$TOKEN_AppName', obj.opts.AppName );

[ fXML, errmsg ] = fopen( corePropsFileName, 'wt' );
if fXML < 0, error( errmsg );end 
fprintf( fXML, '%s\n', corePropsXMLLinesCell );
status = fclose( fXML );
if status ~= 0, error( "Error closing " + corePropsFileName + " after write" );end 




zip( classDefNew, '*', what( zipDir ).path );
[ success, msg, messageID ] = movefile( strcat( classDefNew, '.zip' ), classDefNew, 'f' );
if success ~= 1, error( messageID, msg );end 

[ success, msg, messageID ] = rmdir( zipDir, 's' );
if success ~= 1, error( messageID, msg );end 
end 

function createDefaultArgCallbacks( obj )
callbackNames = [ 
"defaultModelName"
"defaultInputMATFileName"
"defaultModelImage"
"defaultModelAspectRatio"
 ];

returnValues = [ 
obj.modelName
obj.baseFileName( obj.inputMatFileName )
obj.baseFileName( obj.modelImage )
mat2str( obj.getModelAspectRatio(  ) )
 ];

callbackMappings = containers.Map( callbackNames, returnValues );

for callbackName = callbackNames'
returnValue = callbackMappings( callbackName );
obj.writeCallbackToFile( callbackName, returnValue );
end 
end 

function writeCallbackToFile( obj, callbackName, callbackOutput )
filePath = obj.generatedFilePath( callbackName );
fh = fopen( filePath, 'wt' );

docComment = obj.generateDocCommentForCallback(  );

uppercaseName = upper( callbackName );
charName = char( callbackName );
argName = string( charName( 8:end  ) );

fprintf( fh, "function defaultValue = %s(~)\r\n", callbackName );
fprintf( fh, docComment, uppercaseName, argName, argName );
fprintf( fh, '\tdefaultValue = "%s";\r\n', callbackOutput );
fprintf( fh, "end\r\n" );
fclose( fh );
end 

function docComment = generateDocCommentForCallback( ~ )
docComment =  ...
"%%%s Return the default value for %s.\r\n" +  ...
"%%\r\n" +  ...
"%%\tThis default value is used by initializeApp() if " +  ...
"one is not provided\r\n" +  ...
"%%\twhen running the generated app, " +  ...
"for example, by calling myApp_SLSimApp\r\n" +  ...
"%%\twithout specifying the pair: '%s', '<some_value>'.\r\n";
end 

function classDef = appClassDef( obj )
classDef = "classdef " + obj.opts.AppName + " < matlab.apps.AppBase";
end 

function filePath = generatedFilePath( obj, fileName )
outDir = obj.opts.OutputDir;
if isequal( obj.TemplateType, 'Old' )
packageName = strcat( obj.TemplatePrefix, obj.opts.AppName );
filePath = fullfile( outDir, packageName, fileName + ".m" );
else 
packageName = obj.TemplatePrefix;
[ success, message, messageID ] =  ...
mkdir( fullfile( outDir, packageName, 'assets' ), 'metadata' );
if success ~= 1, error( messageID, message );end 

metadataPath = fullfile( outDir, packageName, 'assets', 'metadata' );
filePath = fullfile( metadataPath, fileName + ".m" );
end 
end 

function createPragmaFunctions( obj )
filePath = obj.generatedFilePath( "pragma" );
fh = fopen( filePath, 'wt' );

topComment = "%% Directives used by MATLAB Compiler.\n" +  ...
"%%\n" +  ...
"%%\tThese directives are used by the compiler for locating\n" +  ...
"%%\tthe functions called by the app in eval and feval.\n\n";

fprintf( fh, topComment );

obj.appendPragmaFcnToFile( fh, obj.modelName );

if isequal( obj.TemplateType, 'Old' )
inMatFileName = obj.baseFileName( obj.inputMatFileName );
modelImg = obj.baseFileName( obj.modelImage );

obj.appendPragmaFcnToFile( fh, inMatFileName );
obj.appendPragmaFcnToFile( fh, modelImg );


fileNames = obj.opts.InputMATFiles;
if ( strlength( fileNames ) )
for fileName = fileNames
obj.appendPragmaFcnToFile( fh, fileName );
end 
end 
end 

fclose( fh );
end 

function appendPragmaFcnToFile( ~, fh, pragmaName )
fprintf( fh, '%%#function %s\n', pragmaName );
end 

function aspectRatio = getModelAspectRatio( obj )

mdlLoc = get_param( obj.modelName, 'Location' );
mdlWidth = mdlLoc( 3 ) - mdlLoc( 1 );
mdlHeight = mdlLoc( 4 ) - mdlLoc( 2 );
aspectRatio = mdlWidth / mdlHeight;



allStudios = DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
if isempty( allStudios ), return ;end 

bdHndl = get_param( obj.modelName, 'Handle' );
for s = allStudios
if s.App.blockDiagramHandle == bdHndl
editors = s.App.getAllEditors;
for e = editors
if ~isequal( e.getName, obj.modelName ), continue ;end 

scene = e.getCanvas.Scene;
mdlWidth = scene.Bounds( 3 );
mdlHeight = scene.Bounds( 4 );
aspectRatio = mdlWidth / mdlHeight;
return ;
end 
end 
end 
end 

function createRunDeployScripts( obj )
obj.createAppUtilsPackage(  );
obj.createRunScript(  );
obj.createDeployScript( 'DesktopApp' );
obj.createDeployScript( 'WebApp' );
obj.createTestDesktopDeploymentScript(  );
end 

function pkgPath = getAppUtilsPackagePath( obj )
tplDir = obj.TemplatePrefix;
pkgPath = fullfile( obj.opts.OutputDir, tplDir, obj.AppUtilsPkgName );
end 

function createAppUtilsPackage( obj )
utilsDir = obj.getAppUtilsPackagePath(  );
if ~exist( utilsDir, 'dir' )
mkdir( utilsDir );
end 
end 

function createRunScript( obj )
runFilePath = fullfile( obj.getAppUtilsPackagePath(  ), 'run.m' );

fh = fopen( runFilePath, 'wt' );
content = obj.opts.AppName + ";\n";
fprintf( fh, content );
fclose( fh );
end 

function createDeployScript( obj, appType )
deployFilePath = fullfile( obj.getAppUtilsPackagePath(  ), [ 'deploy', appType, '.m' ] );

buildAPI = "standaloneApplication";
if isequal( appType, 'WebApp' )
buildAPI = "webAppArchive";
end 

fh = fopen( deployFilePath, 'wt' );
content = sprintf( "function deploy%s()\n" +  ...
"ws = warning('off', 'Compiler:compiler:COM_WARN_STARTUP_FILE_INCLUDED');\n" +  ...
"oc = onCleanup(@() warning(ws));\n" +  ...
"mlappPath = fullfile(pwd, '%s.mlapp');\n" +  ...
"compiler.build.%s(mlappPath, ...\n" +  ...
"\t'AdditionalFiles', 'assets', ...\n" +  ...
"\t'SupportPackages', 'none', ...\n" +  ...
"\t'OutputDir', 'deployed%s');\n" +  ...
"end\n", appType, obj.opts.AppName, buildAPI, appType );
fprintf( fh, content );
fclose( fh );
end 

function createTestDesktopDeploymentScript( obj )
deployFilePath = fullfile( obj.getAppUtilsPackagePath(  ), 'testDesktopApp.m' );

fh = fopen( deployFilePath, 'wt' );
content = "assert(isfolder('deployedDesktopApp'), 'Run ''deployedDesktopApp'' first.');\n";

if isunix || ismac
content = content + "system(""sh deployedDesktopApp/run_" + obj.opts.AppName + ".sh "" + matlabroot);\n";
elseif ispc
content = content + "system("".\\deployedDesktopApp\\" + obj.opts.AppName + ".exe"");\n";
end 

fprintf( fh, content );
fclose( fh );
end 
end 

methods ( Hidden )
function printMsg( ~, id, varargin )
Simulink.output.info( message( id, varargin{ : } ).string );
end 

function showUserTips( obj )
Simulink.output.info( message( "simulinkcompiler:genapp:ShowUserTips", obj.opts.AppName ).string );
end 
end 
end 

function fileMustExist( fileNames )
if fileNames ~= ""
fileExists = arrayfun( @( x )exist( x, "file" ), fileNames );
if ~all( fileExists )
error( "Files " + fileNames( ~fileExists ) + " does not exist." );
end 
end 
end 

function mustBeValidModelName( modelName )


sls_resolvename( modelName, 'saveslx' );
end 

function modelName = baseModelName( modelName )
[ modelPath, modelName, ~ ] = fileparts( modelName );

if ( modelPath ~= "" )
error( message( "simulinkcompiler:genapp:InvalidModelName" ) );
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpz3XbAg.p.
% Please follow local copyright laws when handling this file.

