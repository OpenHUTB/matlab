function open( str, options )

















































































































R36
str{ mustBeNonzeroLengthText, mustBeTextScalar }
options.blocks{ mustBeText } = ''
options.verbose{ mustBeMember( options.verbose, { 'on', 'off' } ) } = 'off'
options.resultsPerPage( 1, 1 ){ mustBeInteger, mustBePositive } = 20
end 



persistent slexDDUXLoggerObj;
slexDDUXLoggerObj = modelfinder.internal.dduxLogger;
isNLPInvocation = false;
taggedQuery = '';
decision = '';
resultsMetadata = struct;
actualSearchQuery = str;



verboseFlag = false;
if strcmp( options.verbose, 'on' )
verboseFlag = true;
end 

blocksTerm = options.blocks;

try 
[ str, blocksTerm, isNLPInvocation, taggedQuery ] = processSearchInput( str, blocksTerm, isNLPInvocation, taggedQuery );
resultStruct = modelfinder.internal.queryEngine.search( str, blocksTerm );


if isNLPInvocation && isempty( resultStruct )
[ str, blocksTerm ] = processBackupSearchInput( taggedQuery );
resultStruct = modelfinder.internal.queryEngine.search( str, blocksTerm );
end 
catch 


error( message( 'modelfinder:error:UnknownError' ) );
end 

if isempty( resultStruct )
disp( getString( message( 'modelfinder:error:NoMatchFound' ) ) );


if isSearchDDUXFeatureActive
slexDDUXLoggerObj.collectDDUXData( actualSearchQuery, str, blocksTerm, taggedQuery, resultStruct, resultsMetadata, decision, isNLPInvocation );
end 

return ;
end 


[ resultsOut, resultsMetadata, numResults ] = modelfinder.internal.queryEngine.processResults( resultStruct );


if numResults == 1 && ~verboseFlag && resultsOut.isIndependent
modelfinder.internal.queryEngine.open_system_smart( resultsOut, str );


if isSearchDDUXFeatureActive
decision = '1';
slexDDUXLoggerObj.collectDDUXData( actualSearchQuery, str, blocksTerm, taggedQuery, resultsOut, resultsMetadata, decision, isNLPInvocation );
end 

return ;
end 


maxResults = options.resultsPerPage;

pageNum = 1;
lastFlag = false;
for outIdx = 1:numResults

if outIdx - 1 >= maxResults * pageNum
if resultsOut( outIdx ).isExample || resultsOut( outIdx ).isIndependent || resultsOut( outIdx ).isProject
[ userSelection, decision ] = processUserInput( lastFlag, resultsOut, outIdx, numResults, str );
if ismember( decision, { 'q', 'v' } )
if isSearchDDUXFeatureActive
slexDDUXLoggerObj.collectDDUXData( actualSearchQuery, str, blocksTerm, taggedQuery, resultsOut, resultsMetadata, userSelection, isNLPInvocation );
end 
return ;
end 
pageNum = pageNum + 1;
end 
end 


displayModel( resultsOut( outIdx ), outIdx, verboseFlag );

if outIdx == numResults
lastFlag = true;
[ userSelection, decision ] = processUserInput( lastFlag, resultsOut, outIdx, numResults, str );
if ismember( decision, { 'q', 'v' } )
if isSearchDDUXFeatureActive
slexDDUXLoggerObj.collectDDUXData( actualSearchQuery, str, blocksTerm, taggedQuery, resultsOut, resultsMetadata, userSelection, isNLPInvocation );
end 
return ;
end 
end 
end 
end 


function [ searchTerm, blocksTerm, isNLPInvocation, taggedQuery ] = processSearchInput( searchTerm, blocksTerm, isNLPInvocation, taggedQuery )

if isstring( blocksTerm ) && isscalar( blocksTerm )
blocksTerm = { char( blocksTerm ) };
elseif ischar( blocksTerm )
blocksTerm = { blocksTerm };
else 
blocksTerm = cellfun( @( x )char( x ), blocksTerm, 'UniformOutput', false );
end 

if isempty( blocksTerm{ 1 } )
blocksTerm = '';
end 
searchTerm = char( searchTerm );


if numel( regexp( searchTerm, '\s+', 'split' ) ) > 3
isNLPInvocation = true;
taggedQuery = modelfinder.internal.slNER.tagEntities( string( searchTerm ) );

blocksTerm = taggedQuery.blocks;
searchTerm = strjoin( [ taggedQuery.concepts, taggedQuery.domains, taggedQuery.toolboxes ], ' ' );

if isempty( searchTerm ) && ~isempty( blocksTerm )
searchTerm = '*';
end 
end 
end 

function [ searchTerm, blocksTerm ] = processBackupSearchInput( taggedQuery )
searchTerm = strjoin( struct2array( taggedQuery ), ' ' );
blocksTerm = '';
end 

function displayModel( model, displayIdx, verboseFlag )

displayTitle = regexprep( model.name, ';.*$', '' );

displayLink = model.link;

if model.isProject
displayLink = model.projectPath;
end 

matchedIn = model.matchedIn;
matchedPart = model.matchedPart;
linkedModelPath = model.linkedModelPath;

if model.isExample || model.isProject
if verboseFlag
printDisplayTitle( displayIdx, displayTitle, true );
fprintf( "      Source: %s\n", displayLink );
if ~isempty( linkedModelPath )
[ ~, displayTitle, ~ ] = fileparts( linkedModelPath );
fprintf( "        > %s\n", displayTitle );
printVerboseInformation( linkedModelPath, matchedIn, matchedPart, 10 );
end 
else 
printDisplayTitle( displayIdx, displayTitle, false );
if ~isempty( linkedModelPath )
[ ~, displayTitle, ~ ] = fileparts( linkedModelPath );
fprintf( "        > %s\n", displayTitle );
end 
end 

elseif model.isIndependent
if verboseFlag
printDisplayTitle( displayIdx, displayTitle, true );
printVerboseInformation( displayLink, matchedIn, matchedPart, 6 );
else 
printDisplayTitle( displayIdx, displayTitle, false );
if model.isDuplicateFlag
fprintf( "      %s   %s\n", getString( message( 'modelfinder:error:VerboseModelPath' ) ), fileparts( displayLink ) );
end 
end 
else 
fprintf( "%4d.   > %s\n", displayIdx, displayTitle );
if verboseFlag
printVerboseInformation( displayLink, matchedIn, matchedPart, 10 );
end 
end 
end 

function printDisplayTitle( displayIdx, displayTitle, newLineFlag )
if newLineFlag
displayString = "\n%4d. %s\n";
else 
displayString = "%4d. %s\n";
end 
fprintf( displayString, displayIdx, displayTitle );
end 

function printVerboseInformation( modelPath, matchedIn, matchedPart, indentation )
emptySpace = repmat( ' ', [ 1, indentation ] );
fprintf( "%s%s   %s\n", emptySpace, getString( message( 'modelfinder:error:VerboseModelPath' ) ), modelPath );
fprintf( "%s%s   %s\n", emptySpace, getString( message( 'modelfinder:error:VerboseMatchedIn' ) ), matchedIn );
fprintf( "%s%s %s\n", emptySpace, getString( message( 'modelfinder:error:VerboseMatchedText' ) ), matchedPart );
end 

function selection = validateSelection( userSelection, displayIdx )
if ismember( userSelection, { 'm', 'q' } )
selection = userSelection;
return ;
end 
userSelection = str2double( userSelection );
selection = 'v';

if ( isnan( userSelection ) || userSelection ~= round( userSelection ) || userSelection > displayIdx || userSelection < 1 )
selection = '';
return ;
end 
end 

function [ userSelection, selection ] = processUserInput( lastFlag, resultsToDisplay, displayIdx, numResults, keyword )
if lastFlag
userPrompt = [ getString( message( 'modelfinder:error:InputPromptLastPage' ) ), ' ' ];
else 

fprintf( "\n" );
disp( getString( message( 'modelfinder:error:ShowingMatches', 1, displayIdx - 1, numResults ) ) );
fprintf( "\n" );
userPrompt = [ getString( message( 'modelfinder:error:InputPrompt' ) ), newline, getString( message( 'modelfinder:error:Selection' ) ), ' ' ];
end 

while 1
userSelection = input( userPrompt, 's' );
try 
if lastFlag
selection = validateSelection( userSelection, displayIdx );
else 
selection = validateSelection( userSelection, displayIdx - 1 );
end 
catch 
selection = '';
end 

if selection == 'q'
return ;
elseif selection == 'm' & ~lastFlag
break ;
elseif selection == 'v'
modelfinder.internal.queryEngine.open_system_smart( resultsToDisplay( str2double( userSelection ) ), keyword );
return ;
elseif lastFlag
userPrompt = [ getString( message( 'modelfinder:error:InputPromptLastPageInvalid' ) ), ' ' ];
else 
userPrompt = [ getString( message( 'modelfinder:error:InputPromptInvalid' ) ), newline, getString( message( 'modelfinder:error:Selection' ) ), ' ' ];
end 
end 
end 

function isDDUXLoggingActive = isSearchDDUXFeatureActive(  )
if isSimulinkStarted







if slf_feature( 'get', 'SearchDDUX' ) == 1
isDDUXLoggingActive = true;
return ;
end 
end 
isDDUXLoggingActive = false;
end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpaa58nq.p.
% Please follow local copyright laws when handling this file.

