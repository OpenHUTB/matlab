function success = generateStubFile( self, options )

arguments
    self( 1, 1 )polyspace.internal.codeinsight.CodeInsight
    options.OutputFile( 1, 1 )string{ polyspace.internal.codeinsight.CodeInsight.mustBeNonEmptyString( options.OutputFile ) } = "auto_stub.c"
    options.Metadata( 1, 1 )polyspace.internal.codeinsight.utils.Metadata = [  ]
    options.Verbose( 1, 1 )logical = false


    options.DoSimulinkImportCompliance( 1, 1 )logical = true
    options.AddOriginalIncludeList( 1, 1 )logical = false
end

if ~license( 'checkout', 'Simulink_Test' )
    error( message( 'Simulink:Harness:LicenseNotAvailable' ) );
end

commentHeader = "/*************************************************************************/" + newline +  ...
    "/* Automatically generated " + string( datestr( now ) ) + "                          */" + newline +  ...
    "/* No modification to the content of this file should be done.           */" + newline +  ...
    "/* Changes made to this file will be lost when the sandbox is updated.   */" + newline +  ...
    "/*************************************************************************/" + newline + newline;
try
    self.printStartStatus( "generate stubs content", options.Verbose );
    if isempty( self.CodeInfo )
        success = false;
        self.Errors = "CodeInfo is empty, parse code before generating stubs";
        return ;
    end

    if options.DoSimulinkImportCompliance && ~self.CodeInfo.hasSLCCCompliantInfo
        self.parse( 'DoSimulinkImportCompliance', true );
    end

    [ success, headerContent, sourceContent ] = self.CodeInfo.generateStubs( 'Metadata', options.Metadata, 'CodeInsightObj', self, 'AddOriginalIncludeList', options.AddOriginalIncludeList );
    self.printEndStatus( "generate stubs content", options.Verbose );
catch ME
    success = false;
    self.Errors = ME.getReport;
end
if success && ( ~strcmp( sourceContent, "" ) || ~strcmp( headerContent, "" ) )
    [ dir, name ] = fileparts( options.OutputFile );

    stubHeader = fullfile( dir, name + ".h" );
    self.StubInfo = polyspace.internal.codeinsight.CodeInsight(  ...
        'SourceFiles', self.SourceFiles,  ...
        'IncludeDirs', self.IncludeDirs,  ...
        'Defines', self.Defines,  ...
        'Debug', self.Debug );
    if ~strcmp( sourceContent, "" )
        self.printStartStatus( "write stubs source file", options.Verbose );
        if ~strcmp( headerContent, "" )
            sourceContent = commentHeader + sprintf( '#include "' ) + name + ".h" + sprintf( '"' ) + newline + sourceContent;
        else
            sourceContent = commentHeader + sourceContent;
        end
        fid = fopen( options.OutputFile, 'w' );
        if fid ==  - 1
            m = message( 'cxxfe:codeinsight:InvalidOutputFile' );
            error( m );
        end
        fprintf( fid, "%s", sourceContent );
        fclose( fid );
        c_beautifier( char( options.OutputFile ) );

        self.StubInfo.SourceFiles( end  + 1 ) = options.OutputFile;
        self.printEndStatus( "write stubs source file", options.Verbose );
    end
    if ~strcmp( headerContent, "" )
        self.printStartStatus( "write stubs header file", options.Verbose );
        includeGuardMacro = upper( name ) + "_";
        includeGuardStart = sprintf( "#ifndef %s", includeGuardMacro ) +  ...
            newline + sprintf( "#define %s", includeGuardMacro ) + newline;
        includeGuardEnd = ( "#endif" );
        headerContent = commentHeader + includeGuardStart + headerContent + includeGuardEnd;
        fid2 = fopen( stubHeader, 'w' );
        if fid2 ==  - 1
            m = message( 'cxxfe:codeinsight:InvalidOutputFile' );
            error( m );
        end
        fprintf( fid2, "%s", headerContent );
        fclose( fid2 );
        c_beautifier( char( stubHeader ) );
        self.StubInfo.HeaderFiles( end  + 1 ) = stubHeader;


        for f = self.SourceFiles
            [ srcdir, ~ ] = fileparts( f );
            if ~strcmp( srcdir, dir )
                self.StubInfo.IncludeDirs( end  + 1 ) = srcdir;
            end
        end
        self.printEndStatus( "write stubs header file", options.Verbose );
    end

    self.printStartStatus( "check stubs correctness", options.Verbose );
    success = self.StubInfo.parse( 'DoSimulinkImportCompliance',  ...
        options.DoSimulinkImportCompliance,  ...
        'RemoveUnneededEntities', true );
    self.printEndStatus( "check stubs correctness", options.Verbose );
    if ~success
        self.Errors = "Error during stub generation" + newline + self.StubInfo.Errors;
    end
else
    self.printStatus( "Nothing to stub", options.Verbose );
end
end


