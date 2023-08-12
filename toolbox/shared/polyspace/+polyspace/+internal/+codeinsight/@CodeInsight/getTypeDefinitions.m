function res = getTypeDefinitions( self, typeList )





R36
self( 1, 1 )polyspace.internal.codeinsight.CodeInsight
typeList( 1, : )internal.cxxfe.ast.types.Type
end 

res = [  ];
for srcFile = self.SourceFiles


tmpObj = polyspace.internal.codeinsight.CodeInsight;
tmpObj.SourceFiles = srcFile;
tmpObj.IncludeDirs = self.IncludeDirs;
tmpObj.Defines = self.Defines;
tmpDir = tempname( fullfile( tempdir, 'CodeInsight' ) );
if ~isfolder( tmpDir )
mkdir( tmpDir );
clrObj = onCleanup( @(  )rmdir( tmpDir, 's' ) );
end 



[ ~, ~, ext ] = fileparts( srcFile );
tempFile = fullfile( tmpDir, [ 'tempfile', char( ext ) ] );
tmpObj.parse( 'DoGenCleanPreProcessedFile', true, 'GenCleanPreProcessedFileOutput', tempFile );

resObj = polyspace.internal.codeinsight.CodeInsight;
resObj.SourceFiles = tempFile;
if ~resObj.parse
error( "Parse error during getTypeDefinitions" );
end 

cUnit = resObj.CodeInfo.AST.Project.Compilations.at( 1 );
co = cUnit.Annotations.toArray;
if ( co.Types.Size > 0 )

typeToConsider = co.Types.toArray;
typeToConsider = typeToConsider( [ typeToConsider.IsDefined ] );

typeToConsiderType = [ typeToConsider.Type ];
typeToConsiderCond = arrayfun( @( x )isTypeToConsider( x ), typeToConsiderType );
typeToConsider = typeToConsider( typeToConsiderCond );
if ~isempty( typeToConsider )
res = [ res, getTypeIncludes( typeToConsider, typeList ) ];%#ok<AGROW>
end 
end 
end 
if ~isempty( res )


resClean = strrep( res, "{ ", "{" );
resClean = strrep( resClean, " }", "}" );
[ ~, IA, ~ ] = unique( resClean, 'stable' );
res = res( IA );
end 
end 

function res = isTypeToConsider( aType )
res = ~aType.isQualifiedType ...
 && ~aType.isPointerType ...
 && ~aType.isFunctionType ...
 && ~isempty( aType.DefPos ) ...
 && ~isempty( aType.DefPos.File );
end 

function res = extractCode( SourceRange, filecontent )


block = filecontent( SourceRange.Start.Line:SourceRange.End.Line );
if ( SourceRange.Start.Col > 1 ) && ( SourceRange.Start.Col < strlength( block( 1 ) ) - 1 )
block( 1 ) = block( 1 ).extractAfter( SourceRange.Start.Col - 1 );
end 
if ( SourceRange.End.Col > 0 ) && ( SourceRange.End.Col < strlength( block( end  ) ) - 1 )

tmp = strtrim( block( end  ).extractBefore( SourceRange.End.Col + 2 ) );
if tmp.endsWith( ";" )
block( end  ) = tmp;
else 
block( end  ) = tmp + ";";
end 
end 
res = block.join( newline );
end 

function typeIncludes = getTypeIncludes( typeInfoList, typelist )
typeIncludes = string( [  ] );
seenTypesUUID = string.empty;
fileContentMap = containers.Map;




tDef = struct( 'def', {  }, 'srcRange', {  } );


typeInfoTypeList = [ typeInfoList.Type ];

isPSCleanFile = polyspace.internal.codeinsight.utils.codeInsightFeature( "PSCleanFile" );
function extractTypeIncludes( t )
if ismember( t.UUID, seenTypesUUID )
return ;
end 
seenTypesUUID( end  + 1 ) = t.UUID;

typeInfoIdx = getTypeInfo( typeInfoTypeList, t );
currDef = struct( 'def', {  }, 'srcRange', {  } );
stopBasedTypePropagation = false;
if typeInfoIdx > 0
if isPSCleanFile
if polyspace.internal.codeinsight.utils.isLibFunction( t.Name )
return ;
end 
end 

typeInfo = typeInfoList( typeInfoIdx );

if ~isempty( t.Name ) && ( ~isempty( typeInfo.DefinitionSourceRange ) )
currFile = typeInfo.DefinitionSourceRange.Start.File.Path;
if fileContentMap.isKey( currFile )
filecontent = fileContentMap( currFile );
else 
filecontent = split( string( fileread( currFile ) ), newline );
fileContentMap( currFile ) = filecontent;
end 




if typeInfo.DefinitionSourceRange.Start.File.IsInclude
includeStr = "#include """ + typeInfo.DefinitionSourceRange.Start.File.Name + """";
currDef = struct( 'def', includeStr, 'srcRange', typeInfo.DefinitionSourceRange );
else 
currDefTxt = extractCode( typeInfo.DefinitionSourceRange, filecontent );
if ( isEnumTypeAndRequireDefinitionGeneration( t, currDefTxt ) )




if t.isEnumType(  )
currDef = struct( 'def', getEnumDef( t ), 'srcRange', typeInfo.DefinitionSourceRange );
else 
if t.isTyperefType && t.isTypedefType(  ) && t.getUnderlyingType( t ).isEnumType(  )
underlayingType = t.getUnderlyingType( t );
if isempty( underlayingType.Name )
currDef = struct( 'def', getTypedefEnumDef( t ), 'srcRange', typeInfo.DefinitionSourceRange );
stopBasedTypePropagation = true;
else 


currDef = struct( 'def', "typedef enum " + underlayingType.Name + " " + t.Name + ";", 'srcRange', [  ] );
end 
end 
end 
else 
currDef = struct( 'def', currDefTxt, 'srcRange', typeInfo.DefinitionSourceRange );
end 
end 
end 
end 
if t.isBasedType(  ) && ~stopBasedTypePropagation
extractTypeIncludes( t.Type );
end 
if t.isStructType(  )
members = t.Members.toArray;
for mIdx = 1:numel( members )
extractTypeIncludes( members( mIdx ).Type );
end 
end 
if t.isUnionType(  )
members = t.Members.toArray;
for mIdx = 1:numel( members )
extractTypeIncludes( members( mIdx ).Type );
end 
end 

if t.isFunctionType(  )
paramTypes = t.ParamTypes.toArray;
for mIdx = 1:numel( paramTypes )
extractTypeIncludes( paramTypes( mIdx ) );
end 
extractTypeIncludes( t.RetType );
end 

if ~isempty( currDef )
include = currDef.def;
if ~ismember( include, typeIncludes )
tDef( end  + 1 ) = currDef;
end 
end 
end 
if ~isempty( typelist )
for t = typelist
extractTypeIncludes( t );
end 
end 






toKeep = ones( 1, numel( tDef ) );
for currIdx = 1:numel( tDef )
currRange = tDef( currIdx ).srcRange;
for otherIdx = currIdx + 1:numel( tDef )
otherRange = tDef( otherIdx ).srcRange;
if isRangeIncludedIn( currRange, otherRange )
toKeep( currIdx ) = 0;
break ;
else 
if isRangeIncludedIn( otherRange, currRange )
toKeep( otherIdx ) = 0;
end 
end 
end 
end 
tDef = tDef( logical( toKeep ) );
typeIncludes = [ tDef.def ];
end 

function res = isRangeIncludedIn( range1, range2 )
if isempty( range1 ) || isempty( range2 )
res = false;
return ;
end 
s1 = range1.Start.Line;
s2 = range2.Start.Line;
if s2 > s1
res = false;
else 
if ( s2 == s1 && range2.Start.Col >= range1.Start.Col )
res = false;
else 

e1 = range1.End.Line;
e2 = range2.End.Line;
if e2 < e1
res = false;
else 
if ( e2 == e1 && range2.End.Col <= range1.End.Col )
res = false;
else 
res = true;
end 
end 
end 
end 
end 

function tInfoIdx = getTypeInfo( typeInfoTypeList, aType )
tInfoIdx =  - 1;
currName = aType.Name;
potentials = find( strcmp( { typeInfoTypeList.Name }, currName ) );
for idx = potentials
currType = typeInfoTypeList( idx );
if strcmp( class( currType ), class( aType ) )
tInfoIdx = idx;
return ;
end 
end 
end 

function typedefEnumDef = getTypedefEnumDef( aType )
if aType.isTypedefType(  )
underlayingType = aType.getUnderlyingType( aType );
if underlayingType.isEnumType(  )
typedefEnumDef = "typedef " + getEnumDef( underlayingType, false ) + " " + aType.Name + ";";
end 
end 
end 

function enumDef = getEnumDef( aType, endIt )
if nargin < 2
endIt = true;
end 
if aType.isEnumType(  )
if isempty( aType.Name )
enumDef = "enum {" + newline;
else 
enumDef = "enum " + aType.Name + "{" + newline;
end 
tags = string( aType.Strings.toArray );
values = string( aType.Values.toArray );
tagDef = join( tags + " = " + values, "," + newline );
enumDef = enumDef + tagDef + newline + "}";
if endIt
enumDef = enumDef + ";";
end 
end 
end 

function res = isEnumTypeAndRequireDefinitionGeneration( aType, defTxt )
res = false;
if aType.isEnumType(  ) || aType.isTyperefType && aType.isTypedefType(  ) && aType.getUnderlyingType( aType ).isEnumType(  )

underlayingType = aType.getUnderlyingType( aType );

buffer = regexprep( defTxt, '/\*.*?\*/', '' );
for idx = 1:underlayingType.Values.Size
value = underlayingType.Values.at( idx );
if ~buffer.contains( value )
res = true;
return ;
end 
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpUebywV.p.
% Please follow local copyright laws when handling this file.

