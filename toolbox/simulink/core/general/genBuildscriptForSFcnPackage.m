function buildscriptBody = genBuildscriptForSFcnPackage( fcnName, srcFiles, incPaths, libAndObjFiles, isDebugBuild )




functionName = sprintf( 'mex_%s', fcnName );
functionCall = sprintf( '%s(varargin)', functionName );

functionSignature = sprintf( [ 'function %s\n\n' ], functionCall );
sfunDirRelativePathCreatorVarName = 'sfunDirRelativePathCreator';
commonDirRelativePathCreatorVarName = 'commonDirRelativePathCreator';
archStr = computer( 'arch' );
archStr( ~isstrprop( archStr, 'alphanum' ) ) = '';
mexDirVar = 'mexDir';
archStrVar = 'archStr';
argsStr = sprintf( [  ...
'%s = computer(''arch'');\n' ...
, '%s(~isstrprop(%s,''alphanum'')) = '''';\n' ...
, 'if nargin == 3 && ~any(cellfun(@(x) isempty(x), varargin))\n' ...
, '\t%s = varargin{1};\n' ...
, '\t%s = varargin{2};\n' ...
, '\t%s = varargin{3};\n' ...
, 'else\n' ...
, '\t%s = fullfile(''..'',''..'');\n' ...
, '\t%s = fullfile(''..'',''..'');\n' ...
, '\t%s = fullfile(''..'',[''mex'' %s]);\n' ...
, 'end\n' ...
 ], archStrVar, archStrVar, archStrVar, sfunDirRelativePathCreatorVarName, commonDirRelativePathCreatorVarName, mexDirVar,  ...
sfunDirRelativePathCreatorVarName, commonDirRelativePathCreatorVarName, mexDirVar, archStrVar );

comments = sprintf( [  ...
'\n' ...
, '%% This buildscript is generated for S-Function ''%s''\n' ...
, '%% Use the placeholders to add your custom build commands,\n' ...
, '%% for example, to build a library before invoking the mex command.\n' ...
, '%% These commands for %s are already added. \n' ...
, '%% Note: If this is being used for authoring in Blockset Designer,\n' ...
, '%% paths used in the command are relative to the <projectRoot>,\n' ...
, '%% otherwise, the paths are relative to <workingDir>/slprj.\n' ...
, '%% Please follow the same rules while adding more commands here.\n\n' ...
 ], fcnName, computer( 'arch' ) );

mexFlagVar = 'mexFlags';
mexFlagComments = sprintf( [ '\n' ...
, '%% Please use the following to declare flags to pass to mex command.\n' ] );
if isDebugBuild
mexFlagDecl = sprintf( '%s = {''-g''};', mexFlagVar );
else 
mexFlagDecl = sprintf( '%s = {};', mexFlagVar );
end 
mexFlagDecl = sprintf( '%s%s', mexFlagComments, mexFlagDecl );
slibPaths = {  };slibNames = {  };
libNames = {  };
commonLibNames = {  };

sharedLibExtList = {  };
otherLibObjExtList = {  };
if ismac
sharedLibExtList = { '.dylib' };
otherLibObjExtList = { '.a', '.o' };
elseif isunix
sharedLibExtList = { '.so' };
otherLibObjExtList = { '.a', '.o' };
elseif ispc
sharedLibExtList = { '.dll' };
linkLibExtList = { '.lib' };
otherLibObjExtList = { '.obj', '.lib' };
end 

slibStrCellVar = 'sharedLibList';
winSharedLibList = {  };
commonWinSharedLibList = {  };


for i = 1:numel( sharedLibExtList )
sharedLibExtList{ i } = [ '.', sharedLibExtList{ i } ];
end 
platformList = containers.Map;
allPlatforms = mexext( 'all' );
for i = 1:numel( allPlatforms )
platformList( allPlatforms( i ).arch ) = '';
end 
libFilesToIgnore = containers.Map;
for i = 1:numel( libAndObjFiles )
[ path, name, ext ] = fileparts( libAndObjFiles{ i } );

if ~ispc

if startsWith( name, 'lib' ) && any( contains( sharedLibExtList, ext ) ) && length( name ) > 3




slibPaths = [ slibPaths( : )', { genFullFileCmd( libAndObjFiles{ i } ) } ];
slibNames = [ slibNames( : )', { sprintf( 'sprintf(''-l%%s'',''%s'')', name( 4:end  ) ) } ];

elseif any( contains( sharedLibExtList, ext ) ) || any( contains( otherLibObjExtList, ext ) )










whatToCheck = '';
if strcmp( ext, '.a' ) || strcmp( ext, '.o' )
idx = regexp( path, filesep );
if isequal( idx( end  ), length( path ) )


whatToCheck = path( idx( end  - 1 ):end  );
else 

whatToCheck = path( idx( end  ) + 1:end  );
end 

if ~strcmpi( whatToCheck, computer( 'arch' ) ) && ~strcmp( whatToCheck, archStr ) ...
 && platformList.isKey( whatToCheck )



else 


if isCommonPath( libAndObjFiles{ i } ) && ~strcmp( fcnName, 'common' )
commonLibNames = [ commonLibNames( : )', { genFullFileCmd( libAndObjFiles{ i } ) } ];
else 
libNames = [ libNames( : )', { genFullFileCmd( libAndObjFiles{ i } ) } ];
end 

end 

else 


if ~libFilesToIgnore.isKey( [ name, ext ] )
if isCommonPath( libAndObjFiles{ i } ) && ~strcmp( fcnName, 'common' )
commonLibNames = [ commonLibNames( : )', { genFullFileCmd( libAndObjFiles{ i } ) } ];
else 
libNames = [ libNames( : )', { genFullFileCmd( libAndObjFiles{ i } ) } ];
end 
end 
end 

end 
elseif ispc








isObjFile = strcmp( ext, '.obj' );
isLinkLib = strcmp( ext, '.lib' );




if isLinkLib
isObjFile = false;
for f = 1:numel( libAndObjFiles )
[ ~, libN, libE ] = fileparts( libAndObjFiles{ f } );
isLinkLib = strcmp( libN, name ) && any( contains( sharedLibExtList, libE ) );
if isLinkLib
break 
end 
end 
end 

if ~any( contains( sharedLibExtList, ext ) )
if ~isLinkLib || isObjFile
if isCommonPath( libAndObjFiles{ i } ) && ~strcmp( fcnName, 'common' )
commonLibNames = [ commonLibNames( : )', { genFullFileCmd( libAndObjFiles{ i } ) } ];
else 
libNames = [ libNames( : )', { genFullFileCmd( libAndObjFiles{ i } ) } ];
end 
elseif isLinkLib && ~isObjFile
if startsWith( name, 'lib' )
slibNames = [ slibNames( : )', { sprintf( 'sprintf(''-l%%s'',''%s'')', name( 4:end  ) ) } ];
else 
slibNames = [ slibNames( : )', { sprintf( 'sprintf(''-l%%s'',''%s'')', name ) } ];
end 



if isCommonPath( path ) && ~strcmp( fcnName, 'common' )
commonWinSharedLibList = [ commonWinSharedLibList( : )' ...
, { sprintf( 'sprintf(''-L%%s'',fullfile(%s,%s))', commonDirRelativePathCreatorVarName, genFullFileCmd( path ) ) } ];
else 
winSharedLibList = [ winSharedLibList( : )' ...
, { sprintf( 'sprintf(''-L%%s'',fullfile(%s,%s))', sfunDirRelativePathCreatorVarName, genFullFileCmd( path ) ) } ];
end 
end 
end 
end 
end 

winSharedLibList = [ winSharedLibList( : )', commonWinSharedLibList( : )' ];



outputFileNameVar = 'outputFileName';
outputFileStr = sprintf( '%s = fullfile(%s, [''%s.'' mexext]);\n', outputFileNameVar, mexDirVar, fcnName );
outputFileStr = sprintf( '%sif ~isfolder(%s)\n\tmkdir(%s);\nend\n\n', outputFileStr, mexDirVar, mexDirVar );









sLibNameVar = 'sLibNames';
sLibMexDirDef = sprintf( '%s = {[''-L'' fullfile(%s)]};\n', slibStrCellVar, mexDirVar );

slibListCellFunComments = sprintf( [  ...
'\n%% Shared libraries in S-Function package are stored in the dedicated\n' ...
, '%% mex directory. The following provides the path of mex directory\n' ...
, '%% to mex command with ''-L'' flag. To add more such paths, please\n' ...
, '%% use this variable: %s = [%s(:)'' {''-L<absolutePathToSomeSharedLibraryFolder>''}]\n' ...
, '%% and %s = [%s(:)'' {''-l<nameOfLibrary>''}]\n' ...
, '%% Note: In addition to above, you might also need to\n' ...
, '%% add shared library to system paths, for example, LD_LIBRARY_PATH on glnxa64.\n' ...
, '%% On windows, use this variable to provide path of each link library instead.\n' ...
 ], slibStrCellVar, slibStrCellVar, sLibNameVar, sLibNameVar );
slibListCellFun = sprintf( '%s%s\n', slibListCellFunComments, sLibMexDirDef );






ldflagVar = 'ldflagList';
unixLdFlagStr = sprintf( '\t%s = sprintf(''LDFLAGS="$LDFLAGS -Wl,-rpath,\\\\$ORIGIN"'');\n', ldflagVar );
macLdFlagStr = sprintf( '\t%s = '''';\n', ldflagVar );
pcLdFlagStr = sprintf( '\t%s = '''';\n', ldflagVar );

macPathProcFunc = 'procMacSharedLibPath';
macPathProcFuncStr = sprintf( [  ...
'function oldPath = %s(slibName)\n' ...
, 'oldPath = '''';\n' ...
, 'if ~isfile(slibName)\n' ...
, '    return\n' ...
, 'end\n' ...
, 'systemCmd = [''otool -D '' slibName];\n' ...
, '[status, cmdOut] = system(systemCmd);\n' ...
, 'if status == 1\n' ...
, '    return\n' ...
, 'end\n' ...
, 'outCellArray = split(cmdOut,newline);\n' ...
, 'if numel(outCellArray) < 2\n' ...
, '\treturn\n' ...
, 'end\n' ...
, 'oldPath = outCellArray{2};\n' ...
, 'end\n' ], macPathProcFunc );

macSysCmdVarName = 'macSysCmds';
symLinkPathsVarName = 'symLinkPaths';
macPathProcFuncCallSite = sprintf( [  ...
'if ismac\n' ...
, '\t%s = {};\n' ...
, '\tfor i = 1:numel(%s)\n' ...
, '    \toldPath = %s(%s{i});\n' ...
, '    \tif isempty(oldPath)\n' ...
, '    \t\treturn\n' ...
, '    \tend\n' ...
, '    \t[~,n,ext] = fileparts(%s{i});\n' ...
, '    \tlibName = [n ext];\n' ...
, '    \tsysCmd = [''install_name_tool -change ''...\n' ...
, '        \toldPath '' @loader_path/'' libName...\n' ...
, '        \t'' '' %s];\n' ...
, '    \t%s = [%s(:)'' {sysCmd}];\n' ...
, '\tend\n' ...
, 'end\n\n' ], macSysCmdVarName, symLinkPathsVarName, macPathProcFunc, symLinkPathsVarName,  ...
symLinkPathsVarName, outputFileNameVar, macSysCmdVarName, macSysCmdVarName );

macPathProcComments = sprintf( [  ...
'\n%% For runtime linking on Mac only.\n' ] );
invokeMacSysCmdsStr = sprintf( [ 
'%s' ...
, 'if ismac\n' ...
, '    for i = 1:numel(%s)\n' ...
, '        system(%s{i});\n' ...
, '    end\n' ...
, 'end\n' ], macPathProcComments,  ...
macSysCmdVarName, macSysCmdVarName );
commonSLibPaths = {  };
sfunSLibPaths = {  };
slibPaths = slibPaths( cellfun( @isempty, slibPaths ) == 0 );
for i = 1:numel( slibPaths )

if isCommonPath( slibPaths{ i } ) && ~strcmp( fcnName, 'common' )
commonSLibPaths = [ commonSLibPaths( : )', slibPaths{ i } ];
else 
sfunSLibPaths = [ sfunSLibPaths( : )', slibPaths{ i } ];
end 
end 

symLinkPathStr = '';
sfunSLibPathListVarName = 'sfunSLibPathList';
sfunSLibPathComments = sprintf( [  ...
'\n%% This cell array will contain shared library paths, including the names (so, dll, dylib)\n' ...
, '%% These will be located under <modelWorkingDir>/slprj/sfunName/mex<arch>/\n' ...
 ] );
sfunSLibPathListDefaultDecl = sprintf( [ '%s%s = {};\n' ], sfunSLibPathComments, sfunSLibPathListVarName );
sfunSLibPathListDefaultDeclNoComments = sprintf( [ '%s = {};' ], sfunSLibPathListVarName );
if ~isempty( sfunSLibPaths )
sfunSLibPathListStrVal = sprintf( [ '%s,...\n\t' ], sfunSLibPaths{ : } );
sfunSLibPathListStr = sprintf( [ '%s = {%s};' ], sfunSLibPathListVarName, sfunSLibPathListStrVal( 1:end  - 6 ) );
else 
sfunSLibPathListStr = sfunSLibPathListDefaultDeclNoComments;
end 
sfunSLibPathListCellFun = sprintf( '%s = cellfun(@(x) fullfile(%s, x), %s, ''UniformOutput'',false);\n',  ...
sfunSLibPathListVarName, sfunDirRelativePathCreatorVarName, sfunSLibPathListVarName );

commonSLibPathListVarName = 'commonSLibPathList';
commonSLibPathComments = sprintf( [  ...
'\n%% The following will contain shared library paths, including the names (so, dll, dylib) common to\n' ...
, '%% multiple S-Functions when in scope of Blockset Designer Project\n' ...
, '%% These will be located in <toolboxInstallDir>/common/\n' ...
 ] );
commonSLibPathListDefaultDecl = sprintf( [ '%s%s = {};\n' ], commonSLibPathComments, commonSLibPathListVarName );
commonSLibPathListDefaultDeclNoComments = sprintf( [ '%s = {};' ], commonSLibPathListVarName );
if ~isempty( commonSLibPaths )
commonSLibPathListStrVal = sprintf( [ '%s,...\n\t' ], commonSLibPaths{ : } );
commonSLibPathListStr = sprintf( [ '%s = {%s};' ], commonSLibPathListVarName, commonSLibPathListStrVal( 1:end  - 6 ) );
else 
commonSLibPathListStr = commonSLibPathListDefaultDeclNoComments;
end 
commonSLibPathListCellFun = sprintf( '%s = cellfun(@(x) fullfile(%s, x), %s, ''UniformOutput'',false);\n',  ...
commonSLibPathListVarName, commonDirRelativePathCreatorVarName, commonSLibPathListVarName );

sLibNameComments = sprintf( [  ...
'\n%% The following is used to add shared library names (so, dll, dylib)\n' ...
, '%% with -l (small L) prefex.\n' ...
 ] );
sLibNameDefaultDecl = sprintf( [ '%s%s = {};\n' ], sLibNameComments, sLibNameVar );
if isempty( slibNames )
sLibNameDefaultDeclNoComments = sprintf( [ '%s = {};\n' ], sLibNameVar );
else 
slibNameStr = sprintf( [ '%s,...\n\t' ], slibNames{ : } );
sLibNameDefaultDeclNoComments = sprintf( [ '%s = {%s};' ], sLibNameVar, slibNameStr( 1:end  - 6 ) );
end 
if ispc && ~isempty( winSharedLibList )

linkLibListVal = sprintf( [ '%s,...\n\t' ], winSharedLibList{ : } );
additionalWinDecl = sprintf( '%s = [%s(:)'' {%s}];', slibStrCellVar, slibStrCellVar, linkLibListVal( 1:end  - 6 ) );
symLinkPathStr = sprintf( '\t%s\n\t%s\n\t%s\n\t%s\n', additionalWinDecl, sfunSLibPathListStr,  ...
commonSLibPathListStr, sLibNameDefaultDeclNoComments );
else 
symLinkPathStr = sprintf( '\t%s\n\t%s\n\t%s\n', sfunSLibPathListStr,  ...
commonSLibPathListStr, sLibNameDefaultDeclNoComments );
end 
symLinkPathsDecl = sprintf( '%s = [%s(:)'' %s(:)''];\n', symLinkPathsVarName,  ...
sfunSLibPathListVarName, commonSLibPathListVarName );

libStrCellVar = 'libList';
libListComments = sprintf( [  ...
'\n%% The following will contain object and static libraries (a, o, obj, lib)\n' ...
, '%% These will be located in <modelWorkingDir>/slprj/sfunName/libs/\n' ...
 ] );
libListDefaultDecl = sprintf( [ '%s%s = {};\n' ], libListComments, libStrCellVar );
libListDefaultDeclNoComments = sprintf( [ '%s = {};' ], libStrCellVar );
if ~isempty( libNames )
libStrVal = sprintf( [ '%s,...\n\t' ], libNames{ : } );
libStr = sprintf( [ '%s = {%s};' ], libStrCellVar, libStrVal( 1:end  - 6 ) );
else 
libStr = libListDefaultDeclNoComments;
end 
libListCellFun = sprintf( '%s = cellfun(@(x) fullfile(%s, x), %s, ''UniformOutput'',false);\n',  ...
libStrCellVar, sfunDirRelativePathCreatorVarName, libStrCellVar );

commonLibStrCellVar = 'commonLibList';
commonLibComments = sprintf( [  ...
'\n%% The following will contain object and static libraries (a, o, obj, lib) common to\n' ...
, '%% multiple S-Functions when in scope of Blockset Designer Project\n' ...
, '%% These will be located in <toolboxInstallDir>/common/\n' ...
 ] );
commonLibDefaultDecl = sprintf( [ '%s%s = {};\n' ], commonLibComments, commonLibStrCellVar );
commonLibDefaultDeclNoComments = sprintf( [ '%s = {};' ], commonLibStrCellVar );
if ~isempty( commonLibNames )
commonLibStrVal = sprintf( [ '%s,...\n\t' ], commonLibNames{ : } );
commonLibStr = sprintf( [ '%s = {%s};' ], commonLibStrCellVar, commonLibStrVal( 1:end  - 6 ) );
else 
commonLibStr = commonLibDefaultDeclNoComments;
end 
commonLibListCellFun = sprintf( '%s = cellfun(@(x) fullfile(%s, x), %s, ''UniformOutput'',false);\n',  ...
commonLibStrCellVar, commonDirRelativePathCreatorVarName, commonLibStrCellVar );






defaultBinCommentStr = sprintf( [  ...
'\n' ...
, '%% The following variables should be used to provide paths to\n' ...
, '%% binary files/folders being used with this S-Function. Please add values\n' ...
, '%% to these cells for each platform you intend to use this S-Function on\n' ...
, '%% in placeholders for each platform defined in this file.\n' ...
, '%% Please see the description in the comments to find out the\n' ...
, '%% usage of the variables defined.\n' ...
 ] );

defaultBinPathsDecl = [  ...
defaultBinCommentStr ...
, slibListCellFun ...
, libListDefaultDecl ...
, commonLibDefaultDecl ...
, sLibNameDefaultDecl ...
, sfunSLibPathListDefaultDecl ...
, commonSLibPathListDefaultDecl ];
srcFileList = {  };
commonSrcFileList = {  };
srcFiles = srcFiles( cellfun( @isempty, srcFiles ) == 0 );
for i = 1:numel( srcFiles )
if isCommonPath( srcFiles{ i } ) && ~strcmp( fcnName, 'common' )
commonSrcFileList = [ commonSrcFileList( : )', { genFullFileCmd( srcFiles{ i } ) } ];
else 
srcFileList = [ srcFileList( : )', { genFullFileCmd( srcFiles{ i } ) } ];
end 
end 

srcFileListVarName = 'srcFileList';
srcFileComments = sprintf( '\n%% The following defines source files (C,C++)\n' );
if ~isempty( srcFileList )
srcFileListStrVal = sprintf( [ '%s,...\n\t' ], srcFileList{ : } );
srcFileListStr = sprintf( [ '%s = {%s};' ], srcFileListVarName, srcFileListStrVal( 1:end  - 6 ) );
else 
srcFileListStr = sprintf( [ '%s = {};' ], srcFileListVarName );
end 
srcFileListStr = sprintf( '%s%s', srcFileComments, srcFileListStr );
srcFileListCellFun = sprintf( '%s = cellfun(@(x) fullfile(%s, x), %s, ''UniformOutput'',false);\n',  ...
srcFileListVarName, sfunDirRelativePathCreatorVarName, srcFileListVarName );

commonSrcFileComments = sprintf( [  ...
'\n%% The following defines source files (C,C++) common to\n' ...
, '%% multiple S-Functions when in scope of Blockset Designer Project\n' ...
 ] );
commonSrcFileListVarName = 'commonSrcFileList';
if ~isempty( commonSrcFileList )
commonSrcFileListStrVal = sprintf( [ '%s,...\n\t' ], commonSrcFileList{ : } );
commonSrcFileListStr = sprintf( [ '%s = {%s};' ], commonSrcFileListVarName, commonSrcFileListStrVal( 1:end  - 6 ) );
else 
commonSrcFileListStr = sprintf( [ '%s = {};' ], commonSrcFileListVarName );
end 
commonSrcFileListStr = sprintf( '%s%s', commonSrcFileComments, commonSrcFileListStr );
commonSrcFileListCellFun = sprintf( '%s = cellfun(@(x) fullfile(%s, x), %s, ''UniformOutput'',false);\n',  ...
commonSrcFileListVarName, commonDirRelativePathCreatorVarName, commonSrcFileListVarName );

incPathList = {  };
commonIncPathList = {  };
incPaths = incPaths( cellfun( @isempty, incPaths ) == 0 );
for i = 1:numel( incPaths )
if isCommonPath( incPaths{ i } ) && ~strcmp( fcnName, 'common' )
commonIncPathList = [ commonIncPathList( : )', { sprintf( 'sprintf(''-I%%s'',%s)', genFullFileCmd( incPaths{ i } ) ) } ];
else 
incPathList = [ incPathList( : )', { sprintf( 'sprintf(''-I%%s'',%s)', genFullFileCmd( incPaths{ i } ) ) } ];
end 
end 

incPathListStrVarName = 'incPathList';
incPathComments = sprintf( '\n%% The following defines header file paths (h,hpp)\n' );
if ~isempty( incPathList )
incPathListStrVal = sprintf( [ '%s,...\n\t' ], incPathList{ : } );
incPathListStr = sprintf( [ '%s = {%s};' ], incPathListStrVarName, incPathListStrVal( 1:end  - 6 ) );
else 
incPathListStr = sprintf( [ '%s = {};' ], incPathListStrVarName );
end 
incPathListStr = sprintf( '%s%s', incPathComments, incPathListStr );
incPathListCellFun = sprintf( '%s = cellfun(@(x) [x(1:2) fullfile(%s, x(3:end))], %s, ''UniformOutput'',false);\n',  ...
incPathListStrVarName, sfunDirRelativePathCreatorVarName, incPathListStrVarName );

commonIncPathListStrVarName = 'commonIncPathList';
commonIncPathComments = sprintf( [  ...
'\n%% The following defines header file paths (h,hpp) common to\n' ...
, '%% multiple S-Functions when in scope of Blockset Designer Project\n' ...
 ] );
if ~isempty( commonIncPathList )
commonIncPathListStrVal = sprintf( [ '%s,...\n\t' ], commonIncPathList{ : } );
commonIncPathListStr = sprintf( [ '%s = {%s};' ], commonIncPathListStrVarName, commonIncPathListStrVal( 1:end  - 6 ) );
else 
commonIncPathListStr = sprintf( [ '%s = {};' ], commonIncPathListStrVarName );
end 
commonIncPathListStr = sprintf( '%s%s', commonIncPathComments, commonIncPathListStr );
commonIncPathListCellFun = sprintf( '%s = cellfun(@(x) [x(1:2) fullfile(%s, x(3:end))], %s, ''UniformOutput'',false);',  ...
commonIncPathListStrVarName, commonDirRelativePathCreatorVarName, commonIncPathListStrVarName );

relativePathMakerComments = sprintf( [  ...
'%% Please do not modify the below segment. The following commands\n' ...
, '%% convert the paths so that they are relative to this buildscript.\n' ] );
relativePathMaker = sprintf( [  ...
'\n%s%s%s%s%s%s%s' ...
 ],  ...
relativePathMakerComments,  ...
libListCellFun, commonLibListCellFun,  ...
srcFileListCellFun, commonSrcFileListCellFun,  ...
incPathListCellFun, commonIncPathListCellFun,  ...
sfunSLibPathListCellFun, commonSLibPathListCellFun );

mexCommand = sprintf( [ 'mex(%s{:},''-output'',%s,%s,%s{:},%s{:},%s{:},%s{:},%s{:},%s{:},%s{:},%s{:});' ],  ...
mexFlagVar, outputFileNameVar, ldflagVar, srcFileListVarName, commonSrcFileListVarName, incPathListStrVarName,  ...
commonIncPathListStrVarName, slibStrCellVar, sLibNameVar, libStrCellVar, commonLibStrCellVar );


archStrDefault = sprintf( [ '\t%% Placeholder for custom build commands.\n' ...
, '\t%% Add build commands for platform specific build for the S-Function ''%s''\n\n' ], fcnName );

archToMexMap = containers.Map(  );
allMex = mexext( 'all' );
for i = 1:numel( allMex )
archToMexMap( allMex( i ).arch ) = allMex( i ).ext;
end 

symLinkCmdVar = 'symLinkCmd';
unixLinkCmd = sprintf( '\t%s = ''ln -s'';\n', symLinkCmdVar );
pcLinkCmd = sprintf( '\t%s = ''mklink'';\n', symLinkCmdVar );

binFileListDecl = sprintf( '\t%s\n\t%s\n%s\n',  ...
libStr, commonLibStr, symLinkPathStr );

if ismac
ifStr = sprintf( [ '\nif ismac\n', '%s', '%s\n%s\n', '%s', 'elseif isunix\n', '%s%s\n', '%s', 'elseif ispc\n', '%s%s\n', '%s', 'end\n' ],  ...
archStrDefault, binFileListDecl, unixLinkCmd, macLdFlagStr, archStrDefault, unixLinkCmd, unixLdFlagStr, archStrDefault, pcLinkCmd, pcLdFlagStr );
elseif isunix
ifStr = sprintf( [ '\nif ismac\n', '%s%s\n', '%s', 'elseif isunix\n', '%s', '%s\n%s\n', '%s', 'elseif ispc\n', '%s%s\n', '%s', 'end\n' ],  ...
archStrDefault, unixLinkCmd, macLdFlagStr, archStrDefault, binFileListDecl, unixLinkCmd, unixLdFlagStr, archStrDefault, pcLinkCmd, pcLdFlagStr );
elseif ispc
ifStr = sprintf( [ '\nif ismac\n', '%s%s\n', '%s', 'elseif isunix\n', '%s%s\n', '%s', 'elseif ispc\n', '%s', '%s\n%s\n', '%s', 'end\n' ],  ...
archStrDefault, unixLinkCmd, macLdFlagStr, archStrDefault, unixLinkCmd, unixLdFlagStr, archStrDefault, binFileListDecl, pcLinkCmd, pcLdFlagStr );
end 

symLinkPathCreator = sprintf( [  ...
'\n' ...
, '%s' ...
, 'for i = 1:numel(%s)\n' ...
, '\n\t%% Create a symbolic link to this shared library in mex folder' ...
, '\n\t%% if it does not exist already.' ...
, '\n\t[~,n,e] = fileparts(%s{i});' ...
, '\n\tif isfile(fullfile(%s, [n e]))' ...
, '\n\t\tcontinue' ...
, '\n\tend' ...
, '\n\tif ispc' ...
, '\n\t\tcmdStr = [%s '' '' fullfile(%s, [n e]) '' '' %s{i}];' ...
, '\n\telse' ...
, '\n\t\tcmdStr = [%s '' '' %s{i} '' '' %s];' ...
, '\n\tend' ...
, '\n\tsystem(cmdStr);' ...
, '\nend\n\n' ...
 ], symLinkPathsDecl, symLinkPathsVarName, symLinkPathsVarName, mexDirVar, symLinkCmdVar, mexDirVar, symLinkPathsVarName, symLinkCmdVar, symLinkPathsVarName, mexDirVar );

fileListDecl = sprintf( [ '%s\n\n%s\n\n%s\n\n%s\n\n\n' ], srcFileListStr, commonSrcFileListStr,  ...
incPathListStr, commonIncPathListStr );

buildscriptBody = sprintf( [ '%s%s%s%s%s%s%s%s%s%s%s%s\n%s\nend\n\n%s' ], functionSignature, argsStr, comments,  ...
outputFileStr, mexFlagDecl, fileListDecl, defaultBinPathsDecl, ifStr, relativePathMaker, symLinkPathCreator, macPathProcFuncCallSite, mexCommand, invokeMacSysCmdsStr, macPathProcFuncStr );

end 





function fcmd = genFullFileCmd( path )

if isempty( path )
fcmd = '';
return 
end 

fcmd = sprintf( [ 'fullfile(' ] );
idx = regexp( path, filesep );

for i = 1:numel( idx ) - 1
if isequal( i, 1 )
if isequal( idx( 1 ), 1 )
fcmd = sprintf( [ '%sfilesep,''%s''' ], fcmd, path( idx( i ) + 1:idx( i + 1 ) - 1 ) );

else 
startStr = sprintf( [ '%s' ], path( 1:idx( i ) - 1 ) );
startStr = sprintf( [ '''%s'',''%s''' ], startStr, path( idx( i ) + 1:idx( i + 1 ) - 1 ) );
fcmd = sprintf( [ '%s%s' ], fcmd, startStr );
end 

else 
fcmd = sprintf( [ '%s,''%s''' ], fcmd, path( idx( i ) + 1:idx( i + 1 ) - 1 ) );
end 
end 
if strcmp( fcmd( end  ), ',' ) && numel( idx ) > 1
fcmd = fcmd( 1:end  - 1 );
end 

if numel( idx ) > 1
fcmd = sprintf( [ '%s,''%s'')' ], fcmd, path( idx( end  ) + 1:end  ) );
elseif isequal( numel( idx ), 1 )
if isequal( idx( 1 ), 1 )
fcmd = sprintf( [ '%s''filesep'',''%s'') ' ], fcmd, path( idx( 1 ) + 1:end  ) );

else 
fcmd = sprintf( [ '%s''%s'',''%s'')' ], fcmd, path( 1:idx( 1 ) - 1 ), path( idx( 1 ) + 1:end  ) );
end 
end 

startingIdx = length( '''fullfile(' );

idx = strfind( fcmd, '''slprj''' );


if ( ~isempty( idx ) ) || ( numel( idx ) >= 2 && isequal( startingIdx, idx( 1 ) ) && isequal( idx( 1 ) + length( '''slprj''' ) + 1, idx( 2 ) ) ) ...
 && ( isequal( startingIdx, idx( 1 ) ) )
if numel( fcmd ) <= idx( 1 ) + length( '''slprj''' )
fcmd = [ fcmd( 1:idx( 1 ) - 1 ), fcmd( idx( 1 ) + length( '''slprj''' ):end  ) ];
else 
fcmd = [ fcmd( 1:idx( 1 ) - 1 ), fcmd( idx( 1 ) + length( '''slprj''' ) + 1:end  ) ];
end 
end 
end 

function res = isCommonPath( path )



res = false;
startingIdx = length( '''fullfile(' );


if startsWith( path, 'fullfile(' )
idx = strfind( path, '''common''' );
else 
idx = strfind( genFullFileCmd( path ), '''common''' );
end 
if ~isempty( idx ) && isequal( idx( 1 ), startingIdx )
res = true;
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmprOE6i1.p.
% Please follow local copyright laws when handling this file.

