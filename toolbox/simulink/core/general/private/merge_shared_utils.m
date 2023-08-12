function [ lLinkObjChecksumPatch, buildInfoSubFolders ] =  ...
merge_shared_utils( topMdl, wkrSharedUtils, mastSharedUtils, wkrModel,  ...
lMasterAnchorFolder, isProtectedModelOrPackagedModelExtraction )






slprivate( 'validateSharedUtils', wkrModel, wkrSharedUtils, mastSharedUtils );


if ispc
suDelFiles = { 'const_params.obj' };
else 
suDelFiles = { 'const_params.o' };
end 


if ( rtwprivate( 'rtw_is_cpp_build', topMdl ) )
langExtension = '.cpp';
else 
langExtension = '.c';
end 






rtwsharedFiles = dir( fullfile ...
( wkrSharedUtils, [ coder.internal.SharedUtilities.SharedLibName, '.*' ] ) );
rtwsharedFiles = { rtwsharedFiles.name };


suMergeFiles = [ suDelFiles ...
, rtwsharedFiles ...
, { 'rtwtypes.h' ...
, 'rtwtypeschksum.mat' ...
, 'sharedutilschecksum.mat' ...
, 'tflSUInfo.mat' ...
, 'fileMap.mat' ...
, 'buildInfo.mat' ...
, 'simTargetObjsInMasterFolder.txt' ...
, [ 'const_params', langExtension ] ...
, 'sil' ...
, 'instrumented' } ];


buildInfoSubFolders = { '', 'instrumented', 'sil/hostobj', 'sil/hostobj/instrumented' };
buildInfoFiles = fullfile( wkrSharedUtils, buildInfoSubFolders, 'buildInfo.mat' );
idx = isfile( buildInfoFiles );
buildInfoSubFolders = buildInfoSubFolders( idx );


locMergeBuildInfo( lMasterAnchorFolder, wkrSharedUtils, mastSharedUtils, buildInfoSubFolders );







lLinkObjChecksumPatch =  ...
coder.make.internal.mergeCompileFolder ...
( wkrSharedUtils, mastSharedUtils, buildInfoSubFolders );


wkrDirStruct = dir( wkrSharedUtils );
wkrFiles = setdiff( { wkrDirStruct( : ).name }, [ suMergeFiles, '.', '..' ] );

mastDirStruct = dir( mastSharedUtils );
mastFiles = setdiff( { mastDirStruct( : ).name }, [ suMergeFiles, { '.', '..' } ] );

commonFiles = wkrFiles( ismember( wkrFiles, mastFiles ) );
commonStruct = wkrDirStruct( ismember( { wkrDirStruct( : ).name }, commonFiles ) );
commonDirs = { commonStruct( [ commonStruct( : ).isdir ] ).name };

directCopyFiles = setdiff( wkrFiles, mastFiles );






Simulink.internal.io.FileSystem.robustMkdir( mastSharedUtils );




rtwprivate( 'parwrap_genSharedCode', topMdl, mastSharedUtils,  ...
wkrSharedUtils, true, wkrModel, isProtectedModelOrPackagedModelExtraction );


if ~isempty( directCopyFiles )
for i = 1:length( directCopyFiles )
wkrFile = fullfile( wkrSharedUtils, directCopyFiles{ i } );
mastFile = fullfile( mastSharedUtils, directCopyFiles{ i } );
Simulink.internal.io.FileSystem.robustCopy( wkrFile, mastFile );
end 
end 


if ~isempty( commonDirs )
for i = 1:length( commonDirs )
wkrDir = fullfile( wkrSharedUtils, commonDirs{ i } );
mastDir = fullfile( mastSharedUtils, commonDirs{ i } );
locCheckCopyCommonDir( wkrDir, mastDir, suMergeFiles );
end 
end 


coder.internal.parwrapGenRTWTYPESDOTH( mastSharedUtils, wkrSharedUtils );


for i = 1:length( suDelFiles )
fname = fullfile( mastSharedUtils, suDelFiles{ i } );
if ( exist( fname, 'file' ) == 2 )
builtin( 'delete', fname );
end 
end 
end 



function locCheckCopyCommonDir( src, dst, suMergeFiles )










srcDirStruct = dir( src );
srcFiles = setdiff( { srcDirStruct( : ).name }, [ suMergeFiles, '.', '..' ] );

dstDirStruct = dir( dst );
dstFiles = setdiff( { dstDirStruct( : ).name }, [ suMergeFiles, { '.', '..' } ] );
directRmFiles = { dstDirStruct( ismember( { dstDirStruct( : ).name }, suMergeFiles ) ).name };

commonFiles = srcFiles( ismember( srcFiles, dstFiles ) );
commonStruct = srcDirStruct( ismember( { srcDirStruct( : ).name }, commonFiles ) );
commonDirs = { commonStruct( [ commonStruct( : ).isdir ] ).name };

directCopyFiles = setdiff( srcFiles, dstFiles );



if ~isempty( directRmFiles )
for i = 1:length( directRmFiles )
mastFile = fullfile( dst, directRmFiles{ i } );
builtin( 'delete', mastFile );
end 
end 


if ~isempty( directCopyFiles )
for i = 1:length( directCopyFiles )
wkrFile = fullfile( src, directCopyFiles{ i } );
mastFile = fullfile( dst, directCopyFiles{ i } );
Simulink.internal.io.FileSystem.robustCopy( wkrFile, mastFile );
end 
end 


if ~isempty( commonDirs )
for i = 1:length( commonDirs )
wkrDir = fullfile( src, commonDirs{ i } );
mastDir = fullfile( dst, commonDirs{ i } );
locCheckCopyCommonDir( wkrDir, mastDir, suMergeFiles );
end 
end 

return ;
end 



function locMergeBuildInfo( lMasterAnchorFolder, wkrSharedUtils, mastSharedUtils,  ...
buildInfoSubFolders )

for i = 1:length( buildInfoSubFolders )
workerBuildInfo = fullfile( wkrSharedUtils, buildInfoSubFolders{ i }, 'buildInfo.mat' );
masterBuildInfo = fullfile( mastSharedUtils, buildInfoSubFolders{ i }, 'buildInfo.mat' );

biWorker = load( workerBuildInfo );
if ~isfile( masterBuildInfo )

biMaster = biWorker;


biMaster.buildInfo.Settings.LocalAnchorDir = lMasterAnchorFolder;
updateFilePathsAndExtensions( biMaster.buildInfo );
p = fileparts( masterBuildInfo );
if ~isfolder( p )
Simulink.internal.io.FileSystem.robustMkdir( p )
end 
save( masterBuildInfo, '-struct', 'biMaster' );
else 

biMaster = load( masterBuildInfo );


workerSources = getSourceFiles( biWorker.buildInfo, true, false );


masterSources = getSourceFiles( biMaster.buildInfo, true, false );


newSources = setdiff( workerSources, masterSources );
[ p, f, e ] = cellfun( @( x )fileparts( x ), newSources,  ...
'UniformOutput', false );
addSourceFiles( biMaster.buildInfo,  ...
convertStringsToChars( string( f ) + string( e ) ), p );



buildInfoSharedIsUpToDate = coder.internal.updateSharedSourceBuildInfo ...
( biMaster.buildInfo, biWorker.buildInfo );

if ~buildInfoSharedIsUpToDate || ~isempty( newSources )

save( masterBuildInfo, '-struct', 'biMaster' );
end 

end 
end 
end 






% Decoded using De-pcode utility v1.2 from file /tmp/tmpYiLQqy.p.
% Please follow local copyright laws when handling this file.

