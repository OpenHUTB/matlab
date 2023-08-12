classdef utility < internal.packageConfig.utilityAbstract


methods ( Static )
function package = getPackageInfo( model )

package = [  ];
fileDir = internal.packageConfig.utility.getCachedMATFolderPath;
fileName = [ model, '_ParamConfig.mat' ];
filePath = fullfile( fileDir, fileName );

if exist( filePath, "file" ) &&  ...
~isempty( whos( '-file', filePath, 'var', 'Package' ) )
matObj = matfile( filePath );
package = matObj.Package;
end 
end 
function out = ifDuplicateEntry( rowStructArray, rowStruct )


out = length( find( arrayfun( @( x )strcmp( x.FileName, rowStruct.FileName ) &&  ...
strcmp( x.DestinationFolder, rowStruct.DestinationFolder ),  ...
rowStructArray ) > 0 ) ) > 1;
end 
function out = FMURootFolders

out = { [ 'resources', filesep ],  ...
[ 'sources', filesep ],  ...
[ 'binaries', filesep ],  ...
[ 'documentation', filesep ],  ...
[ 'extra', filesep ] };
end 
function out = sourcePathExist( rowStruct )


sourcePath = fullfile( rowStruct.SourceFolder,  ...
rowStruct.FileName );
out = isfile( sourcePath ) || isfolder( sourcePath );
end 
function out = invalidSourcePath( rowStruct )

out = ~internal.packageConfig.utility.sourcePathExist( rowStruct ) ||  ...
startsWith( pwd, fullfile( rowStruct.SourceFolder,  ...
rowStruct.FileName ) );
end 
function out = BackgroundColor( Color )



switch lower( Color )
case 'red'
out = [ 0.8814, 0.2379, 0.1755, 0.1 ];
case 'yellow'
out = [ 0.9399, 0.7059, 0.1092, 1 ];
otherwise 
assert( false, 'Invalid background color selection' );
end 
end 
function out = statusIconPath( Icon )



switch lower( Icon )
case 'error'
file = 'error_16.png';
case 'caution'
file = 'search_warning.png';
otherwise 
assert( false, 'Invalid status icon selection' )
end 
out =  ...
fullfile( matlabroot, 'toolbox',  ...
'shared', 'dastudio',  ...
'resources', file );
end 
function out = getArch


out = computer( 'arch' );
end 
function ext = getBinaryFileExtension



if isunix
if ~ismac
ext = '.so';
else 
ext = '.dylib';
end 
elseif ispc
ext = '.dll';
end 
end 
function modelBinaryFolder = getModelBinaryFolder( is32BitDLL )



R36
is32BitDLL( 1, 1 )logical = false
end 
out = internal.packageConfig.utility.getArch;
if is32BitDLL && startsWith( out, 'win' )
modelBinaryFolder = strrep( out, '64', '32' );
else 
ActualTag = { 'glnxa', 'maci' };
ReplacementTag = { 'linux', 'darwin' };
modelBinaryFolder = regexprep( out, ActualTag, ReplacementTag );
end 
end 
function out = isIndexFile( RowStruct )


out = strcmp( fullfile( RowStruct.DestinationFolder,  ...
RowStruct.FileName ),  ...
fullfile( 'documentation', 'index.html' ) );
end 
function out = isSourceFile( RowStruct )


out = strcmp( RowStruct.DestinationFolder,  ...
[ 'sources', filesep ] ) &&  ...
ismember( RowStruct.FileType, { '.c', '.h' } );
end 
function out = isModelBinaryFile( RowStruct, ModelName, Generate32BitDLL )

modelBinaryFolderPath =  ...
fullfile( 'binaries',  ...
internal.packageConfig.utility.getModelBinaryFolder( Generate32BitDLL ) );

modelBinaryFileName = [ ModelName ...
, internal.packageConfig.utility.getBinaryFileExtension ];

modelBinaryFilePath =  ...
fullfile( modelBinaryFolderPath, modelBinaryFileName );

out = strcmp( modelBinaryFilePath,  ...
fullfile( RowStruct.DestinationFolder,  ...
RowStruct.FileName ) );
end 
function out = hasFolderWithModelBinary( RowStruct, ModelName, Generate32BitDLL )

out = false;
if strcmp( RowStruct.FileType, 'folder' ) &&  ...
strcmp( RowStruct.FileName,  ...
internal.packageConfig.utility.getModelBinaryFolder( Generate32BitDLL ) )
modelBinaryFileName = strcat( ModelName,  ...
internal.packageConfig.utility.getBinaryFileExtension );
out = isfile( fullfile( RowStruct.SourceFolder, RowStruct.FileName, modelBinaryFileName ) );
end 
end 
function out = isInValidDestinationPath( RowStruct )


if startsWith( RowStruct.DestinationFolder,  ...
internal.packageConfig.utility.FMURootFolders )
DestinationCell =  ...
strsplit( RowStruct.DestinationFolder, filesep, 'CollapseDelimiters', false );
out = any( cellfun( @( x ) ...
ismember( x, { '.', '..' } ) ||  ...
internal.packageConfig.utility.IsInValidFileOrFolder( x ), DestinationCell( 1:end  - 1 ) ) );
else 
out = true;
end 
end 
function FolderPath = updateFileSep( FolderPath )



FolderPathCell =  ...
strsplit( FolderPath, filesep, 'CollapseDelimiters', false );
if isempty( FolderPathCell{ end  } ) && length( FolderPathCell ) > 1
FolderPathCell = FolderPathCell( 1:end  - 1 );
end 

FolderPath = strcat( strjoin( FolderPathCell, filesep ), filesep );
end 
function cachedMATFolderPath = getCachedMATFolderPath

cachedMATFolderPath = fullfile( Simulink.fileGenControl( 'get', 'CacheFolder' ),  ...
'slprj', '_paramConfig' );
end 
function [ InValid ] = IsInValidFileOrFolder( Str )




InValid = any( ismember( '<>:"/\|?*', Str ) ) ||  ...
any( Str < 32 ) ||  ...
isempty( Str );
end 
function [ FolderPath, FileName, FileExt ] = findFileparts( EntityPath )

info = dir( EntityPath );

if ( ~isempty( info ) )
if ( info( 1 ).isdir )
EntityPath = info( 1 ).folder;
else 
EntityPath = fullfile( info( 1 ).folder, info( 1 ).name );
end 
end 
[ FolderPath, FileName, FileExt ] = fileparts( EntityPath );
FileName = strcat( FileName, FileExt );
if isfolder( EntityPath )
FileExt = 'folder';
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpex5gwB.p.
% Please follow local copyright laws when handling this file.

