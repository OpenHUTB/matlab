function [ resultSrcFileList, resultIncludeDir, copiedFiles ] = createResultDir( aASTFileList, options )

arguments
    aASTFileList( 1, : )internal.cxxfe.ast.source.SourceFile
    options.ResultsDir( 1, 1 )string
    options.AggregatedHeaderFilename( 1, 1 )string
    options.AggregateHeaderFiles( 1, 1 ) = false
    options.CopySourceFiles( 1, 1 )logical = false
    options.CleanSourceFiles( 1, 1 )logical = false
    options.OriginalSourceFiles( 1, : )string
    options.IgnoreSystemIncludes( 1, 1 )logical = true
end
filesToCopy = string.empty;
filesToKeep = string.empty;
resultSrcFileList = string.empty;
copiedFiles = string.empty;

if exist( options.ResultsDir, 'dir' ) ~= 7
    createDirectory( options.ResultsDir );
end

if isempty( aASTFileList )

    return ;
end


if polyspace.internal.codeinsight.utils.codeInsightFeature( "PSCleanFile" ) ...
        || polyspace.internal.codeinsight.utils.codeInsightFeature( "PSPreProcessedFile" )
    options.CleanSourceFiles = true;
end



aASTTopLevelFileList = aASTFileList( [ aASTFileList.IsTopLevelFile ] );


firstLevelHeaderDepth = 0;
for aASTFile = aASTTopLevelFileList
    includedFiles = aASTFile.IncludedFiles.toArray;
    includedWrittenNames = string( aASTFile.IncludedFileWrittenNames.toArray );
    for idx = 1:numel( includedFiles )
        [ ~, currDepth ] = getNormalizedPathDepth( fullfile( includedWrittenNames( idx ) ) );
        firstLevelHeaderDepth = max( firstLevelHeaderDepth, currDepth );
    end
end




includeSubPath = "";
if firstLevelHeaderDepth > 0
    includeSubPath = "include";
    if firstLevelHeaderDepth > 1
        includeSubPath = fullfile( "include", strjoin( string( 1:firstLevelHeaderDepth - 1 ), filesep ) );
    end
end

resultIncludeDir = fullfile( options.ResultsDir, includeSubPath, "include" );
if exist( resultIncludeDir, 'dir' ) ~= 7
    createDirectory( resultIncludeDir );
end
resultSrcDir = fullfile( options.ResultsDir, "src" );
if exist( resultSrcDir, 'dir' ) ~= 7
    createDirectory( resultSrcDir );
end

    function createDirIfNeeded( f )



        [ dirname, ~, ~ ] = fileparts( f );
        if ~isempty( dirname )
            targetDir = fullfile( resultIncludeDir, dirname );
            if exist( targetDir, 'dir' ) ~= 7
                createDirectory( targetDir );
            end
        end
    end

    function res = isSameDirAsSrcDir( srcpath, headerpath, headerwritten )
        headerdirInfo = dir( headerpath );
        srcToHeaderdirInfo = dir( fullfile( srcpath, headerwritten ) );
        if ~isempty( srcToHeaderdirInfo )

            res = strcmp( srcToHeaderdirInfo.folder, headerdirInfo.folder );
        else
            res = false;
        end
    end

headerNamesToIgnore = string( [  ] );
if options.AggregateHeaderFiles

    for aASTFile = aASTTopLevelFileList


        if isempty( aASTFile.WrittenName )
            continue ;
        end

        sourceDirInfo = dir( aASTFile.WrittenName );
        originalSrcDir = sourceDirInfo.folder;

        includedFiles = aASTFile.IncludedFiles.toArray;
        includedWrittenNames = string( aASTFile.IncludedFileWrittenNames.toArray );
        if options.IgnoreSystemIncludes
            headerIdxToIgnore = [ includedFiles.IsIncludedFromSystemIncludeDir ];
            headerToIgnore = includedFiles( headerIdxToIgnore );
            headerNamesToIgnore = [ headerNamesToIgnore, string( { headerToIgnore.WrittenName } ) ];%#ok<AGROW>
            includedFiles = includedFiles( ~headerIdxToIgnore );
            includedWrittenNames = includedWrittenNames( ~headerIdxToIgnore );
        end
        includedFiles = includedFiles( [ includedFiles.IsInclude ] );
        includedWrittenNames = includedWrittenNames( [ includedFiles.IsInclude ] );
        hasIncludedFileInSrcDir = false;
        if ~isempty( includedFiles )
            if isSameDirAsSrcDir( originalSrcDir, includedFiles( 1 ).Path, includedWrittenNames( 1 ) )
                hasIncludedFileInSrcDir = true;
            end
            includedHeaderFile = includedWrittenNames( 1 );
            createDirIfNeeded( includedHeaderFile );
            fid = createFile( fullfile( resultIncludeDir, includedHeaderFile ) );

            [ ~, includeGuardMacro, ~ ] = fileparts( includedHeaderFile );
            includeGuardMacro = upper( includeGuardMacro ) + "_H_";
            includeGuardStart = sprintf( "#ifndef %s", includeGuardMacro ) +  ...
                newline + sprintf( "#define %s", includeGuardMacro ) + newline;
            includeGuardEnd = ( "#endif" );
            fprintf( fid, includeGuardStart + "#include """ + options.AggregatedHeaderFilename + """\n" + includeGuardEnd );
            fclose( fid );

            for idx = 2:numel( includedFiles )
                if isSameDirAsSrcDir( originalSrcDir, includedFiles( idx ).Path, includedWrittenNames( idx ) )
                    hasIncludedFileInSrcDir = true;
                end
                includedHeaderFile = includedWrittenNames( idx );
                createDirIfNeeded( includedHeaderFile );
                if exist( fullfile( resultIncludeDir, includedHeaderFile ), 'FILE' ) == 0

                    fid = createFile( fullfile( resultIncludeDir, includedHeaderFile ) );
                    fclose( fid );
                end
            end
        end
        if hasIncludedFileInSrcDir
            filesToCopy( end  + 1 ) = string( aASTFile.WrittenName );%#ok<AGROW>
        else
            filesToKeep( end  + 1 ) = string( aASTFile.WrittenName );%#ok<AGROW>
        end
    end
    if options.CopySourceFiles

        filesToCopy = [ filesToCopy, filesToKeep ];
        filesToKeep = string.empty;
    end
else

    headerMap = containers.Map;
    for aASTFile = aASTFileList
        includedFiles = aASTFile.IncludedFiles.toArray;
        includedWrittenNames = string( aASTFile.IncludedFileWrittenNames.toArray );
        for idx = 1:numel( includedFiles )
            currPath = includedFiles( idx ).Path;
            if headerMap.isKey( currPath )
                currWrittenName = string( includedWrittenNames( idx ) );
                currList = headerMap( currPath );
                if ~ismember( currList, currWrittenName )
                    currList( end  + 1 ) = currWrittenName;%#ok<AGROW>
                    headerMap( currPath ) = currList;
                end
            else
                headerMap( currPath ) = [ string( includedWrittenNames( idx ) ) ];
            end
        end
    end


    if options.IgnoreSystemIncludes
        headerIdxToIgnore = [ aASTFileList.IsIncludedFromSystemIncludeDir ];
        headerToIgnore = aASTFileList( headerIdxToIgnore );
        headerNamesToIgnore = string( { headerToIgnore.WrittenName } );
        aASTFileList = aASTFileList( ~headerIdxToIgnore );
    end
    aASTHeaderFilesToCopy = aASTFileList( [ aASTFileList.IsInclude ] );
    for aASTFile = aASTHeaderFilesToCopy
        if headerMap.isKey( aASTFile.Path )
            for aWrittenName = headerMap( aASTFile.Path )
                createDirIfNeeded( aWrittenName );
                copyfile( aASTFile.Path, fullfile( resultIncludeDir, aWrittenName ) );
            end
        end

    end

    aASTSrcFilesToCopy = aASTFileList( [ aASTFileList.IsInclude ] == false );
    filesToCopy = string( { aASTSrcFilesToCopy.WrittenName } );
end




if options.CopySourceFiles
    for originalSrcFile = options.OriginalSourceFiles

        d = dir( originalSrcFile );
        if ~isempty( d )
            originalSrcFilePath = string( fullfile( d.folder, d.name ) );
        else


            originalSrcFilePath = string( fullfile( originalSrcFile ) );
        end
        if ~ismember( originalSrcFilePath, filesToCopy ) && ~ismember( fullfile( originalSrcFile ), filesToCopy )
            filesToCopy( end  + 1 ) = originalSrcFile;%#ok<AGROW>
        end
    end
end

needFileCopy = ~isempty( filesToCopy );
if needFileCopy






    if ~options.CopySourceFiles

        m = message( 'cxxfe:codeinsight:ForceCopySrc', filesToCopy );
        warning( m );
    end

    for f = filesToCopy
        fileInfo = dir( f );
        resultSrcFile = fullfile( resultSrcDir, fileInfo.name );
        resultSrcFileList( end  + 1 ) = resultSrcFile;%#ok<AGROW>
        if options.CleanSourceFiles
            newcontent = polyspace.internal.codeinsight.utils.cleanFileContent( f );
            fid = fopen( resultSrcFile, 'w' );
            fprintf( fid, "%s", newcontent );
            fclose( fid );
            c_beautifier( char( resultSrcFile ) );
        else
            copyfile( f, resultSrcFile );


            fileattrib( resultSrcFile, '+w' );
        end
        copiedFiles( end  + 1 ) = resultSrcFile;%#ok<AGROW>
    end
end

resultSrcFileList = [ filesToKeep, resultSrcFileList ];

if ~options.AggregateHeaderFiles
    for aSrcFile = aASTFileList
        createUnusedHeader( aSrcFile.Path, headerNamesToIgnore, resultIncludeDir );
    end
end




for aSrcFile = resultSrcFileList
    createUnusedHeader( aSrcFile, headerNamesToIgnore, resultIncludeDir );
end

end

function createUnusedHeader( aFileName, headerNamesToIgnore, resultIncludeDir )
filecontent = string( fileread( fullfile( aFileName ) ) );


filecontent = regexprep( filecontent, '(/\*([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*+/)|(//.*)', '', 'dotexceptnewline' );
includeDirectiveList = regexp( filecontent, '#\s*include\s+((\".+\")|(<.+>))', 'match', 'dotexceptnewline' );

includeWrittenNameList = string( regexp( includeDirectiveList, '((\".+\")|(<.+>))', 'match' ) );
includeWrittenNameList = includeWrittenNameList.replace( [ """", "<", ">" ], "" );
for includeWrittenName = includeWrittenNameList
    if ~ismember( includeWrittenName, headerNamesToIgnore ) && ~isfile( fullfile( resultIncludeDir, includeWrittenName ) )

        [ dirname, ~, ~ ] = fileparts( includeWrittenName );
        if ~isempty( dirname )
            targetDir = fullfile( resultIncludeDir, dirname );
            if exist( targetDir, 'dir' ) ~= 7
                createDirectory( targetDir );
            end
        end
        fid = createFile( fullfile( resultIncludeDir, includeWrittenName ) );
        fclose( fid );
    end
end
end


function [ p, depth ] = getNormalizedPathDepth( p )
C = strsplit( fullfile( p ), filesep );

C( strcmp( C, '.' ) ) = [  ];

idx = 1;
while idx <= numel( C )
    if idx > 1 && strcmp( C{ idx }, '..' ) && ~strcmp( C{ idx - 1 }, '..' )

        C( idx - 1:idx ) = [  ];
        idx = idx - 1;
    else
        idx = idx + 1;
    end
end
p = strjoin( C, filesep );

depth = find( ~strcmp( C, ".." ), 1, 'first' ) - 1;
end

function createDirectory( d )
try
    mkdir( d );
catch Cause
    M1 = MException( message( 'cxxfe:codeinsight:CannotCreateResultDir', d ) );
    M2 = addCause( M1, Cause );
    throw( M2 );
end
end

function fid = createFile( f )
try
    fid = fopen( f, 'w' );
catch Cause
    ME = MException( message( 'cxxfe:codeinsight:CannotCreateResultFile', d ) );
    ME = addCause( ME, Cause );
    throw( ME );
end
end

