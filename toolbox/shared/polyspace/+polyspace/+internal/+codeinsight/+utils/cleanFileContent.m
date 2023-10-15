function newcontent = cleanFileContent( sourceFile )

reIntroduceStdHeaderFiles = polyspace.internal.codeinsight.utils.codeInsightFeature( "PSCleanFile" );

newcontent = processFileContent( sourceFile,  ...
    'RemoveAllPragmas', true,  ...
    'RemoveEmptyLines', false,  ...
    'reIntroduceStdHeaderFiles', reIntroduceStdHeaderFiles,  ...
    'RemoveLinePragmas', true );
end

function newcontent = processFileContent( sourceFile, options )
arguments
    sourceFile( 1, 1 )string
    options.RemoveEmptyLines logical = false
    options.RemoveLinePragmas logical = true
    options.RemoveAllPragmas logical = false
    options.reIntroduceStdHeaderFiles logical = false
    options.RemovePatterns( 1, : )string = [  ]
end

content = fileread( sourceFile );
newcontent = string( content );
if options.reIntroduceStdHeaderFiles
    newcontent = polyspace.internal.codeinsight.utils.reIntroduceStdHeaderFiles( newcontent );
end

if ~isempty( options.RemovePatterns )
    for pattern = options.RemovePatterns
        replaceWith = options.RemovePatterns;
        replaceWith( : ) = "";
        newcontent = regexprep( newcontent, options.RemovePatterns, replaceWith );
    end
end

if options.RemoveLinePragmas
    newcontent = regexprep( newcontent, '# [0-9]+.*', '', 'lineanchors', 'dotexceptnewline' );
end

if options.RemoveEmptyLines
    newcontent = regexprep( newcontent, { '\r', '\n\n+' }, { '', '\n' } );
end

contentLines = split( newcontent, newline );
lineNb = numel( contentLines );
linesToKeep = ones( 1, lineNb, 'logical' );
for idx = 1:lineNb
    currentLine = contentLines( idx );
    currentLine = strip( currentLine );
    if options.RemoveEmptyLines && ( isempty( currentLine ) || currentLine == "" )
        linesToKeep( idx ) = false;
        continue ;
    end
    if options.RemoveLinePragmas && startsWith( currentLine, "#line" )
        contentLines( idx ) = "";
        continue ;
    end
    if options.RemoveAllPragmas && ( startsWith( currentLine, "#pragma" ) || startsWith( currentLine, "__pragma" ) )
        contentLines( idx ) = "";
    end
end
newcontentLines = contentLines( linesToKeep );
newcontent = join( newcontentLines, newline );
end
