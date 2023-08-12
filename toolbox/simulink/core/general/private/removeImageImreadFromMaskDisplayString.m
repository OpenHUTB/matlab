function [ displayStringChanged, fixedString ] = removeImageImreadFromMaskDisplayString( originalString )



displayStringChanged = false;
if iscell( originalString )
originalString = originalString{ 1 };
end 
fixedString = originalString;



if isempty( strfind( originalString, 'imread' ) ) ||  ...
isempty( strfind( originalString, 'image' ) ) ||  ...
~isempty( strfind( originalString, '...' ) ) ||  ...
~isempty( strfind( originalString, '%{' ) )
return ;
end 


originalString = regexprep( originalString, '(^|\n)%.+?(\n|$)', '' );


imageFuncs = extractFunctionFromStr( originalString, '(^|\s|;)', 'image' );
for imageFunc = imageFuncs
[ imageFuncChanged, fixedImageFunc ] = removeImreadFromImageFunc( imageFunc{ 1 } );
if imageFuncChanged

fixedString = strrep( fixedString, imageFunc{ 1 }, fixedImageFunc );
displayStringChanged = true;
end 
end 

if iscell( fixedString )
fixedString = fixedString{ 1 };
end 
end 

function [ imageFuncChanged, filteredImageFunc ] = removeImreadFromImageFunc( imageFunc )



imageFuncChanged = false;
filteredImageFunc = imageFunc;



imreadStrings = extractFunctionFromStr( imageFunc, '^image\s*\(', 'imread' );
if length( imreadStrings ) ~= 1
return ;
end 


originalImreadString = imreadStrings{ 1 };
imreadInteriorString = regexprep( originalImreadString, '^imread\s*\((.+)\)$', '$1' );



if ~isempty( strfind( imreadInteriorString, '://' ) )
return ;
end 























matchFormatStr = createMatchFormatRegExpStr(  );
if length( matchFormatStr ) ~= 1
return ;
end 
matchFormatStr = matchFormatStr{ 1 };



matchFileName = regexp( imreadInteriorString, '^''.+''$', 'match' );
if length( matchFileName ) == 1

matchFileName = matchFileName{ 1 };
testFileName = matchFileName( 2:length( matchFileName ) - 1 );
testFileName = regexprep( testFileName, '''''', '' );
if isempty( strfind( testFileName, '''' ) )
filteredImageFunc = strrep( imageFunc, originalImreadString, matchFileName );
imageFuncChanged = true;
return ;
end 
end 



matchFileNameAndFormatRegExp = sprintf( '^''.+?''\\s*,\\s*''%s''$', matchFormatStr );
matchFileNameAndFormat = regexp( imreadInteriorString, matchFileNameAndFormatRegExp, 'match' );
if length( matchFileNameAndFormat ) == 1
matchFileNameAndFormat = matchFileNameAndFormat{ 1 };
splitFileNameAndFormat = regexp( matchFileNameAndFormat, '''\s*,\s*''[^,]*$' );
if isempty( splitFileNameAndFormat )
return ;
end 


splitFileName = matchFileNameAndFormat( 1:splitFileNameAndFormat );
splitFormat = regexp( matchFileNameAndFormat, sprintf( '''%s''$', matchFormatStr ), 'match' );
if length( splitFormat ) ~= 1
return 
end 
splitFormat = splitFormat{ 1 };


if ~fileExtensionMatchesFormat( splitFileName, splitFormat )
return 
end 

filteredImageFunc = strrep( imageFunc, originalImreadString, splitFileName );
imageFuncChanged = true;
return ;
end 



matchFilenameBrackets = regexp( imreadInteriorString, '^\[.+\]$', 'match' );
if length( matchFilenameBrackets ) == 1
filteredImageFunc = strrep( imageFunc, originalImreadString, matchFilenameBrackets );
imageFuncChanged = true;
return ;
end 



matchFilenameBracketsAndFormatsRegExp = sprintf( '^\\[.+\\]\\s*,\\s*''%s''$', matchFormatStr );
matchFilenameBracketsAndFormats = regexp( imreadInteriorString, matchFilenameBracketsAndFormatsRegExp, 'match' );
if length( matchFilenameBracketsAndFormats ) == 1

matchFilenameBracketsAndFormats = matchFilenameBracketsAndFormats{ 1 };
splitFormat = regexp( matchFilenameBracketsAndFormats, sprintf( '''%s''$', matchFormatStr ), 'match' );
splitFileName = regexp( matchFilenameBracketsAndFormats, '''.+?''\]', 'match' );

if length( splitFormat ) ~= 1 || length( splitFileName ) ~= 1
return 
end 
splitFileName = splitFileName{ 1 };
splitFormat = splitFormat{ 1 };

if ~fileExtensionMatchesFormat( splitFileName, splitFormat )
return ;
end 

filteredImageFunc = strrep( imageFunc, originalImreadString, regexp( imreadInteriorString, '^\[.+\]', 'match' ) );
imageFuncChanged = true;
return ;
end 



matchFullFile = regexp( imreadInteriorString, '^fullfile.*$', 'match' );
if length( matchFullFile ) == 1


fullFileFuncString = extractFunctionFromStr( imreadInteriorString, '^', 'fullfile' );
if strcmp( fullFileFuncString, matchFullFile )
filteredImageFunc = strrep( imageFunc, originalImreadString, imreadInteriorString );
imageFuncChanged = true;
end 
end 



matchFilenameFullfileAndFormatsRegExp = sprintf( '^fullfile.+\\)\\s*,\\s*''%s''$', matchFormatStr );
matchFilenameFullfileAndFormats = regexp( imreadInteriorString, matchFilenameFullfileAndFormatsRegExp, 'match' );
if length( matchFilenameFullfileAndFormats ) == 1

matchFilenameFullfileAndFormats = matchFilenameFullfileAndFormats{ 1 };
fullFileFuncString = extractFunctionFromStr( matchFilenameFullfileAndFormats, '^', 'fullfile' );
filteredImageFunc = strrep( imageFunc, originalImreadString, fullFileFuncString );
imageFuncChanged = true;
return ;
end 
end 

function [ matches ] = fileExtensionMatchesFormat( fileName, format )



matches = false;
if length( format ) < 3
return 
end 

targetExtension = [ '.', format( 2:length( format ) - 1 ) ];
if isempty( strfind( fileName, targetExtension ) )
return ;
end 

matches = true;
end 

function [ funcStrings ] = extractFunctionFromStr( fullString, precursor, funcName )









funcStrings = {  };
funcStarts = regexp( fullString, sprintf( '%s%s\\s*\\(', precursor, funcName ) );


for funcStart = funcStarts

funcString = fullString( funcStart:length( fullString ) );
funcString = funcString( regexp( funcString, funcName ):length( funcString ) );


parenthesesFind = strfind( funcString, '(' );
if isempty( parenthesesFind )
continue ;
end 

numOpenParenthesis = 1;
startParenthesisIndex = parenthesesFind( 1 );
currentlyInsideString = false;




for strIndex = startParenthesisIndex + 1:length( funcString )
if funcString( strIndex ) == '(' && ~currentlyInsideString
numOpenParenthesis = numOpenParenthesis + 1;
elseif funcString( strIndex ) == ')' && ~currentlyInsideString
numOpenParenthesis = numOpenParenthesis - 1;
elseif funcString( strIndex ) == ''''
currentlyInsideString = ~currentlyInsideString;
end 

if numOpenParenthesis <= 0
break ;
end 
end 





if numOpenParenthesis <= 0


funcStrings{ end  + 1 } = funcString( 1:strIndex );%#ok<AGROW>
end 
end 
end 

function [ matchFormatStr ] = createMatchFormatRegExpStr(  )








persistent cachedMatchFormatRegExp;

if ~isempty( cachedMatchFormatRegExp )
matchFormatStr = cachedMatchFormatRegExp;
else 
excludedFormats = { 'cur', 'hdf', 'ico', 'pcx', 'ras', 'xwd' };
matchFormatStr = '(';
formats = imformats;
needsOr = false;
for format = formats
for extension = format.ext

if ~isempty( find( strcmp( excludedFormats, extension ), 1 ) )
continue ;
end 

if needsOr
matchFormatStr = strcat( matchFormatStr, '|', extension );
else 
matchFormatStr = strcat( matchFormatStr, extension );
needsOr = true;
end 
end 
end 
matchFormatStr = strcat( matchFormatStr, ')' );
cachedMatchFormatRegExp = matchFormatStr;
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpBdURMG.p.
% Please follow local copyright laws when handling this file.

