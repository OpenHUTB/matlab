classdef CodeInsight < handle




    properties
        SourceFiles( 1, : )string{ polyspace.internal.codeinsight.CodeInsight.mustBeNonEmptyString( SourceFiles ) }
        HeaderFiles( 1, : )string{ polyspace.internal.codeinsight.CodeInsight.mustBeNonEmptyString( HeaderFiles ) }
        IncludeDirs( 1, : )string{ polyspace.internal.codeinsight.CodeInsight.mustBeNonEmptyString( IncludeDirs ) }
        Defines( 1, : )string{ polyspace.internal.codeinsight.CodeInsight.mustBeNonEmptyString( Defines ) }
        ParsingOptions internal.cxxfe.FrontEndOptions
        CodeInfo( 1, : )polyspace.internal.codeinsight.CodeInfo
        StubInfo( 1, : )polyspace.internal.codeinsight.CodeInsight
        HarnessInfo( 1, : )polyspace.internal.codeinsight.CodeInsight
        SandboxInfo( 1, : )polyspace.internal.codeinsight.CodeInsight
        Errors
        Debug logical = false
    end

    methods
        function self = CodeInsight( namedargs )
            arguments
                namedargs.SourceFiles( 1, : )string{ polyspace.internal.codeinsight.CodeInsight.mustBeNonEmptyString( namedargs.SourceFiles ) }
                namedargs.HeaderFiles( 1, : )string{ polyspace.internal.codeinsight.CodeInsight.mustBeNonEmptyString( namedargs.HeaderFiles ) }
                namedargs.IncludeDirs( 1, : )string{ polyspace.internal.codeinsight.CodeInsight.mustBeNonEmptyString( namedargs.IncludeDirs ) }
                namedargs.Defines( 1, : )string{ polyspace.internal.codeinsight.CodeInsight.mustBeNonEmptyString( namedargs.Defines ) }
                namedargs.ParsingOptions( 1, 1 )internal.cxxfe.FrontEndOptions
                namedargs.Debug logical = false
            end
            if isfield( namedargs, 'SourceFiles' )
                self.SourceFiles = strip( namedargs.SourceFiles );
            end
            if isfield( namedargs, 'HeaderFiles' )
                self.HeaderFiles = strip( namedargs.HeaderFiles );
            end
            if isfield( namedargs, 'IncludeDirs' )
                self.IncludeDirs = namedargs.IncludeDirs;
            end
            if isfield( namedargs, 'Defines' )
                self.Defines = namedargs.Defines;
            end
            if isfield( namedargs, 'ParsingOptions' )
                self.ParsingOptions = namedargs.ParsingOptions;
            end
            self.Debug = namedargs.Debug;
        end

        success = parse( self, options );
        success = createSandbox( self, options );
        success = createFileHarness( self, options );
        success = generateStubFile( self, options );
        typeDefinitions = getTypeDefinitions( self, typeList );
    end

    methods ( Access = private, Hidden )

        function out = printStartStatus( ~, msg, verbose )
            if verbose
                fprintf( "start -- %s --\n", msg );
                if nargout > 0
                    out = tic;
                else
                    tic;
                end
            else
                out = [  ];
            end
        end

        function printEndStatus( ~, msg, verbose, startTime )
            if verbose
                if nargin < 4
                    stepDuration = toc;
                else
                    stepDuration = toc( startTime );
                end
                fprintf( "end -- %s -- took %s\n", msg, seconds( stepDuration ) );
            end
        end

        function printStatus( ~, msg, verbose )
            if verbose
                fprintf( "log -- %s --\n", msg );
            end
        end

        function checkProperties( self )

            for f = self.SourceFiles
                if exist( f, 'file' ) ~= 2
                    error( message( 'cxxfe:codeinsight:SrcFileDoesNotExist', f ) );
                end
            end

            for f = self.HeaderFiles
                if exist( f, 'file' ) ~= 2
                    error( message( 'cxxfe:codeinsight:HeaderFileDoesNotExist', f ) );
                end
            end

            for d = self.IncludeDirs
                if exist( d, 'dir' ) ~= 7
                    error( message( 'cxxfe:codeinsight:IncludeDirDoesNotExist', d ) );
                end
            end
        end
    end

    methods ( Static, Hidden )
        function mustBeNonEmptyString( s )
            arguments
                s( 1, : )string
            end
            if any( s == "" )
                error( message( 'cxxfe:codeinsight:NonEmptyStringValue' ) );
            end
        end
        [ resultSrcFileList, resultIncludeDir, copiedFiles ] = createResultDir( aASTFileList, options );
        newcontent = processFileContent( sourceFile, options );
    end
end
