function [ whichResult, whichResultType ] = emlWhich( aSymbol, aUseCachedSupportPackageRoot )




R36
aSymbol( 1, 1 )string
aUseCachedSupportPackageRoot( 1, 1 )logical
end 



































































import coderapp.internal.screener.meta.*;
results = makeEmptyWhichResults(  );
metadataEntries = findByPathOrSymbol( aSymbol );
redirectionMetadataEntries = metadataEntries( [ metadataEntries.isRedirect ] );
redirectionMetadataEntries = filter( redirectionMetadataEntries, @( entry )~isMethod( entry.path, aSymbol ) );
redirectionMetadataEntries = alphabetizeEMLPathResults( redirectionMetadataEntries );
if ~isempty( redirectionMetadataEntries )
redirectionSymbols = sort( string( redirectionMetadataEntries.redirectsTo ) );
for redirection = redirectionSymbols
results = [ results, emlWhichNoRedirectNoUserPrecedence( redirection ) ];%#ok<AGROW>
end 
end 
results = [ results, emlWhichNoRedirectNoUserPrecedence( aSymbol ) ];
import coderapp.internal.screener.resolver.isUserFile;
results = stable_partition( results, @( x )isUserFile( x.PathOrSymbol, aUseCachedSupportPackageRoot ) );
whichResult = [ results.PathOrSymbol ];
whichResultType = [ results.Type ];
if isempty( whichResult )
whichResult = reshape( string.empty, [ 1, 0 ] );
end 
if isempty( whichResultType )
whichResultType = reshape( coderapp.internal.screener.WhichResultType.empty, [ 1, 0 ] );
end 
end 


function results = emlWhichNoRedirectNoUserPrecedence( aSymbol )



emlResults = getEMLResults( aSymbol );
whichAllResults = getWhichAllResults( aSymbol );
results = [ emlResults, whichAllResults ];
if ~isPrivateFunctionPath( aSymbol )
results = filter( results, @( x )~isPrivateFunctionPath( x.PathOrSymbol ) );
end 
results = stable_partition( results, @( x )isMOrMLXOrBuiltin( x.PathOrSymbol ) );
results = stable_partition( results, @( x )~isMethod( x.PathOrSymbol, aSymbol ) );
results = stable_partition( results, @( x )isWhichResultSupportedForCodegen( x, aSymbol ) );
end 

function result = trimMATLABRoot( aPathArray )





R36
aPathArray( 1, : )string
end 
result = arrayfun( @trimMATLABRootScalar, aPathArray );
function result = trimMATLABRootScalar( aPath )
if startsWith( aPath, matlabroot )
aPath = char( aPath );
result = string( aPath( ( numel( matlabroot ) + 1 ):end  ) );
else 
result = string( aPath );
end 
end 
end 

function results = getEMLResults( aSymbol )
import coderapp.internal.screener.meta.*;
import coderapp.internal.screener.WhichResultType;

metadataResults = findByPathOrSymbol( aSymbol );
emlPathResults = filter( metadataResults, @( entry )isEMLPathFile( entry.path ) || entry.isEMLBuiltin );
emlPathResults = alphabetizeEMLPathResults( emlPathResults );
emlPathResults = stable_partition( emlPathResults, @( entry )entry.isEMLBuiltin );
function result = toWhichResult( entry )
if entry.isEMLBuiltin
result = makeWhichResult( entry.path, WhichResultType.EMLBuiltin );
else 
result = makeWhichResult( entry.path, WhichResultType.EMLPath );
end 
end 
results = arrayfun( @toWhichResult, emlPathResults );
results = results( : )';
end 

function results = alphabetizeEMLPathResults( emlPathResults )
emlPathResultPaths = arrayfun( @( entry )trimMATLABRoot( entry.path ), emlPathResults );
[ ~, idx ] = sort( emlPathResultPaths );
results = emlPathResults( idx );
end 

function results = getWhichAllResults( aSymbol )
import coderapp.internal.screener.WhichResultType;
whichResultStrs = callWhich( aSymbol );
results = arrayfun( @toWhichResult, whichResultStrs );
if ~isempty( results )
[ ~, uniqueIdx ] = unique( [ results.PathOrSymbol ], 'stable' );
results = results( uniqueIdx );
end 
function y = toWhichResult( whichResultStr )
import coderapp.internal.screener.WhichResultType;
import coderapp.internal.screener.resolver.isBuiltIn;
if isBuiltIn( whichResultStr )
y = makeWhichResult( aSymbol, WhichResultType.MATLABBuiltin );
else 
y = makeWhichResult( whichResultStr, WhichResultType.MATLABPath );
end 
end 
end 

function result = isWhichResultSupportedForCodegen( aWhichResult, aSymbol )
import coderapp.internal.screener.WhichResultType

switch ( aWhichResult.Type )
case WhichResultType.EMLBuiltin
result = true;
case WhichResultType.EMLPath
result = isSupportedForCodegen( aWhichResult.PathOrSymbol, aSymbol );
case WhichResultType.MATLABBuiltin
result = false;
case WhichResultType.MATLABPath
result = isSupportedForCodegen( aWhichResult.PathOrSymbol, aSymbol );
end 
end 

function result = isSupportedForCodegen( aPath, aSymbol )




import coderapp.internal.screener.meta.*;
entry = Find.byPath( aPath );
if isempty( entry )
result = false;
elseif isUnsupportedClassMethod( entry, aSymbol )
result = false;
else 
result = entry.MEX || entry.CXX || entry.GPU || entry.HDL || entry.FI || entry.LIB;
end 
end 

function result = isUnsupportedClassMethod( aMetaEntry, aSymbol )
if isMethod( aMetaEntry.path, aSymbol )
result = any( string( aMetaEntry.unsupportedClassMethods ) == string( aSymbol ) );
else 
result = false;
end 
end 

function result = filter( aVector, aPredicate )




predicateValues = arrayfun( aPredicate, aVector );
result = aVector( predicateValues );
end 

function result = stable_partition( aVector, aPredicate )








predicateValues = arrayfun( aPredicate, aVector );
[ ~, idx ] = sort( predicateValues, 'descend' );
result = aVector( idx );
end 

function whichResult = callWhich( symbol )
whichResult = string( coderapp.internal.screener.resolver.callWhich( symbol ) )';
end 

function result = hasCaseInsensitiveExtension( filePath, extension )
R36
filePath( 1, 1 )string
extension( 1, 1 )string
end 
[ ~, ~, ext ] = fileparts( filePath );
result = any( strcmpi( ext, extension ) );
end 

function result = isMOrMLXOrBuiltin( aPath )
R36
aPath( 1, 1 )string
end 
result = hasCaseInsensitiveExtension( aPath, ".m" ) ...
 || hasCaseInsensitiveExtension( aPath, ".mlx" ) ...
 || hasCaseInsensitiveExtension( aPath, "" );
end 

function result = isPrivateFunctionPath( aPath )
R36
aPath( 1, 1 )string
end 
[ base, ~, ~ ] = fileparts( aPath );
[ base, privDir, ~ ] = fileparts( base );
[ ~, privDirParent, ~ ] = fileparts( base );


result = strcmp( privDir, "private" ) && ~startsWith( privDirParent, "@" );
end 

function result = isEMLPathFile( aPath )





R36
aPath( 1, 1 )string
end 
persistent EMLPathDirs;
if isempty( EMLPathDirs )
EMLPathDirs = [ 
fullfile( matlabroot, "toolbox", "eml", "lib", "matlab", "eml" ),  ...
fullfile( matlabroot, "toolbox", "eml", "lib", "matlab", "datafun" ),  ...
fullfile( matlabroot, "toolbox", "eml", "lib", "matlab", "datatypes" ),  ...
fullfile( matlabroot, "toolbox", "eml", "lib", "matlab", "elfun" ),  ...
fullfile( matlabroot, "toolbox", "eml", "lib", "matlab", "elmat" ),  ...
fullfile( matlabroot, "toolbox", "eml", "lib", "matlab", "funfun" ),  ...
fullfile( matlabroot, "toolbox", "eml", "lib", "matlab", "general" ),  ...
fullfile( matlabroot, "toolbox", "eml", "lib", "matlab", "images" ),  ...
fullfile( matlabroot, "toolbox", "eml", "lib", "matlab", "imagesci" ),  ...
fullfile( matlabroot, "toolbox", "eml", "lib", "matlab", "iofun" ),  ...
fullfile( matlabroot, "toolbox", "eml", "lib", "matlab", "lang" ),  ...
fullfile( matlabroot, "toolbox", "eml", "lib", "matlab", "matfun" ),  ...
fullfile( matlabroot, "toolbox", "eml", "lib", "matlab", "ops" ),  ...
fullfile( matlabroot, "toolbox", "eml", "lib", "matlab", "optimfun" ),  ...
fullfile( matlabroot, "toolbox", "eml", "lib", "matlab", "polyfun" ),  ...
fullfile( matlabroot, "toolbox", "eml", "lib", "matlab", "randfun" ),  ...
fullfile( matlabroot, "toolbox", "eml", "lib", "matlab", "sparfun" ),  ...
fullfile( matlabroot, "toolbox", "eml", "lib", "matlab", "specfun" ),  ...
fullfile( matlabroot, "toolbox", "eml", "lib", "matlab", "strfun" ),  ...
fullfile( matlabroot, "toolbox", "eml", "lib", "matlab", "strfun", "validators" ),  ...
fullfile( matlabroot, "toolbox", "eml", "lib", "matlab", "timefun" ),  ...
fullfile( matlabroot, "toolbox", "eml", "lib", "matlab", "validators" ),  ...
fullfile( matlabroot, "toolbox", "eml", "lib", "fixedpoint" ),  ...
fullfile( matlabroot, "toolbox", "aeroblks", "eml" ),  ...
fullfile( matlabroot, "toolbox", "eml", "lib", "scomp" ),  ...
fullfile( matlabroot, "toolbox", "images", "images", "eml" ),  ...
fullfile( matlabroot, "toolbox", "images", "colorspaces", "eml" ),  ...
fullfile( matlabroot, "toolbox", "signal", "eml" ),  ...
fullfile( matlabroot, "toolbox", "shared", "algorithmlowering", "emlauthoring", "intrinsic" ),  ...
fullfile( matlabroot, "toolbox", "vision", "vision", "eml" ),  ...
fullfile( matlabroot, "toolbox", "comm", "comm", "eml" ),  ...
fullfile( matlabroot, "toolbox", "dsp", "dsp", "eml" ),  ...
fullfile( matlabroot, "toolbox", "stats", "eml" ),  ...
fullfile( matlabroot, "toolbox", "wavelet", "eml" ),  ...
fullfile( matlabroot, "toolbox", "fuzzy", "fuzzy", "eml" ),  ...
fullfile( matlabroot, "toolbox", "optim", "eml" ),  ...
fullfile( matlabroot, "toolbox", "shared", "optimlib", "eml" ),  ...
fullfile( matlabroot, "test", "tools", "eml", "codertest_foundation", "eml_path" ),  ...
fullfile( matlabroot, "toolbox", "comm", "commutilities" ),  ...
fullfile( matlabroot, "toolbox", "comm", "comm", "+comm" ),  ...
fullfile( matlabroot, "toolbox", "comm", "comm", "+comm", "+internal" ),  ...
fullfile( matlabroot, "toolbox", "dsp", "dsputilities" ),  ...
fullfile( matlabroot, "toolbox", "dsp", "dsp", "private" ),  ...
fullfile( matlabroot, "toolbox", "dsp", "dsp", "+dsp" ),  ...
fullfile( matlabroot, "toolbox", "signal", "signal", "+internal" ),  ...
fullfile( matlabroot, "toolbox", "vision", "vision" ),  ...
fullfile( matlabroot, "toolbox", "vision", "vision", "+vision" ),  ...
fullfile( matlabroot, "toolbox", "vision", "vision", "+vision", "+private" ) ];
end 
result = contains( aPath, EMLPathDirs );
end 

function result = makeWhichResult( aPathOrSymbol, aWhichResultType )
R36
aPathOrSymbol( 1, 1 )string
aWhichResultType( 1, 1 )coderapp.internal.screener.WhichResultType
end 
result = struct( 'PathOrSymbol', aPathOrSymbol, 'Type', aWhichResultType );
end 

function result = makeEmptyWhichResults(  )
import coderapp.internal.screener.WhichResultType;
result = repmat( makeWhichResult( "", WhichResultType.MATLABPath ), [ 1, 0 ] );
end 

function result = isMethod( aResolvedPathOrSymbol, aSymbol )




import coderapp.internal.util.getQualifiedFileName;
import coderapp.internal.screener.resolver.isBuiltIn;
aSymbol = getQualifiedFileName( aSymbol );
qualifiedResolvedName = string( getQualifiedFileName( aResolvedPathOrSymbol ) );

if qualifiedResolvedName ~= aSymbol

result = true;
elseif isBuiltIn( aResolvedPathOrSymbol )

result = false;
elseif isClassFolderMethodFile( aResolvedPathOrSymbol )


result = true;
else 
result = false;
end 
end 

function result = isClassFolderMethodFile( aFile )
[ parentPath, fileName ] = fileparts( char( aFile ) );
[ ~, parentDirName ] = fileparts( parentPath );
if strcmp( parentDirName, 'private' )
[ ~, parentDirName ] = fileparts( fileparts( parentDirName ) );
end 
if numel( parentDirName ) >= 2 && parentDirName( 1 ) == '@'
result = ~strcmp( parentDirName( 2:end  ), fileName );
else 
result = false;
end 
end 

function entries = findByPathOrSymbol( aPathOrSymbol )
import coderapp.internal.screener.meta.*;
if isfile( aPathOrSymbol )

entries = Find.byPath( aPathOrSymbol );
elseif contains( aPathOrSymbol, filesep )

symbol = coderapp.internal.util.getQualifiedFileName( aPathOrSymbol );
candidates = Find.bySymbol( symbol );
entries = filter( candidates, @( entry )contains( entry.path, aPathOrSymbol ) );
else 

entries = Find.bySymbol( aPathOrSymbol );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmppiN3X2.p.
% Please follow local copyright laws when handling this file.

