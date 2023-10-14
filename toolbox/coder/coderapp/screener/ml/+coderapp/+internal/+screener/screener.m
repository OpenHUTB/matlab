function report = screener( aFileList, aDisplayUI, aOptions, aPathMap )

arguments
    aFileList( 1, : )string{ mustBeNonempty( aFileList ), mustBeNonzeroLengthText( aFileList ), mustBeFile( aFileList ) }
    aDisplayUI( 1, 1 )logical
    aOptions( 1, 1 )coder.internal.ScreenerOptions
    aPathMap{ mustBeA( aPathMap, 'containers.Map' ) }
end

mustBeMFile( aFileList );
aFileList = unique( aFileList );
validateFileList( aFileList, aOptions );

report = runScreenerAnalysis( aFileList, aPathMap, aDisplayUI, aOptions );
end

function report = runScreenerAnalysis( files, pathMap, displayUI, aOptions )
mdl = mf.zero.Model(  );
screenerResult = coderapp.internal.screener.invokeAnalysis( files, aOptions, MfzModel = mdl );

if ~isempty( screenerResult.Result.ExceptionalErrors.toArray )
    warning( message( 'coderApp:screener:ScreenerCLIAnalysisError' ) );
end

if displayUI
    coderapp.internal.screener.ui.Screener( screenerResult );
    report = [  ];
else
    report = codergui.internal.ScreenerInfoBuilder.build( screenerResult, PathMap = pathMap, Model = mdl );
end
end

function mustBeMFile( aFileList )
validExts = [ ".mlx", ".m" ];
for file = aFileList
    [ ~, ~, ext ] = fileparts( file );
    if all( ~strcmpi( ext, validExts ) )
        error( message( 'coderApp:screener:NonMFile', file ) );
    end
end
end

function validateFileList( aFileList, aOptions )
if ~aOptions.AnalyzeMathWorksCode
    for file = aFileList
        if ~coderapp.internal.screener.resolver.isUserFile( file )
            error( message( 'coderApp:screener:MathWorksFunctionAsEntryPoint', file ) );
        end
    end
end
end


