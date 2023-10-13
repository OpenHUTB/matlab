function [ result, raw, mfzModel ] = invokeScreenerForJavaApp( files, screenerTarget, resultBuilder )
arguments
    files{ mustBeA( files, [ "cell", "char", "string", "java.util.Collection" ] ) }
    screenerTarget{ mustBeA( screenerTarget, [ "char", "string", "com.mathworks.toolbox.coder.screener.ScreenerTarget" ] ) } = 'C'
    resultBuilder( 1, 1 ){ mustBeA( resultBuilder, "com.mathworks.toolbox.coder.screener.CallTreeImpactModelBuilder" ) } = com.mathworks.toolbox.coder.screener.CallTreeImpactModelBuilder(  )%#ok<*JAPIMATHWORKS>
end

if nargout > 1


    nargoutchk( 3, 3 );
end
if isjava( files )
    files = cellfun( @( f )string( f.getAbsolutePath(  ) ), cell( files.toArray(  ) ) );
else
    files = string( files );
end

[ raw, mfzModel ] = invokeScreener( files, string( screenerTarget ) );
result = convertToJavaResult( resultBuilder, raw, files, screenerTarget );
end


function [ raw, mfzModel ] = invokeScreener( files, screenerTarget )
arguments
    files string
    screenerTarget( 1, 1 )string
end

nargoutchk( 2, 2 );
import coderapp.internal.screener.Environment;
import coderapp.internal.screener.Language;

env = Environment.LIB;
lang = Language.CXX;
useFi = false;

switch screenerTarget
    case 'C'
        env = Environment.LIB;
    case 'MEX'
        env = Environment.MEX;
    case 'FIXED_POINT'
        env = Environment.MEX;
        useFi = true;
    case 'HDL'
        lang = Language.HDL;
        useFi = true;
    case 'GPU'
        lang = Language.GPU;
    otherwise
        error( 'Unrecognized screener target: %s', screenerTarget );
end
opts = coder.internal.ScreenerOptions( 'Environment', string( env ), 'Language', string( lang ), 'FixedPointConversion', useFi );
[ raw, mfzModel ] = coderapp.internal.screener.invokeAnalysis( files, opts );
end


function result = convertToJavaResult( builder, raw, inputPaths, screenerTarget )
import coderapp.internal.screener.FileType;
if ~isjava( screenerTarget )
    screenerTarget = com.mathworks.toolbox.coder.screener.ScreenerTarget.valueOf( screenerTarget );
end
builder.setScreenerTarget( screenerTarget );

files = raw.Files.toArray(  );
filePaths = { files.Path };
builder.withRoots( intersect( inputPaths, filePaths ) );
builder.withUnresolvedRoots( setdiff( inputPaths, filePaths ) );
CRLF = sprintf( "\r\n" );

for fcn = raw.Result.Functions.toArray
    if fcn.IsMathWorksAuthored || fcn.FileType == FileType.BuiltIn
        continue
    end
    builder.newFile( fcn.Path );





    fileObj = raw.Files.getByKey( fcn.Path );
    if ~isempty( fileObj )
        crlfPos = strfind( fileObj.Contents, CRLF );
        crAdjust = zeros( 1, strlength( fileObj.Contents ) );
        crAdjust( crlfPos ) = 1;
        crAdjust = cumsum( crAdjust );
    else
        assert( fcn.CallSites.Size == 0 && fcn.Messages.Size == 0,  ...
            'Not expecting information for a Function without a File' );
        crAdjust = [  ];
    end


    calls = fcn.CallSites.toArray(  );

    if ~isempty( calls )


        callees = [ calls.Callee ];
        isBuiltin = [ callees.FileType ] == FileType.BuiltIn;
        calleePaths = { callees.Path };
        calleePaths( isBuiltin ) = fullfile( matlabroot, 'toolbox', '__builtin__', calleePaths( isBuiltin ) );
        builder.addDependencies( calleePaths );

        isSupported = [ calls.IsSupported ];
        calls( isSupported ) = [  ];
        calleePaths( isSupported ) = [  ];
    end


    if ~isempty( calls )
        for i = 1:numel( calls )
            call = calls( i );
            location = call.Location;
            builder.addUnsupportedCall(  ...
                call.Symbol,  ...
                calleePaths{ i },  ...
                int32( location.Start.Offset - crAdjust( location.Start.Offset ) - 1 ),  ...
                int32( location.End.Offset - crAdjust( location.End.Offset ) ),  ...
                int32( location.Start.Line ) );
        end
    end


    for msg = fcn.Messages.toArray(  )
        if isCodeAnalyzerWarning( msg )
            continue ;
        end
        switch msg.Type
            case 'UNSUPPORTED_CALL_SITE'
            otherwise
                location = msg.Location;
                builder.addMessage(  ...
                    toJavaProblemTypeName( msg.Type ),  ...
                    raw.FullMessages{ msg.UUID }.Text,  ...
                    int32( location.Start.Offset - crAdjust( location.Start.Offset ) - 1 ),  ...
                    int32( location.End.Offset - crAdjust( location.End.Offset ) ),  ...
                    int32( location.Start.Line ) );
        end
    end
end

result = builder.getCallTreeImpactModel(  );
end


function javaName = toJavaProblemTypeName( messageType )
arguments
    messageType( 1, 1 )coderapp.internal.screener.ScreenerMessageType
end

import coderapp.internal.screener.ScreenerMessageType;
switch messageType
    case {
            ScreenerMessageType.CELL_ARRAY
            ScreenerMessageType.TRY_CATCH
            ScreenerMessageType.NESTED_FUNCTION
            ScreenerMessageType.UNSUPPORTED_CALL_SITE
            }
        javaName = char( messageType );
    otherwise
        javaName = 'SYNTAX_ERROR';
end
end

function result = isCodeAnalyzerWarning( aMessage )
import coderapp.internal.screener.ScreenerMessageType;
import coderapp.internal.screener.MessageSeverity;
result = aMessage.Type == ScreenerMessageType.NON_CODEGEN_MESSAGE && aMessage.Severity == MessageSeverity.WARNING;
end



