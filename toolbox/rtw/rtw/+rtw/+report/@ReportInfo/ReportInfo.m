classdef ReportInfo < Simulink.report.ReportInfo








properties ( Hidden )
Summary = [  ]
ReducedBlocks = [  ]
InsertedBlocks = [  ]
AddSource = true
RelativePathToSharedUtilRptFromRpt = ''
BlockTracker = [  ]
ModelRefRelativeBuildDir = [  ]
CustomFile = {  }
Encoding = ''
RelativePathFromBuildDirToSharedUtilDir;
BuildSuccess = true
isInstrBuild = false;
RelativePathFromBuildDirToStartDir
end 

properties ( SetAccess = private, Hidden = true )
CodeGenerationId = [  ];
CodeGenerationIdStaticMetrics = [  ];
end 

properties ( Transient = true )
CachedSortedFileInfo = {  }
CachedFileInfo = [  ];
CachedSortedFileInfoList = [  ];

LastConfig


UpdateReport = false
end 
properties ( Transient )
Dlg
StartDir
end 

methods 
function obj = ReportInfo( modelName )
obj = obj@Simulink.report.ReportInfo( modelName );
if Simulink.report.ReportInfo.featureOpenInStudio
obj.Summary = rtw.report.SummaryInStudio( modelName );
else 
obj.Summary = rtw.report.Summary( modelName );
end 
obj.Dirty = true;
obj.FileInfo = obj.newFileInfo( {  }, {  }, {  }, {  }, {  } );
obj.BlockTracker = rtw.report.CodeGenBlockTracker( modelName );
obj.Encoding = 'UTF-8';
end 

function setCodeGenerationId( this, codeGenId )
this.CodeGenerationId = codeGenId;
this.Dirty = true;
end 

function setCodeGenerationIdStaticMetrics( this, codeGenId )
this.CodeGenerationIdStaticMetrics = codeGenId;
this.Dirty = true;
end 



function initPathDuringBuild( obj, buildDir, startDir )
obj.BuildDirectory = buildDir;
obj.StartDir = startDir;
obj.RelativePathFromBuildDirToStartDir = rtwprivate( 'rtwGetRelativePath', startDir, buildDir );
currPath = pwd;
clean = onCleanup( @(  )cd( currPath ) );
cd( startDir );
if isempty( obj.SourceSubsystem )
buildDirs = RTW.getbuildDir( obj.ModelName );
else 
buildDirs = RTW.getbuildDir( bdroot( obj.SourceSubsystem ) );
end 

obj.GenUtilsPath = fullfile( startDir, buildDirs.SharedUtilsTgtDir );
obj.RelativePathFromBuildDirToSharedUtilDir = rtwprivate( 'rtwGetRelativePath', fullfile( obj.GenUtilsPath, filesep ), fullfile( obj.BuildDirectory, filesep ) );
end 

function initStartDirBasedOnBuildDir( obj )
if isempty( obj.StartDir ) && ~isempty( obj.BuildDirectory )
obj.StartDir = cd( cd( fullfile( obj.BuildDirectory, obj.RelativePathFromBuildDirToStartDir ) ) );
end 
end 

function fileInfo = tokenPath( obj, fileInfo )

filePath = fullfile( fileInfo.Path, filesep );
mlroot = fullfile( matlabroot, filesep );
startDir = fullfile( obj.StartDir, filesep );
buildDir = fullfile( obj.BuildDirectory, filesep );
genUtilsPath = fullfile( obj.GenUtilsPath, filesep );
if isempty( filePath ) || strcmp( filePath, buildDir )
filePath = '$(BuildDir)';
elseif ~strcmp( filePath, buildDir ) && strcmp( filePath, genUtilsPath )
filePath = '$(SharedUtilsDir)';




elseif ~isempty( startDir ) && strncmp( filePath, startDir, length( startDir ) )
if strcmp( filePath, startDir )
filePath = '$(StartDir)';
else 
filePath = [ '$(StartDir)', filePath( length( startDir ):end  - 1 ) ];
end 
elseif strncmp( filePath, mlroot, length( mlroot ) )
if strcmp( filePath, mlroot )
filePath = '$(MATLAB_ROOT)';
else 
filePath = [ '$(MATLAB_ROOT)', filePath( length( mlroot ):end  - 1 ) ];
end 
elseif exist( fileInfo.Path, 'dir' )
relativeToBuildDir = rtwprivate( 'rtwGetRelativePath', filePath, buildDir );



if ~strcmp( fullfile( relativeToBuildDir, filesep ), filePath )
filePath = fullfile( '$(BuildDir)', relativeToBuildDir );
end 
else 
filePath = fileInfo.Path;
end 
fileInfo.Path = filePath;
end 

function initGenUtilsPathBasedOnBuildDir( obj )
if exist( fullfile( obj.BuildDirectory, obj.RelativePathFromBuildDirToSharedUtilDir ), 'dir' )
obj.GenUtilsPath = cd( cd( fullfile( obj.BuildDirectory, obj.RelativePathFromBuildDirToSharedUtilDir ) ) );
else 

fpath = fullfile( obj.BuildDirectory, [ '..', filesep ] );
if exist( fullfile( fpath, obj.RelativePathFromBuildDirToSharedUtilDir ), 'dir' )
obj.GenUtilsPath = cd( cd( fullfile( fpath, obj.RelativePathFromBuildDirToSharedUtilDir ) ) );
end 
end 
end 

function out = getFileInfo_Cached( obj )
out = obj.CachedFileInfo;
if isempty( out )
out = obj.getFileInfo(  );
end 
end 
function out = getSortedFileInfoList_Cached( obj )
out = obj.CachedSortedFileInfoList;
if isempty( out )
out = obj.getSortedFileInfoList(  );
end 
end 

function delete( obj )
if ~isempty( obj.Dlg )
obj.Dlg.close;
end 
end 
end 

methods ( Hidden )
lics = getLicenseRequirements( obj )
buildInfo = getBuildInfo( obj )
out = updateFileInfo( obj )
trimFileSet( obj )
[ extLists, sortedFileInfoList ] = sortGroup( obj, stat_fullNameList, categories, dirFiles )
end 

methods ( Static )
obj = instance( model )
obj = newInstance( model )
clearInstance( model )
setInstance( model, obj )
out = detectBuildFolder( sys, varargin )
obj = loadMat( sys, varargin )
[ out, tmpMdlName, sys ] = getSubsystemBuildFolder( sys )
out = getSInfo( slprjFolder, varargin )
out = newFileInfo( name, group, fileType, filePath, tag )
out = getHTMLFileName( filename )
obj = getReportInfoFromBuildDir( buildFolder )
out = hasToolbar( varargin )
out = DisplayInCodeTrace( varargin )
out = getCommentTag( block, systemMap )
out = getCodeFileCategoryDisplayNames(  )
end 
end 





% Decoded using De-pcode utility v1.2 from file /tmp/tmpdGwj_z.p.
% Please follow local copyright laws when handling this file.

