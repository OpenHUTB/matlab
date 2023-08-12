classdef TemplateGenerator < handle





properties ( Access = private )
SourceAppName
TemplateName
OutputDir
AppPath
ExistingTemplateHandling
end 

properties ( Access = private, Dependent )
TemplateDir
end 

properties ( Access = private, Constant )
OverwriteExistingTemplate = "overwrite"
RenameExistingTemplate = "rename"
DefaultTemplateName = "SimAppTemplate"

ClassDirPrefix = "@"
AppFileExt = ".mlapp"
end 

methods 

function obj = TemplateGenerator( sourceAppName, options )
R36
sourceAppName( 1, 1 )string ...
{ simulink.compiler.internal.TemplateGenerator.appMustExist }
options.TemplateName( 1, 1 )string =  ...
simulink.compiler.internal.TemplateGenerator.DefaultTemplateName
options.OutputDir( 1, 1 )string = pwd
options.ExistingTemplateHandling( 1, 1 )string ...
{ simulink.compiler.internal.TemplateGenerator.mustBeValidTemplateHandling }
end 

obj.SourceAppName = obj.baseAppName( sourceAppName );
obj.AppPath = obj.appPath( sourceAppName );
obj.OutputDir = options.OutputDir;
obj.TemplateName = options.TemplateName;

if isfield( options, "ExistingTemplateHandling" )
obj.ExistingTemplateHandling = options.ExistingTemplateHandling;
end 
end 

function generate( obj )
obj.handleExistingTemplate(  );

msgKey = "simulinkcompiler:genapp:CreatingTemplate";
msg = message( msgKey, obj.TemplateName ).string;
fprintf( msg );

try 
obj.copyAppDirToTemplate(  );
if isMultiPaneSimApp( obj.AppPath )
appLocation = dir( obj.AppPath ).folder;
mkdir( obj.TemplateDir, "@AppHelper" );
mkdir( fullfile( obj.TemplateDir ), "assets" );
copyfile( fullfile( appLocation, "@AppHelper" ), fullfile( obj.TemplateDir, "@AppHelper" ) );
copyfile( fullfile( appLocation, "assets" ), fullfile( obj.TemplateDir, "assets" ) );
end 
obj.renameMlappFile(  );
unzipDir = obj.unzipMlappFile(  );
obj.renameClassInMlappFile( unzipDir );
obj.zipMlappFile( unzipDir );
obj.removeUnneededFiles(  );
catch templateGenException
errorId = "SimulinkCompiler:GenTemplate:UnableToGenerateTemplate";
msgKey = "simulinkcompiler:genapp:UnableToGenerateTemplate";
msg = message( msgKey ).string;

userException = MException( errorId, msg );
userException = addCause( userException, templateGenException );
throw( userException );
end 
end 

function templateDir = get.TemplateDir( obj )
if isMultiPaneSimApp( obj.AppPath )
templateDir = fullfile( obj.OutputDir, obj.TemplateName );
else 
templateDir = fullfile( obj.OutputDir, obj.ClassDirPrefix + obj.TemplateName );
end 
end 

end 

methods ( Access = private )

function pickUnusedNameForTemplate( obj )
origTemplateName = obj.TemplateName;
suffix = 1;
while exist( obj.TemplateDir, "dir" ) == 7
obj.TemplateName = origTemplateName + suffix;
suffix = suffix + 1;
end 
end 

function removeTemplateDir( obj )
if ~isfolder( obj.TemplateDir )
return 
end 

rmdir( obj.TemplateDir, "s" );
end 

function copyAppDirToTemplate( obj )
if isMultiPaneSimApp( obj.AppPath )
mkdir( obj.TemplateDir );
end 

copyfile( obj.AppPath, obj.TemplateDir );

if isunix
makeWritable( obj.TemplateDir );
end 
end 

function renameMlappFile( obj )
classDefOld = fullfile( obj.TemplateDir, obj.SourceAppName + obj.AppFileExt );
movefile( classDefOld, obj.newClassDef(  ) );
end 

function renameClassInMlappFile( obj, unzipDir )
obj.updateClassNameInDocDotXML( unzipDir );
obj.updateClassNameInAppModelDotMAT( unzipDir );
obj.updateAppNameInCorePropsDotXML( unzipDir );
end 

function unzipDir = unzipMlappFile( obj )
unzipDir = fullfile( obj.OutputDir, strrep( tempname, tempdir, "" ) );
unzip( obj.newClassDef(  ), unzipDir );
end 

function linesCell = readXMLFileAsCharCell( ~, filePath )
[ fXML, errmsg ] = fopen( filePath );

if fXML < 0
error( errmsg );
end 












fileContentsCell = textscan( fXML, '%s', 'Delimiter', '\r\n', 'Whitespace', '' );
linesCell = fileContentsCell{ 1 };
status = fclose( fXML );

if status ~= 0
msgKey = "simulinkcompiler:genapp:ErrorClosingAfterRead";
error( message( msgKey, filePath ).string );
end 
end 

function replaceAppNameInXMLFile( obj, replacement, filePath )
xmlLinesCell = obj.readXMLFileAsCharCell( filePath );
xmlLinesCell = strrep( xmlLinesCell, obj.SourceAppName, replacement );
obj.writeCharCellToXMLFile( xmlLinesCell, filePath );
end 

function updateClassNameInDocDotXML( obj, zipDir )
xmlFileName = fullfile( zipDir, "matlab", "document.xml" );
obj.replaceAppNameInXMLFile( obj.TemplateName, xmlFileName );
end 

function updateClassNameInAppModelDotMAT( obj, zipDir )
appModelDotMat = fullfile( zipDir, "appdesigner", "appModel.mat" );
tmpVar = load( appModelDotMat, "code" );
code = tmpVar.code;
code.ClassName = obj.TemplateName;
save( appModelDotMat, "code", "-append" );
end 

function updateAppNameInCorePropsDotXML( obj, zipDir )
corePropsFileName = fullfile( zipDir, "metadata", "coreProperties.xml" );
obj.replaceAppNameInXMLFile( "$TOKEN_AppName", corePropsFileName );
end 

function zipMlappFile( obj, unzipDir )
classDefNew = obj.newClassDef(  );
zip( classDefNew, strcat( unzipDir, filesep, "*" ) );
movefile( strcat( classDefNew, ".zip" ), classDefNew, "f" );
rmdir( unzipDir, "s" );
end 

function classDef = newClassDef( obj )
classDef = fullfile( obj.TemplateDir, obj.TemplateName + obj.AppFileExt );
end 

function removeUnneededFiles( obj )
if isMultiPaneSimApp( obj.AppPath )
autoGeneratedFiles = [ 
fullfile( "assets", "metadata", "pragma.m" ),  ...
fullfile( "assets", "data", "modelData.mat" ),  ...
fullfile( "assets", "images", "modelImage.svg" )
 ];
else 
autoGeneratedFiles = [  ...
"defaultInputMATFileName.m",  ...
"defaultModelAspectRatio.m",  ...
"defaultModelImage.m",  ...
"defaultModelName.m",  ...
"pragma.m" ...
, obj.SourceAppName + "_inputs.mat",  ...
obj.SourceAppName + "_image.svg"
 ];
end 
deleteFile = @( fn )delete( fullfile( obj.TemplateDir, fn ) );
arrayfun( deleteFile, autoGeneratedFiles );
if isMultiPaneSimApp( obj.AppPath )
rmdir( fullfile( obj.TemplateDir, "assets", "data" ), "s" );
rmdir( fullfile( obj.TemplateDir, "assets", "metadata" ), "s" );
end 
end 

function handleExistingTemplate( obj )
if ~isempty( obj.ExistingTemplateHandling )
switch ( obj.ExistingTemplateHandling )
case obj.RenameExistingTemplate
obj.pickUnusedNameForTemplate(  );

case obj.OverwriteExistingTemplate
obj.removeTemplateDir(  );
end 
elseif exist( obj.TemplateDir, "dir" ) == 7
msgKey = "simulinkcompiler:genapp:DirectoryExists";
validValues = obj.validExistingTemplateHandlingValues(  );
validValues = join( arrayfun( @( elem )"<enum>" + elem + "</enum>", validValues ) );
msg = message( msgKey, obj.TemplateDir, obj.SourceAppName, validValues );
throw( MSLException( [  ], msg ) );
end 
end 

function baseName = baseAppName( obj, appName )
[ ~, fileName ] = fileparts( appName );
baseName = strrep( fileName, obj.ClassDirPrefix, "" );
end 
end 

methods ( Static, Access = private )
function writeCharCellToXMLFile( charCell, filePath )
[ fXML, errmsg ] = fopen( filePath, "wt" );

if fXML < 0
error( errmsg );
end 

fprintf( fXML, "%s\n", charCell );
status = fclose( fXML );

if status ~= 0
msgKey = "simulinkcompiler:genapp:ErrorClosingAfterWrite";
error( message( msgKey, filePath ).string );
end 
end 

function appPath = appPath( sourceAppName )
import simulink.compiler.internal.TemplateGenerator;

[ filePath, fileName ] = fileparts( sourceAppName );
if isMultiPaneSimApp( sourceAppName )
fileName = fileName + ".mlapp";
else 
fileName = TemplateGenerator.ClassDirPrefix +  ...
strrep( fileName, TemplateGenerator.ClassDirPrefix, "" );
end 
appPath = fullfile( filePath, fileName );
end 

function appMustExist( sourceAppName )
import simulink.compiler.internal.TemplateGenerator;
appPath = TemplateGenerator.appPath( sourceAppName );

isOldStyleApp = ~isMultiPaneSimApp( appPath ) && isfolder( appPath );

if ~isMultiPaneSimApp( appPath ) && ~isOldStyleApp
msgKey = "simulinkcompiler:genapp:DirectoryNotFound";
error( message( msgKey, sourceAppName ).string );
end 
end 

function validValues = validExistingTemplateHandlingValues(  )
import simulink.compiler.internal.TemplateGenerator;
validValues = [  ...
TemplateGenerator.OverwriteExistingTemplate,  ...
TemplateGenerator.RenameExistingTemplate,  ...
 ];
end 

function mustBeValidTemplateHandling( option )
import simulink.compiler.internal.TemplateGenerator;
mustBeMember( option, TemplateGenerator.validExistingTemplateHandlingValues(  ) )
end 
end 
end 

function makeWritable( dir )
[ success, msg, msgId ] = fileattrib( dir, "+w", "u", "s" );
if success ~= 1, error( msg, msgId );end 
end 

function TF = isMultiPaneSimApp( appPath )




[ filePath, fileName ] = fileparts( appPath );
TF = isfolder( fullfile( filePath, "@AppHelper" ) ) &&  ...
isfile( fullfile( filePath, fileName + ".mlapp" ) ) &&  ...
isfolder( fullfile( filePath, "assets" ) );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpvnQI3Y.p.
% Please follow local copyright laws when handling this file.

