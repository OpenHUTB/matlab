function emitHTML( obj, varargin )




if isa( obj, 'Simulink.ModelReference.ProtectedModel.Report' )
protectedModelBuild = true;
else 
protectedModelBuild = false;
end 


tempTurnOffV2 = protectedModelBuild;
if tempTurnOffV2
reportFlag = Simulink.report.ReportInfo.featureReportV2( false );
end 

if ~Simulink.report.ReportInfo.featureReportV2
loc_emitHTML_V1( obj, varargin{ : } );
else 
loc_emitHTML_V2( obj, varargin{ : } );
end 

if tempTurnOffV2

Simulink.report.ReportInfo.featureReportV2( reportFlag );
end 
end 




function loc_emitHTML_V2( obj, varargin )

try 
if ~bdIsLoaded( obj.ModelName )
obj.loadModel;
end 
obj.updateConfig;
catch me
switch ( me.identifier )
case 'Simulink:Commands:OpenSystemUnknownSystem'
error( 'Attempted to open unknown system: %s', obj.ModelName );
otherwise 
rethrow( me );
end 
end 

if obj.UpdateReport
reportFolder = obj.getReportDir;
for k = 1:length( obj.Pages )
p = obj.Pages{ k };
p.ReportFolder = reportFolder;
p.beforeUpdate( obj.Config, obj.LastConfig );
end 
end 

savedConfig = obj.Config;

for k = 1:2:nargin - 1
obj.Config.( varargin{ k } ) = varargin{ k + 1 };
end 

obj.Config.checkLicense;

model = obj.ModelName;
obj.createReportDir;
outPath = obj.getReportDir;


dataPath = fullfile( outPath, 'data' );
if ~exist( dataPath, 'dir' )
mkdir( dataPath );
end 


cr = simulinkcoder.internal.Report.getInstance;
isRefBuild = isCurrModelRefBuild( obj );
if ~isempty( obj.SourceSubsystem )
rootsysTemp = bdroot( obj.SourceSubsystem );
modelSource = model;
else 
rootsysTemp = model;
modelSource = obj.getActiveModelName;
end 
codeData = cr.getCodeData( rootsysTemp, isRefBuild, '', true );

if isempty( codeData )
error( 'Code Data not found!' );
end 

fid = fopen( fullfile( dataPath, 'data.js' ), 'w' );
fprintf( fid, 'var dataJson = %s;', jsonencode( codeData ) );
fclose( fid );


loc_getCommentTraceables( obj );


fid = fopen( fullfile( dataPath, 'pages.js' ), 'w' );
fprintf( fid, 'var reportPages = [' );
pages = obj.Pages;



containsTraceReport = false;
for k = 1:length( pages )
page = pages{ k };
if isa( page, 'rtw.report.Traceability' )
containsTraceReport = true;
break ;
end 
end 

if strcmpi( obj.Config.GenerateTraceInfo, 'on' ) && ~containsTraceReport



buildDir = obj.BuildDirectory;
[ rootsys, subsys, bMdlRef ] = getSystemNames( obj );
traceInfo_fileList = {  };
sortedFileInfoList = obj.getSortedFileInfoList;
for n = 1:sortedFileInfoList.NumFiles
if ( isequal( fileparts( sortedFileInfoList.FileName{ n } ), buildDir ) ||  ...
isequal( fileparts( sortedFileInfoList.FileName{ n } ), '$(BuildDir)' ) )
traceInfo_fileList{ length( traceInfo_fileList ) + 1 } = sortedFileInfoList.FileName{ n };%#ok<AGROW>
end 
end 
coder.internal.slcoderReport( 'saveTraceInfo', rootsys, buildDir, traceInfo_fileList, bMdlRef, subsys, model, obj );
end 

for k = 1:length( pages )
p = pages{ k };
title = p.getShortTitle;
model = obj.ModelName;
suffix = obj.getModelNameSuffix;
baseName = [ model, suffix ];
if isempty( p.ReportFileName )

fileName = [ baseName, '_', p.getDefaultReportFileName ];
else 
fileName = p.getReportFileName;
end 
fprintf( fid, '["%s","%s"]', title, fileName );
if k ~= length( pages )
fprintf( fid, "," );
end 
end 

fprintf( fid, "];" );
fclose( fid );


if strcmp( obj.Config.GenerateWebview, 'on' )
obj.emitWebview(  );
end 


obj.emitPages(  );


if isfolder( dataPath )
modelHierarchyJs = generateModelHierarchyJsFlat( obj, model, isRefBuild );
modelHierarchyJs = strrep( modelHierarchyJs, '\', '/' );
[ fid, errMsg ] = fopen( fullfile( dataPath, 'model.js' ), 'w' );
assert( fid ~=  - 1, sprintf( 'Path: %s, Error: %s', dataPath, errMsg ) );
fprintf( fid, 'var modelInfo = {model:"%s"};', obj.ModelName );
fprintf( fid, modelHierarchyJs );
fclose( fid );
end 

if isRefBuild
indexSrcFile = fullfile( matlabroot,  ...
'toolbox', 'coder', 'simulinkcoder_app', 'slcoderRpt',  ...
'src', 'slcoderRpt_js', 'indexMdlRef.html' );
internalSrcFile = fullfile( matlabroot,  ...
'toolbox', 'coder', 'simulinkcoder_app', 'slcoderRpt',  ...
'src', 'slcoderRpt_js', 'slcoderRpt', '_internalMdlRef.html' );
else 
indexSrcFile = fullfile( matlabroot,  ...
'toolbox', 'coder', 'simulinkcoder_app', 'slcoderRpt',  ...
'src', 'slcoderRpt_js', 'index.html' );
internalSrcFile = fullfile( matlabroot,  ...
'toolbox', 'coder', 'simulinkcoder_app', 'slcoderRpt',  ...
'src', 'slcoderRpt_js', 'slcoderRpt', '_internal.html' );
end 

indexDstFile = fullfile( outPath, 'index.html' );
copyfile( indexSrcFile, indexDstFile, 'f' );
internalDstFile = fullfile( outPath, '_internal.html' );
copyfile( internalSrcFile, internalDstFile, 'f' );


libFolder = fullfile( matlabroot, 'toolbox', 'coder', 'simulinkcoder_app', 'slcoderRpt',  ...
'resources', 'lib' );
if isRefBuild
libParent = fileparts( obj.BuildDirectory );

dstLibFolder = fullfile( libParent, '_htmllib' );
if ~isfolder( dstLibFolder )
copyfile( libFolder, dstLibFolder, 'f' );
end 
else 

dstLibFolder = fullfile( outPath, 'lib' );
copyfile( libFolder, dstLibFolder, 'f' );
end 

if ~isRefBuild
try 
folders = Simulink.filegen.internal.FolderConfiguration( obj.ModelName );
secondDir = fileparts( folders.CodeGeneration.ModelReferenceCode );
parentPath = fullfile( obj.StartDir, secondDir );
dstLibFolder = fullfile( parentPath, '_htmllib' );
if ~isfolder( dstLibFolder )
copyfile( libFolder, dstLibFolder, 'f' );
end 
catch me
if ~strcmpi( me.identifier, 'Simulink:FileGen:ModelNotFound' )
rethrow( me );
end 
end 
end 


hiliteFile = 'rtwhilite2.js';
resourceDir = Simulink.report.ReportInfo.getResourceDir;
coder.report.ReportInfoBase.copyFiles( resourceDir, { hiliteFile }, fullfile( outPath, 'pages' ) );

jsfile = fullfile( matlabroot, 'toolbox', 'shared', 'codergui', 'web', 'resources', 'rtwshrink.js' );
dstfile = fullfile( obj.getReportDir, 'pages', 'rtwshrink.js' );
coder.internal.coderCopyfile( jsfile, dstfile );


fileName = fullfile( outPath, '_internal.html' );


if obj.hasWebview(  )
obj.emitMain( fileName );
end 


massUpdateLegacyMCall( obj );



if obj.hasWebview(  )
updateWebviewLinksForReport( obj );
end 


obj.Config = savedConfig;

end 


function loc_emitHTML_V1( obj, varargin )

suppressHyperlinks = false;
try 
if ~bdIsLoaded( obj.ModelName )
obj.loadModel;
end 
obj.updateConfig;
catch me
switch ( me.identifier )
case 'Simulink:Commands:OpenSystemUnknownSystem'
suppressHyperlinks = true;
otherwise 
rethrow( me );
end 
end 
if obj.UpdateReport
reportFolder = obj.getReportDir;
for k = 1:length( obj.Pages )
p = obj.Pages{ k };
p.ReportFolder = reportFolder;
p.beforeUpdate( obj.Config, obj.LastConfig );
end 
end 

savedConfig = obj.Config;
obj.createReportDir;
oldDir = cd( obj.getReportDir );
try 
for k = 1:2:nargin - 1
obj.Config.( varargin{ k } ) = varargin{ k + 1 };
end 
if suppressHyperlinks
obj.Config.IncludeHyperlinkInReport = 'off';

end 
obj.Config.checkLicense;

perf_id = 'Report emitWebview';
PerfTools.Tracer.logSimulinkData( 'SLbuild', obj.ModelName, obj.PerfTracerTargetName,  ...
perf_id, true );
obj.emitWebview;
PerfTools.Tracer.logSimulinkData( 'SLbuild', obj.ModelName, obj.PerfTracerTargetName,  ...
perf_id, false );
perf_id = 'Report emitMain';
PerfTools.Tracer.logSimulinkData( 'SLbuild', obj.ModelName, obj.PerfTracerTargetName,  ...
perf_id, true );
obj.emitMain;
PerfTools.Tracer.logSimulinkData( 'SLbuild', obj.ModelName, obj.PerfTracerTargetName,  ...
perf_id, false );
if obj.AddCode
perf_id = 'Report code2html';
PerfTools.Tracer.logSimulinkData( 'SLbuild', obj.ModelName, obj.PerfTracerTargetName,  ...
perf_id, true );
obj.convertCode2HTML(  );
PerfTools.Tracer.logSimulinkData( 'SLbuild', obj.ModelName, obj.PerfTracerTargetName,  ...
perf_id, false );
end 
perf_id = 'Report emitContents';
PerfTools.Tracer.logSimulinkData( 'SLbuild', obj.ModelName, obj.PerfTracerTargetName,  ...
perf_id, true );



obj.emitContents;
PerfTools.Tracer.logSimulinkData( 'SLbuild', obj.ModelName, obj.PerfTracerTargetName,  ...
perf_id, false );



obj.copyResources;
catch me
obj.Config = savedConfig;
cd( oldDir );
rethrow( me );
end 
obj.Config = savedConfig;
cd( oldDir );
end 



function modelHierarchyJs = generateModelHierarchyJsFlat( topReportInfo, topModelName, isRefBuild )
modelHierarchy = {  };
modelHierarchy = { modelHierarchy{ : }, { topModelName, '_internal.html', 'null' } };%#ok
refParentModelName = topModelName;


refModelNames = topReportInfo.ModelReferences;
refModelBuildDirs = topReportInfo.ModelReferencesBuildDir;

for i = 1:length( refModelNames )
refModelName = refModelNames{ i };
if ~isempty( refModelBuildDirs ) && refModelBuildDirs.isKey( refModelName )

relDir = refModelBuildDirs( refModelName ).ModelRefRelativeBuildDir;
[ ~, justModel, ~ ] = fileparts( relDir );
if ~isRefBuild

parentRelDir = fullfile( '..', '..', relDir );
else 
parentRelDir = fullfile( '..', '..', justModel );
end 
cfg = Simulink.fileGenControl( 'getConfig' );
isTargEnvSetting = strcmpi( cfg.CodeGenFolderStructure, 'TargetEnvironmentSubfolder' );
if isTargEnvSetting

if ~isRefBuild

parentRelDir = fullfile( '..', '..', '_ref', refModelName );
else 

parentRelDir = fullfile( '..', '..', refModelName );
end 
end 
currModelRelativeBuildDir = fullfile( parentRelDir, 'html', '_internal.html' );
modelHierarchy = { modelHierarchy{ : }, { refModelName, currModelRelativeBuildDir, refParentModelName } };%#ok

if ~isRefBuild && ~isTargEnvSetting


baseFolder = refModelBuildDirs( refModelName ).CodeGenFolder;
dataFile = fullfile( baseFolder, relDir, 'html', 'data', 'model.js' );
if isfile( dataFile )
rewriteModelRefRelPaths( dataFile );
end 
end 
else 

modelHierarchy = { modelHierarchy{ : }, { refModelName, '', refParentModelName } };%#ok
end 
end 

modelHierarchyJs = getmodelHierarchyFileFlat( modelHierarchy );
end 

function rewriteModelRefRelPaths( fileName )



txt = fileread( fileName );
regexpStr = 'slprj/.+?/';
newTxt = regexprep( txt, regexpStr, '' );
[ fid, errMsg ] = fopen( fileName, 'w' );
assert( fid ~= 1, sprintf( 'File: %s, error: %s', fileName, errMsg ) );
fprintf( fid, newTxt );
fclose( fid );
end 

function modelHierarchyOutput = getmodelHierarchyFileFlat( modelHierarchy )
modelHierarchyJs = 'var modelHierarchy=[';
size = length( modelHierarchy );

for i = 1:size
modelInfo = modelHierarchy{ i };
curr = [ '{model:"', modelInfo( 1 ), '",',  ...
'relativePath:"', modelInfo( 2 ), '",',  ...
'parent:"', modelInfo( 3 ), '"},' ];
modelHierarchyJs = [ modelHierarchyJs, curr ];%#ok
end 
modelHierarchyJs = [ modelHierarchyJs, '];' ];
modelHierarchyOutput = [ modelHierarchyJs{ : } ];
end 

function res = isCurrModelRefBuild( obj )


res = false;

model = obj.ModelName;
try 
dirs = RTW.getBuildDir( model );
catch 

return ;
end 
relRefBuildFolder = dirs.ModelRefRelativeBuildDir;
if ~isempty( relRefBuildFolder ) && contains( obj.getReportDir, relRefBuildFolder )


res = true;
end 
end 

function updateWebviewLinksForReport( obj )

if ~Simulink.report.ReportInfo.featureReportV2
return ;
end 

rptFolder = fullfile( obj.getReportDir, 'pages' );


htmlList = dir( fullfile( rptFolder, '*.html' ) );


postFcnDef = [ '<script>', coder.report.internal.getPostParentWindowMessageDef, '</script>' ];
for idx = 1:numel( htmlList )
fileName = htmlList( idx ).name;
fileName = fullfile( rptFolder, fileName );
fid = fopen( fileName );
txtCell = textscan( fid, '%s' );
txtStr = txtCell{ 1 };
htmlTxt = strjoin( txtStr );
fclose( fid );

isGetPostFcnPresent = false;
postFcnStr = 'postParentWindowMessage(message)';
if contains( htmlTxt, postFcnStr )
isGetPostFcnPresent = true;
end 



regexpStr = "\(\{message:'legacyMCall',\s+expr:'coder\.internal\.code2model.+?'(.+?):(\w+?)\\'\).*?\}\)";
replaceStr = "({message:'traceToWebview', modelName:'$1', sid:'$2'})";
newHtmlTxt = regexprep( htmlTxt, regexpStr, replaceStr );

fid = fopen( fileName, 'w' );
fprintf( fid, '%s', newHtmlTxt );
fclose( fid );

if ~isGetPostFcnPresent


newHtmlTxt = replace( newHtmlTxt, '</body> </html>', [ postFcnDef, ' </body> </html>' ] );
fid = fopen( fileName, 'w' );
fprintf( fid, '%s', newHtmlTxt );
fclose( fid );
end 


regexpStr = "\(\{message:'legacyMCall',\s+expr:'coder\.internal\.code2model\(\\'(.+?)', sid:'(\w+?)'.*?\}\)";
replaceStr = "({message:'traceToWebview', modelName:'$1', sid:'$2'})";
newHtmlTxt2 = regexprep( newHtmlTxt, regexpStr, replaceStr );

if ~strcmp( newHtmlTxt, newHtmlTxt2 )
fid = fopen( fileName, 'w' );
fprintf( fid, '%s', newHtmlTxt2 );
fclose( fid );
end 

end 
end 

function massUpdateLegacyMCall( obj )




rptFolder = fullfile( obj.getReportDir, 'pages' );


htmlList = dir( fullfile( rptFolder, '*.html' ) );


for idx = 1:length( htmlList )
fileName = htmlList( idx ).name;
if contains( fileName, '_trace.html' ) || contains( fileName, '_metrics.html' )

continue ;
end 

fileName = fullfile( rptFolder, fileName );
htmlTxt = fileread( fileName );



newHtmlTxt = coder.internal.slcoderReport( 'editMCallHyperlinkForV2Html', htmlTxt );
if isempty( newHtmlTxt ) && ~contains( fileName, '_survey.html' )
continue ;
end 


postFcnDef = [ '<script>', coder.report.internal.getPostParentWindowMessageDef, '</script>' ];
if ~isempty( newHtmlTxt )
newHtmlTxt = strrep( newHtmlTxt, '</body>', sprintf( '%s\n</body>', postFcnDef ) );
else 


newHtmlTxt = strrep( htmlTxt, '</body>', sprintf( '%s\n</body>', postFcnDef ) );
end 


fid = fopen( fileName, 'w' );
fprintf( fid, '%s', newHtmlTxt );
fclose( fid );
end 
end 

function loc_getCommentTraceables( reportInfo )
currModel = reportInfo.ModelName;
subsys = reportInfo.SourceSubsystem;
if isempty( subsys )

rootsys = getfullname( currModel );
else 

rootsys = strtok( subsys, '/:' );
end 

buildDir = reportInfo.BuildDirectory;
htmlDir = fullfile( buildDir, 'html' );

cfg = reportInfo.Config;
bGenHTMLFile = ~rtw.report.ReportInfo.DisplayInCodeTrace || reportInfo.hasWebview;
hlink = strcmp( cfg.IncludeHyperlinkInReport, 'on' );
bLink2Webview = reportInfo.hasWebview;
if strcmp( cfg.GenerateTraceReport, 'on' ) ||  ...
strcmp( cfg.GenerateTraceReportSl, 'on' ) ||  ...
strcmp( cfg.GenerateTraceReportSf, 'on' ) ||  ...
strcmp( cfg.GenerateTraceReportEml, 'on' )
gentracerpt = true;
else 
gentracerpt = false;
end 

if strcmp( cfg.GenerateTraceInfo, 'on' )
gentrace = true;
else 
gentrace = false;
end 

ssHdl = [  ];
newSSName = '';
if ~isValidSlObject( slroot, currModel )
if ~isempty( reportInfo.SourceSubsystem )
ssHdl = get_param( reportInfo.SourceSubsystem, 'Handle' );
newSSName = reportInfo.TemporaryModelFullSSName;
end 
else 
ssHdl = rtwprivate( 'getSourceSubsystemHandle', currModel );
newSSName = rtwprivate( 'getNewSubsystemName', currModel );
end 
if slfeature( 'RightClickBuild' ) ~= 0
try 
modelPath = get_param( rootsys, 'FileName' );
catch 
load_system( rootsys );
modelPath = get_param( rootsys, 'FileName' );
close_system( rootsys );
end 
else 
modelPath = get_param( rootsys, 'FileName' );
end 
traceRequirements = true;
bBlockSIDComment = coder.internal.isBlockSIDCommentEnabled( rootsys );
if ( ~isempty( subsys ) || isempty( coder.internal.ModelCodegenMgr.getInstance( currModel ) ) )
systemMap = reportInfo.SystemMap;
else 
systemMap = [  ];
end 
arg = { hlink, currModel, ssHdl, newSSName,  ...
modelPath, buildDir, traceRequirements, bLink2Webview, bBlockSIDComment, systemMap,  ...
bGenHTMLFile, [  ], fullfile( htmlDir, filesep ) };
sortedFileInfoList = reportInfo.getSortedFileInfoList;
protectingCurrentModel = Simulink.ModelReference.ProtectedModel.protectingModel( currModel );
rtwprivate( 'rtwctags', sortedFileInfoList.FileName,  ...
arg, true,  ...
sortedFileInfoList.HtmlFileName,  ...
gentrace || gentracerpt, 'utf-8', protectingCurrentModel );
end 

function [ rootsys, subsys, bMdlRef ] = getSystemNames( obj )

bMdlRef = ~strcmp( obj.ModelReferenceTargetType, 'NONE' );
reportInfo = rtw.report.getReportInfo( obj.ModelName, obj.BuildDirectory );

if bMdlRef
subsys = '';
else 
subsys = reportInfo.SourceSubsystem;
end 

if isempty( subsys )

rootsys = getfullname( obj.ModelName );
else 

if slfeature( 'RightClickBuild' ) == 0
rootsys = strtok( subsys, '/:' );
else 
rootsys = obj.ModelName;
end 
end 

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpkhzHL_.p.
% Please follow local copyright laws when handling this file.

