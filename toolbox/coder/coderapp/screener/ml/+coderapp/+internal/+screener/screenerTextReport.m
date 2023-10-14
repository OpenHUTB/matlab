function outputReport = screenerTextReport( screenerResultView )

arguments
    screenerResultView( 1, 1 )coderapp.internal.screener.ScreenerResultView
end

summaryTxt = composeSummaryTxt( screenerResultView );
configurationTxt = constructConfigurationTxt( screenerResultView );
issuesTxt = composeIssuesTxt( screenerResultView );

outputReport = strip( char( join( {  ...
    summaryTxt,  ...
    '',  ...
    configurationTxt,  ...
    '',  ...
    issuesTxt,  ...
    }, '' ) ) );
end


function summaryTxt = composeSummaryTxt( screenerResultView )
numIssues = screenerResultView.Messages.Size;
numFiles = length( screenerResultView.Files.keys );
numUnsupportedFunctions = length( screenerResultView.UnsupportedFunctions.toArray );

summaryTxt = char( join( {  ...
    underlineHeader( message( 'coderApp:screener:OverviewHeader' ).getString(  ) ),  ...
    '',  ...
    message( 'coderApp:screener:issueCount', numIssues ).getString(  ),  ...
    message( 'coderApp:screener:unsupportedFunctions', numUnsupportedFunctions ).getString(  ),  ...
    message( 'coderApp:screener:filesAnalyzed', numFiles ).getString(  ),  ...
    '', '' }, newline ) );
end

function configurationTxt = constructConfigurationTxt( screenerResultView )




tgt = screenerResultView.Result.Input.Target;

if ~isempty( tgt )
    configurationTxt = char( join( {  ...
        underlineHeader( message( 'coderApp:screener:ConfigurationHeader' ).getString(  ) ),  ...
        '',  ...
        [ message( 'coderApp:screener:configLanguage' ).getString(  ), ': ', enumMsgText( tgt.Language ) ],  ...
        '', '' }, newline ) );
else
    configurationTxt = '';
end
end

function issuesTxt = composeIssuesTxt( screenerResultView )




underlinedHeader = underlineHeader( message( 'coderApp:screener:IssuesHeader' ).getString(  ) );

if screenerResultView.Messages.Size > 0
    problemsTxt = composeHierarchicalIssues( screenerResultView );
else
    problemsTxt = message( 'coderApp:screener:analysisNoProblems' ).getString(  );
end

issuesTxt = char( join( {  ...
    underlinedHeader,  ...
    '',  ...
    problemsTxt }, newline ) );
end

function hierarchicalIssues = composeHierarchicalIssues( screenerResultView )
messages = screenerResultView.Messages.toArray;
fullMessages = screenerResultView.FullMessages;
buckets = containers.Map;
severities = containers.Map;






messageLocations = [ messages.Location ];
messageStarts = [ messageLocations.Start ];
messageLineNumbers = [ messageStarts.Line ];
[ ~, I ] = sort( messageLineNumbers );
messages = messages( I );


functionNames = arrayfun( @functionNameFromMessage, messages, 'UniformOutput', false );
[ ~, I ] = sort( functionNames );
messages = messages( I );

for msg = messages
    fullMessage = fullMessages{ msg.UUID };
    [ msgText, subMsgText, isDisplayableMessage ] = msgTextFromMessage( fullMessage );
    if isDisplayableMessage
        if ~isKey( buckets, msgText ) && ~isempty( msgText ) && ~isempty( subMsgText )
            buckets( msgText ) = { subMsgText };
            severities( msgText ) = getMessageSeverity( fullMessage );
        else
            buckets( msgText ) = horzcat( buckets( msgText ), { subMsgText } );
        end
    end
end

keysInOrder = string( buckets.keys );


keyOccurances = arrayfun( @( key )length( buckets( key ) ), keysInOrder );
[ ~, I ] = sort( keyOccurances, 'descend' );
keysInOrder = keysInOrder( I );


keySeverities = arrayfun( @( key )severities( key ), keysInOrder );
[ ~, I ] = sort( keySeverities, 'descend' );
keysInOrder = keysInOrder( I );

hierarchicalIssues = bucketsToHierarchicalIssuesText( buckets, keysInOrder );
end

function severity = getMessageSeverity( fullMessage )




if isa( fullMessage.Message, 'coderapp.internal.screener.CallSiteMessage' )
    severity = 3;
elseif fullMessage.Message.Severity == coderapp.internal.screener.MessageSeverity.ERROR
    severity = 2;
elseif fullMessage.Message.Severity == coderapp.internal.screener.MessageSeverity.WARNING
    severity = 1;
end
end

function [ msgText, subMsgText, isDisplayableMessage ] = msgTextFromMessage( fullMessage )




msgText = fullMessage.Text;
subMsgText = '';
loc = fullMessage.Message.Location.Start.Line;
[ functionName, isDisplayableMessage ] = functionNameFromMessage( fullMessage.Message );
if ~isDisplayableMessage




    return ;
end
if isa( fullMessage.Message, 'coderapp.internal.screener.CallSiteMessage' )
    callee = fullMessage.Message.CallSite.Symbol;
    msgText = sprintf( "%s: %s", message( 'coderApp:screener:unsupportedFunction' ).getString(  ), callee );
end
subMsgText = sprintf( "%s (%s)", functionName, message( 'coderApp:screener:lineMessage', loc ).getString(  ) );
end

function [ functionName, isDisplayableMessage ] = functionNameFromMessage( message )



isDisplayableMessage = true;

switch class( message )
    case 'coderapp.internal.screener.CallSiteMessage'
        functionName = message.CallSite.Caller.Path;
    case 'coderapp.internal.screener.FunctionMessage'
        functionName = message.Function.Path;
    otherwise




        functionName = '';
        isDisplayableMessage = false;
end




[ ~, functionName, extension ] = fileparts( functionName );
functionName = strcat( functionName, extension );
end

function issuesTxt = bucketsToHierarchicalIssuesText( buckets, keysInOrder )




arguments
    buckets containers.Map
    keysInOrder( 1, : )string
end
issuesTxt = "";

for key = keysInOrder
    issuesTxt = sprintf( "%s%s (%d)\n", issuesTxt, key, length( buckets( key ) ) );
    for subMsg = buckets( key )
        issuesTxt = sprintf( "%s%s%s\n", issuesTxt, '    - ', subMsg{ 1 } );
    end
end
issuesTxt = char( issuesTxt );
end

function txt = enumMsgText( enumMember )
msgID = coderapp.internal.screener.ui.getMessageIDForEnumMember( enumMember );
txt = message( msgID ).getString(  );
end

function underlinedHeader = underlineHeader( header )
underlineTxt = repmat( '=', 1, length( header ) );
underlinedHeader = char( sprintf( "%s\n%s", header, underlineTxt ) );
end


