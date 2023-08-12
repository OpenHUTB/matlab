function report = screener( varargin )

































try 
[ fcnArgs, options, legacyTextMode ] = parseAndValidateArguments( varargin{ : } );
displayUI = ( nargout == 0 );
out = screenerImpl( fcnArgs, options, displayUI, legacyTextMode );
if nargout == 1
report = out;
end 
catch ME

throw( ME );
end 
end 

function [ fcnArgs, options, legacyTextMode ] = parseAndValidateArguments( varargin )
narginchk( 1, inf );

[ optionsArgs, textArgs ] = validateAndPartitionOptionsAndTextArgs( varargin{ : } );

if ~isempty( optionsArgs )
narginchk( 2, inf );
[ fcnArgs, options, legacyTextMode ] = parseAndValidateArgumentsWithOptions( optionsArgs{ : }, textArgs{ : } );
else 
[ fcnArgs, options, legacyTextMode ] = parseAndValidateArgumentsNoOptions( textArgs{ : } );
end 
end 

function [ optionsArgs, textArgs ] = validateAndPartitionOptionsAndTextArgs( varargin )
optionsIdx = cellfun( @( x )isa( x, 'coder.internal.ScreenerOptions' ), varargin );
optionsArgs = varargin( optionsIdx );
textArgs = varargin( ~optionsIdx );


cellfun( @( arg )mustBeText( arg ), textArgs );

if nnz( optionsIdx ) > 1
error( message( 'coderApp:screener:MultipleScreenerOptionsSpecified' ) );
end 
end 

function [ fcnArgs, options, legacyTextMode ] = parseAndValidateArgumentsWithOptions( aOptions, aArgs )
R36
aOptions( 1, 1 )coder.internal.ScreenerOptions
end 
R36( Repeating )
aArgs( 1, : )string{ mustBeNonempty( aArgs ), mustBeNonzeroLengthText( aArgs ) }
end 
narginchk( 2, inf );
[ fcnArgs, options, legacyTextMode ] = parseAndValidateArgumentsImpl( [ aArgs{ : } ], aOptions );
end 

function [ fcnArgs, options, legacyTextMode ] = parseAndValidateArgumentsNoOptions( aArgs )
R36( Repeating )
aArgs( 1, : )string{ mustBeNonempty( aArgs ), mustBeNonzeroLengthText( aArgs ) }
end 
narginchk( 1, inf );
[ fcnArgs, options, legacyTextMode ] = parseAndValidateArgumentsImpl( [ aArgs{ : } ] );
end 

function [ fcnArgs, aOptions, legacyTextMode ] = parseAndValidateArgumentsImpl( aArgs, aOptions )
R36
aArgs( 1, : )string{ mustBeNonempty( aArgs ), mustBeNonzeroLengthText( aArgs ) }
aOptions( 1, 1 )coder.internal.ScreenerOptions = coder.internal.ScreenerOptions
end 

[ hyphenArgs, fcnArgs ] = partitionArgs( aArgs );

if numel( hyphenArgs ) > 1
error( message( 'coderApp:screener:TooManyHyphenedArguments' ) );
end 

legacyTextMode = false;

if ~isempty( hyphenArgs )
switch ( hyphenArgs )
case "-c"
aOptions.Language = "CXX";
case "-gpu"
aOptions.Language = "GPU";
aOptions.FixedPointConversion = false;
case "-text"
legacyTextMode = true;
warning( message( 'coderApp:screener:DeprecatedTextHyphenedArgument' ) );
otherwise 
error( message( 'coderApp:screener:InvalidHyphenedArgument', hyphenArgs ) );
end 
end 
end 

function [ hyphenArgs, fcnArgs ] = partitionArgs( aArgs )





hyphenArgsIdx = strncmp( aArgs, "-", 1 );
hyphenArgs = aArgs( hyphenArgsIdx );
fcnArgs = aArgs( ~hyphenArgsIdx );
end 


function report = screenerImpl( aFcnArgs, aOptions, aDisplayUI, legacyTextMode )
if legacyTextMode
report = screenerLegacyMode( aFcnArgs );
else 
report = screenerNonLegacyMode( aFcnArgs, aOptions, aDisplayUI );
end 
end 

function report = screenerLegacyMode( aFcnArgs )
fcnArgsCell = cellstr( aFcnArgs );
X = coderprivate.emlscreener_kernel( fcnArgsCell{ : } );

coderprivate.emlscreener_genreport( X );

report = X;
end 

function report = screenerNonLegacyMode( aFcnArgs, aOptions, aDisplayUI )
files = resolveFcns( aFcnArgs, aOptions );
pathMap = containers.Map( 'KeyType', 'char', 'ValueType', 'char' );
report = coderapp.internal.screener.screener( files, aDisplayUI, aOptions, pathMap );
end 

function fcns = resolveFcns( aFcnArgs, aOptions )
fcns = arrayfun( @( arg )resolveFcn( arg, aOptions ), aFcnArgs );
end 

function fcn = resolveFcn( aFcnArg, aOptions )
if aOptions.UseEMLWhich
bestWhichResult = coderapp.internal.screener.resolver.getBestEMLWhichResult( aFcnArg );
else 
bestWhichResult = coderapp.internal.screener.resolver.getBestWhichResult( aFcnArg );
end 
if isfile( bestWhichResult )
fcn = bestWhichResult;
else 
absPath = coderapp.internal.util.foundation.absolute( aFcnArg );
if isfile( absPath )
warning( message( 'coderApp:screener:EntryPointNotOnPath', absPath ) );
fcn = absPath;
else 
error( message( 'Coder:common:ProjectFileNotFound', aFcnArg ) );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpzMU19i.p.
% Please follow local copyright laws when handling this file.

