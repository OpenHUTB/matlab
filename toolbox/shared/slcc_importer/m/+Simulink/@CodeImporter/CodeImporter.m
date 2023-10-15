





























classdef CodeImporter < handle

    properties




        LibraryFileName( 1, 1 )string = "untitled";





        OutputFolder( 1, 1 )string = "";

    end

    properties ( SetAccess = private )

















        CustomCode( 1, 1 )Simulink.CodeImporter.CustomCode;




















        ParseInfo( 1, 1 )Simulink.CodeImporter.ParseInfo;














        Options( 1, 1 )Simulink.CodeImporter.Options;
    end

    properties ( Hidden )
        qualifiedSettings( 1, 1 )internal.CodeImporter.QualifiedSettings
        importAsLibrary( 1, 1 )logical = true;
        autoCreatePorts( 1, 1 )logical = false;
        CodeInsight( 1, 1 )polyspace.internal.codeinsight.CodeInsight;
        HasSLTest( 1, 1 )logical = false;
        HasSLCov( 1, 1 )logical = false;
        FunctionsToImport( 1, : )string;
        TypesToImport( 1, : )string;
        MetadataFileChecksum = [  ];
        MetadataInfo polyspace.internal.codeinsight.utils.Metadata = [  ];
        FunctionSettings( 1, : )
    end

    properties ( Hidden, Transient )

        Wizard;
        launchedFromBlocksetDesigner( 1, 1 )logical = false;
        ParentIdForBlocksetDesigner( 1, 1 )string = '';
    end


    methods

        function obj = CodeImporter( name )

            start_simulink;

            obj.CustomCode = Simulink.CodeImporter.CustomCode;
            obj.OutputFolder = "";
            obj.initializeParseInfo(  );
            obj.CodeInsight = polyspace.internal.codeinsight.CodeInsight;
            obj.qualifiedSettings = internal.CodeImporter.QualifiedSettings;
            sltLicenseStatus = license( 'test', 'Simulink_Test' );
            obj.HasSLTest = sltLicenseStatus &&  ...
                ( dig.isProductInstalled( 'Simulink Test' ) );
            slCovLicenseStatus = license( 'test', 'Simulink_Coverage' );
            obj.HasSLCov = slCovLicenseStatus &&  ...
                ( dig.isProductInstalled( 'Simulink Coverage' ) );
            obj.Options = Simulink.CodeImporter.Options( obj.HasSLTest, obj.isSLTest );
            if nargin > 0
                obj.LibraryFileName = name;
            end
        end
    end


    methods ( Hidden )


        function updateCustomCodeRootFolder( obj, src )
            obj.CustomCode.updateRootFolder( src );
        end
    end


    methods
        function set.OutputFolder( obj, src )
            src = strip( src );
            obj.OutputFolder = src;
            updateCustomCodeRootFolder( obj, obj.OutputFolder );
        end

        function set.LibraryFileName( obj, src )
            src = strip( src );
            if ~isvarname( src )
                errmsg = MException( message( 'Simulink:CodeImporter:InvalidLibraryFileName', src ) );
                throw( errmsg );
            end
            obj.LibraryFileName = src;
        end

        function set.FunctionsToImport( obj, srcs )
            srcs = strip( srcs );


            obj.FunctionsToImport = srcs;
        end

        function set.TypesToImport( obj, srcs )
            srcs = strip( srcs );

            obj.TypesToImport = srcs;
        end

    end


    methods ( Hidden )



        function initializeParseInfo( obj )
            obj.ParseInfo = Simulink.CodeImporter.ParseInfo( obj );
        end

        function tf = isSLTest( obj )
            tf = isa( obj, 'sltest.CodeImporter' );
        end

        function tf = isSLUnitTest( obj )
            tf = obj.isSLTest && obj.isUnitTest;
        end

        function filePath = verifySaveFilePath( obj, fileName, isOverwrite )
            if ~isempty( char( fileName ) )
                [ path, name, ext ] = fileparts( char( fileName ) );
                if ~isempty( path ) && ~exist( path, 'dir' )
                    errmsg = MException( message( 'Simulink:CodeImporter:FilePathNotExist', path ) );
                    throw( errmsg );
                end
                if isempty( path )
                    path = pwd;
                end
                if isempty( name )
                    name = [ char( obj.LibraryFileName ), '_import' ];
                    ext = '.json';
                end
                if isempty( ext )
                    ext = '.json';
                end
            else
                path = pwd;
                name = [ char( obj.LibraryFileName ), '_import' ];
                ext = '.json';
            end
            filePath = fullfile( path, [ name, ext ] );
            if isfile( filePath ) && ~isOverwrite
                errmsg = MException( message( 'Simulink:CodeImporter:SaveFileIsNotOverwrite', filePath ) );
                throw( errmsg );
            end
            if isfile( filePath ) && ~internal.CodeImporter.Tools.isFileWritable( filePath )
                errmsg = MException( message( 'Simulink:CodeImporter:SaveFileIsNotWritable', filePath ) );
                throw( errmsg );
            end
            if ~internal.CodeImporter.Tools.isFolderWritable( path )
                errmsg = MException( message( 'Simulink:CodeImporter:NonwritableFolder', path ) );
                throw( errmsg );
            end
        end

        function saveData = prepareSaveData( obj )
            obj.cacheFunctionSettings(  );

            saveData.SimulinkCodeImporterVersion = 1.0;
            saveData.LibraryFileName = obj.LibraryFileName;
            if ~isempty( char( obj.OutputFolder ) )
                saveData.OutputFolder = obj.OutputFolder;
            end

            if ~isempty( obj.CustomCode.SourceFiles )
                saveData.CustomCode.SourceFiles = obj.CustomCode.SourceFiles;
            end
            if ~isempty( obj.CustomCode.InterfaceHeaders )
                saveData.CustomCode.InterfaceHeaders = obj.CustomCode.InterfaceHeaders;
            end
            if ~isempty( obj.CustomCode.IncludePaths )
                saveData.CustomCode.IncludePaths = obj.CustomCode.IncludePaths;
            end
            if ~isempty( obj.CustomCode.Libraries )
                saveData.CustomCode.Libraries = obj.CustomCode.Libraries;
            end
            if ~isempty( obj.CustomCode.Defines )
                saveData.CustomCode.Defines = obj.CustomCode.Defines;
            end
            saveData.CustomCode.Language = obj.CustomCode.Language;
            if ~isempty( obj.CustomCode.CompilerFlags )
                saveData.CustomCode.CompilerFlags = obj.CustomCode.CompilerFlags;
            end
            if ~isempty( obj.CustomCode.LinkerFlags )
                saveData.CustomCode.LinkerFlags = obj.CustomCode.LinkerFlags;
            end
            saveData.CustomCode.GlobalVariableInterface = obj.CustomCode.GlobalVariableInterface;
            saveData.CustomCode.FunctionArrayLayout = obj.CustomCode.FunctionArrayLayout;
            if ~isempty( char( obj.CustomCode.MetadataFile ) )
                saveData.CustomCode.MetadataFile = obj.CustomCode.MetadataFile;
            end

            if ~strcmpi( obj.Options.PassByPointerDefaultSize, '-1' )
                saveData.Options.PassByPointerDefaultSize = obj.Options.PassByPointerDefaultSize;
            end
            if ~obj.Options.CreateTestHarness
                saveData.Options.CreateTestHarness = obj.Options.CreateTestHarness;
            end
            if ( ~obj.isSLTest && ~isempty( char( obj.Options.LibraryBrowserName ) ) )
                saveData.Options.LibraryBrowserName = obj.Options.LibraryBrowserName;
            end
            if ~isequal( obj.Options.UndefinedFunctionHandling, internal.CodeImporter.UndefinedFunctionHandling.FilterOut )
                saveData.Options.UndefinedFunctionHandling = obj.Options.UndefinedFunctionHandling;
            end
            if ~isempty( obj.FunctionsToImport )
                saveData.FunctionsToImport = obj.FunctionsToImport;
            end
            if ~isempty( obj.TypesToImport )
                saveData.TypesToImport = obj.TypesToImport;
            end
            if ~isempty( obj.FunctionSettings )
                saveData.FunctionSettings = obj.FunctionSettings;
            end
        end

        function saveToJSON( ~, saveData, filePath )
            propToBeSaved = jsonencode( saveData, 'PrettyPrint', true );
            fid = fopen( filePath, 'wt' );
            fprintf( fid, '%s', propToBeSaved );
            fclose( fid );
        end

        function performCleanup( obj )
            obj.LibraryFileName = "untitled";
            obj.OutputFolder = "";
            obj.CustomCode = Simulink.CodeImporter.CustomCode;
            obj.initializeParseInfo(  );
            obj.Options = Simulink.CodeImporter.Options( obj.HasSLTest, obj.isSLTest );
            obj.FunctionsToImport = [  ];
            obj.TypesToImport = [  ];
            obj.FunctionSettings = [  ];
            obj.qualifiedSettings = internal.CodeImporter.QualifiedSettings;
            obj.importAsLibrary = true;
            obj.autoCreatePorts = false;
            obj.CodeInsight = polyspace.internal.codeinsight.CodeInsight;
            obj.MetadataFileChecksum = [  ];
            obj.MetadataInfo = [  ];


        end

        function restoreSavedData( obj, savedData )

            obj.performCleanup(  );


            if isfield( savedData, 'LibraryFileName' )
                obj.LibraryFileName = savedData.LibraryFileName;
            end

            if isfield( savedData, 'OutputFolder' )
                obj.OutputFolder = savedData.OutputFolder;
            end
            if isfield( savedData, 'CustomCode' )
                if isfield( savedData.CustomCode, 'SourceFiles' )
                    obj.CustomCode.SourceFiles = savedData.CustomCode.SourceFiles;
                end
                if isfield( savedData.CustomCode, 'InterfaceHeaders' )
                    obj.CustomCode.InterfaceHeaders = savedData.CustomCode.InterfaceHeaders;
                end
                if isfield( savedData.CustomCode, 'IncludePaths' )
                    obj.CustomCode.IncludePaths = savedData.CustomCode.IncludePaths;
                end
                if isfield( savedData.CustomCode, 'Libraries' )
                    obj.CustomCode.Libraries = savedData.CustomCode.Libraries;
                end
                if isfield( savedData.CustomCode, 'Defines' )
                    obj.CustomCode.Defines = savedData.CustomCode.Defines;
                end
                if isfield( savedData.CustomCode, 'Language' )
                    obj.CustomCode.Language = savedData.CustomCode.Language;
                end
                if isfield( savedData.CustomCode, 'CompilerFlags' )
                    obj.CustomCode.CompilerFlags = savedData.CustomCode.CompilerFlags;
                end
                if isfield( savedData.CustomCode, 'LinkerFlags' )
                    obj.CustomCode.LinkerFlags = savedData.CustomCode.LinkerFlags;
                end
                if isfield( savedData.CustomCode, 'GlobalVariableInterface' )
                    obj.CustomCode.GlobalVariableInterface = savedData.CustomCode.GlobalVariableInterface;
                end
                if isfield( savedData.CustomCode, 'FunctionArrayLayout' )
                    obj.CustomCode.FunctionArrayLayout = savedData.CustomCode.FunctionArrayLayout;
                end
                if isfield( savedData.CustomCode, 'MetadataFile' )
                    obj.CustomCode.MetadataFile = savedData.CustomCode.MetadataFile;
                end
            end
            if isfield( savedData, 'Options' )
                if isfield( savedData.Options, 'PassByPointerDefaultSize' )
                    obj.Options.PassByPointerDefaultSize = savedData.Options.PassByPointerDefaultSize;
                end
                if isfield( savedData.Options, 'CreateTestHarness' )
                    obj.Options.CreateTestHarness = savedData.Options.CreateTestHarness;
                end
                if isfield( savedData.Options, 'LibraryBrowserName' )
                    obj.Options.LibraryBrowserName = savedData.Options.LibraryBrowserName;
                end
                if isfield( savedData.Options, 'UndefinedFunctionHandling' )
                    obj.Options.UndefinedFunctionHandling = savedData.Options.UndefinedFunctionHandling;
                end
            end
            if isfield( savedData, 'FunctionsToImport' )
                obj.FunctionsToImport = savedData.FunctionsToImport;
            end
            if isfield( savedData, 'TypesToImport' )
                obj.TypesToImport = savedData.TypesToImport;
            end
            if isfield( savedData, 'FunctionSettings' ) && ~isempty( savedData.FunctionSettings )
                obj.FunctionSettings = savedData.FunctionSettings;
            end
        end

        function savedData = loadSavedDataFromFile( obj, file )
            if isempty( char( file ) )
                errmsg = MException( message( 'Simulink:CodeImporter:NoFileToLoad' ) );
                throw( errmsg );
            end
            if ~isfile( file )
                errmsg = MException( message( 'Simulink:CodeImporter:FilePathNotExist', file ) );
                throw( errmsg );
            end

            try
                savedData = jsondecode( fileread( file ) );
            catch ME
                errmsg = MException( message( 'Simulink:CodeImporter:CannotReadFunctionSettings', file ) );
                errmsg = addCause( errmsg, ME );
                throw( errmsg );
            end

            if ~isstruct( savedData ) ||  ...
                    ~isfield( savedData, 'SimulinkCodeImporterVersion' ) ||  ...
                    ~isscalar( savedData.SimulinkCodeImporterVersion ) ||  ...
                    ~isa( savedData.SimulinkCodeImporterVersion, 'double' )
                errmsg = MException( message( 'Simulink:CodeImporter:CannotReadFunctionSettings', file ) );
                throw( errmsg );
            end

            if ( ~obj.isSLTest && ( isfield( savedData, 'TestType' ) || isfield( savedData, 'SandboxSettings' ) ) )
                errmsg = MException( message( 'Simulink:CodeImporter:UnableToLoadSLTestSavedFileToBase' ) );
                throw( errmsg );
            end
        end

        function startWizard( obj )
            obj.view;
            disp( obj.Wizard.Gui.DebugURL );
        end

        function delete( obj )
            if ~isempty( obj.Wizard )
                obj.Wizard.delete(  );
            end
        end

        function validateFileOnAbsolutePath( ~, srcs, specs )
            for i = 1:length( srcs )
                if srcs( i ) == ""
                    continue ;
                end
                [ path, file, ext ] = fileparts( srcs( i ) );
                if ~isfile( srcs( i ) )
                    errmsg = MException( message( 'Simulink:CodeImporter:InvalidAbsFilePath', file + ext, path, specs( i ) ) );
                    throw( errmsg );
                end
            end
        end

        function validateAbsolutePath( ~, srcs, specs )
            for i = 1:length( srcs )
                if srcs( i ) == ""
                    continue ;
                end
                if ~isfolder( srcs( i ) )
                    errmsg = MException( message( 'Simulink:CodeImporter:InvalidAbsPath', specs( i ) ) );
                    throw( errmsg );
                end
            end
        end

        function qualifyProjectLibrarySettings( obj )
            rootFolder = strip( obj.OutputFolder, '"' );
            obj.qualifiedSettings.OutputFolder =  ...
                internal.CodeImporter.Tools.processDollarsAnsSep( rootFolder );
            if isempty( char( obj.qualifiedSettings.OutputFolder ) )
                obj.qualifiedSettings.OutputFolder = pwd;
            end
            if ~isfolder( obj.qualifiedSettings.OutputFolder )
                errmsg = MException( message( 'Simulink:CodeImporter:CannotFindOutputFolder',  ...
                    obj.qualifiedSettings.OutputFolder ) );
                throw( errmsg );
            elseif ~internal.CodeImporter.Tools.isFolderWritable(  ...
                    obj.qualifiedSettings.OutputFolder )
                errmsg = MException( message( 'Simulink:CodeImporter:NonwritableOutputFolder',  ...
                    obj.qualifiedSettings.OutputFolder ) );
                throw( errmsg );
            end

            [ success, folderDetail ] = fileattrib( obj.qualifiedSettings.OutputFolder );
            assert( success, 'Get file attribes of writtable OutputFolder fails.' );
            obj.qualifiedSettings.OutputFolder = folderDetail.Name;
            obj.qualifiedSettings.CustomCode.updateRootFolder(  ...
                obj.qualifiedSettings.OutputFolder );
        end

        function qualifyCustomCodeSettings( obj, isInferHeader )
            if nargin < 2



                isInferHeader = false;
            end

            obj.CustomCode.SourceFiles( obj.CustomCode.SourceFiles == "" ) = [  ];
            obj.CustomCode.InterfaceHeaders( obj.CustomCode.InterfaceHeaders == "" ) = [  ];
            obj.CustomCode.IncludePaths( obj.CustomCode.IncludePaths == "" ) = [  ];
            obj.CustomCode.Libraries( obj.CustomCode.Libraries == "" ) = [  ];

            if ( isempty( obj.CustomCode.InterfaceHeaders ) &&  ...
                    ~isInferHeader &&  ...
                    ~obj.isSLUnitTest )
                errmsg = MException( message( 'Simulink:CodeImporter:EmptyInterfaceHeader' ) );
                throw( errmsg );
            end

            if ( isempty( obj.CustomCode.SourceFiles ) && obj.isSLUnitTest )
                errmsg = MException( message( 'Simulink:CodeImporter:EmptySourceFile' ) );
                throw( errmsg );
            end


            obj.qualifiedSettings.CustomCode.SourceFiles = [  ];
            for idx = 1:length( obj.CustomCode.SourceFiles )
                obj.qualifiedSettings.CustomCode.SourceFiles( idx ) =  ...
                    internal.CodeImporter.Tools.processDollarsAnsSep(  ...
                    obj.CustomCode.SourceFiles( idx ) );
            end
            validateFileOnAbsolutePath( obj,  ...
                internal.CodeImporter.Tools.convertToFullPath(  ...
                obj.qualifiedSettings.CustomCode.SourceFiles,  ...
                obj.qualifiedSettings.OutputFolder ),  ...
                string( obj.CustomCode.SourceFiles ) );
            obj.qualifiedSettings.CustomCode.SourceFiles =  ...
                unique( obj.qualifiedSettings.CustomCode.SourceFiles, 'stable' );

            if isempty( obj.qualifiedSettings.CustomCode.SourceFiles ) && isInferHeader
                errmsg = MException( message( 'Simulink:CodeImporter:InferringHdrWithEmptySrc' ) );
                throw( errmsg );
            end


            obj.qualifiedSettings.CustomCode.IncludePaths = [  ];
            for idx = 1:length( obj.CustomCode.IncludePaths )
                obj.qualifiedSettings.CustomCode.IncludePaths( idx ) =  ...
                    internal.CodeImporter.Tools.processDollarsAnsSep(  ...
                    obj.CustomCode.IncludePaths( idx ) );
            end
            validateAbsolutePath( obj,  ...
                internal.CodeImporter.Tools.convertToFullPath(  ...
                obj.qualifiedSettings.CustomCode.IncludePaths,  ...
                obj.qualifiedSettings.OutputFolder ),  ...
                string( obj.CustomCode.IncludePaths ) );
            obj.qualifiedSettings.CustomCode.IncludePaths =  ...
                unique( obj.qualifiedSettings.CustomCode.IncludePaths, 'stable' );

            if isInferHeader

                return ;
            end


            obj.qualifiedSettings.CustomCode.Libraries = [  ];
            for idx = 1:length( obj.CustomCode.Libraries )
                obj.qualifiedSettings.CustomCode.Libraries( idx ) =  ...
                    internal.CodeImporter.Tools.processDollarsAnsSep(  ...
                    obj.CustomCode.Libraries( idx ) );
            end

            validateFileOnAbsolutePath( obj,  ...
                internal.CodeImporter.Tools.convertToFullPath(  ...
                obj.qualifiedSettings.CustomCode.Libraries,  ...
                obj.qualifiedSettings.OutputFolder ),  ...
                string( obj.CustomCode.Libraries ) );
            obj.qualifiedSettings.CustomCode.Libraries =  ...
                unique( obj.qualifiedSettings.CustomCode.Libraries, 'stable' );


            obj.qualifiedSettings.CustomCode.MetadataFile =  ...
                internal.CodeImporter.Tools.processDollarsAnsSep(  ...
                obj.CustomCode.MetadataFile );


            obj.qualifiedSettings.CustomCode.MetadataFile =  ...
                internal.CodeImporter.Tools.convertToFullPath(  ...
                obj.qualifiedSettings.CustomCode.MetadataFile,  ...
                obj.qualifiedSettings.OutputFolder );

            if obj.qualifiedSettings.CustomCode.MetadataFile == ""

                obj.MetadataFileChecksum = [  ];
                obj.MetadataInfo = [  ];

            elseif isfile( obj.qualifiedSettings.CustomCode.MetadataFile )
                currMetadataChecksum = Simulink.getFileChecksum(  ...
                    obj.qualifiedSettings.CustomCode.MetadataFile );
                if ~isequal( currMetadataChecksum, obj.MetadataFileChecksum )

                    try
                        obj.MetadataInfo =  ...
                            obj.importFromMetadataFile(  );

                        obj.MetadataFileChecksum = currMetadataChecksum;
                    catch ME
                        throw( ME );
                    end
                end
            else


                error( message( 'Simulink:CodeImporter:CannotFindMetadataFile',  ...
                    obj.qualifiedSettings.CustomCode.MetadataFile ) );
            end


            obj.qualifiedSettings.CustomCode.InterfaceHeaders = [  ];
            for idx = 1:length( obj.CustomCode.InterfaceHeaders )
                obj.qualifiedSettings.CustomCode.InterfaceHeaders( idx ) =  ...
                    internal.CodeImporter.Tools.processDollarsAnsSep(  ...
                    obj.CustomCode.InterfaceHeaders( idx ) );
            end
            obj.qualifiedSettings.CustomCode.InterfaceHeaders =  ...
                unique( obj.qualifiedSettings.CustomCode.InterfaceHeaders, 'stable' );











            if ~obj.isSLUnitTest && ~isempty( obj.qualifiedSettings.CustomCode.InterfaceHeaders )
                includeDirs = internal.CodeImporter.Tools.convertToFullPath(  ...
                    obj.qualifiedSettings.CustomCode.IncludePaths,  ...
                    obj.qualifiedSettings.OutputFolder );
                includeDirs = CGXE.Utils.orderedUniquePaths( [ includeDirs, obj.qualifiedSettings.OutputFolder ] );

                [ ~, errStr ] = CGXE.Utils.tokenize( obj.qualifiedSettings.OutputFolder,  ...
                    sprintf( '"%s"\n', strip( obj.qualifiedSettings.CustomCode.InterfaceHeaders, '"' ) ),  ...
                    'InterfaceHeaders',  ...
                    includeDirs );

                if ~isempty( errStr )
                    exception = MException( message( 'Simulink:CustomCode:TokenizeError' ) );
                    for i = 1:numel( errStr )
                        exception = exception.addCause( MException( '', strrep( errStr{ i }.Msg, '\', '\\' ) ) );
                    end
                    throw( exception );
                end
            end

        end

        function qualifyProjectCompilerSettings( obj )


            if ~isempty( obj.CustomCode.Defines )
                obj.qualifiedSettings.CustomCode.Defines =  ...
                    string( CGXE.CustomCode.extractUserDefines(  ...
                    obj.CustomCode.Defines ) );
            else
                obj.qualifiedSettings.CustomCode.Defines = {  };
            end


            obj.qualifiedSettings.CustomCode.CompilerFlags =  ...
                obj.CustomCode.CompilerFlags;


            obj.qualifiedSettings.CustomCode.LinkerFlags =  ...
                obj.CustomCode.LinkerFlags;


            obj.qualifiedSettings.CustomCode.Language =  ...
                obj.CustomCode.Language;


            obj.qualifiedSettings.CustomCode.GlobalVariableInterface =  ...
                obj.CustomCode.GlobalVariableInterface;


            obj.qualifiedSettings.CustomCode.FunctionArrayLayout =  ...
                obj.CustomCode.FunctionArrayLayout;
        end



        function qualifySettings( obj )
            obj.qualifyProjectLibrarySettings(  );
            obj.qualifyCustomCodeSettings(  );
            obj.qualifyProjectCompilerSettings(  );
        end

        function customCodeHasChanged = computeAndUpdateChecksum( obj )

            [ settingsChecksum, interfaceChecksum, fullChecksum ] =  ...
                obj.qualifiedSettings.CustomCode.computeChecksum(  );
            settingsChecksumChange = ( settingsChecksum ~=  ...
                obj.qualifiedSettings.CustomCode.settingsChecksum );
            fullCheckSumChange = ( fullChecksum ~=  ...
                obj.qualifiedSettings.CustomCode.fullChecksum );
            obj.qualifiedSettings.CustomCode.updateChecksum(  ...
                settingsChecksum, interfaceChecksum, fullChecksum );
            customCodeHasChanged =  ...
                settingsChecksumChange || fullCheckSumChange;
        end

        function parseCode = getCodeToParse( obj )
            parseCode = obj.qualifiedSettings.CustomCode;
        end


        function doParse( obj )

            obj.cacheFunctionSettings(  );

            obj.initializeParseInfo(  );


            parseCode = obj.getCodeToParse(  );


            options.DoSimulinkImportCompliance = true;
            options.Lang = parseCode.Language;
            parseArgs = namedargs2cell( options );

            assert( ~isempty( parseCode.InterfaceHeaders ), 'Need at least one interface file to parse.' );


            includeDirs = internal.CodeImporter.Tools.convertToFullPath(  ...
                parseCode.IncludePaths,  ...
                parseCode.RootFolder );
            includeDirs = CGXE.Utils.orderedUniquePaths( [ includeDirs, parseCode.RootFolder ] );

            if ~isscalar( parseCode.InterfaceHeaders )
                tmpInferredHdrFile = "tmpInferredHeader_" + cgxe( 'MD5AsString', datetime, rand ) + ".h";
                headerFileName = fullfile( parseCode.RootFolder, tmpInferredHdrFile );
                allIncludeStr = sprintf( '#include "%s"\n', strip( parseCode.InterfaceHeaders, '"' ) );
                [ fid, fError ] = fopen( headerFileName, 'w' );
                if ( fid ==  - 1 )
                    error( fError );
                end
                fprintf( fid, "%s", allIncludeStr );
                fclose( fid );
                cleanupTmpInferredHdr = onCleanup( @(  )delete( headerFileName ) );
                interfaceHeaders = headerFileName;
            else
                [ interfaceHeaders, errStr ] = CGXE.Utils.tokenize( parseCode.RootFolder,  ...
                    sprintf( '"%s"\n', strip( parseCode.InterfaceHeaders, '"' ) ),  ...
                    'InterfaceHeaders',  ...
                    includeDirs );
                assert( isempty( errStr ), 'CGXE.Utils.tokenize errors out during custom code parsing.' );
            end

            codeInsight = polyspace.internal.codeinsight.CodeInsight( 'SourceFiles', interfaceHeaders,  ...
                'IncludeDirs', internal.CodeImporter.Tools.convertToFullPath(  ...
                parseCode.IncludePaths,  ...
                parseCode.RootFolder ),  ...
                'Defines', parseCode.Defines );


            obj.ParseInfo.setSuccess( codeInsight.parse( parseArgs{ : } ) );
            if obj.ParseInfo.Success
                obj.ParseInfo.CodeInfo = codeInsight.CodeInfo;
                obj.ParseInfo.computeFunctions( true );
                obj.ParseInfo.computeTypes( true );
            else
                obj.ParseInfo.setErrors( codeInsight.Errors );
                return ;
            end

            if isempty( parseCode.SourceFiles )
                return ;
            end


            codeInsight = polyspace.internal.codeinsight.CodeInsight( 'SourceFiles', internal.CodeImporter.Tools.convertToFullPath(  ...
                parseCode.SourceFiles,  ...
                parseCode.RootFolder ),  ...
                'IncludeDirs', internal.CodeImporter.Tools.convertToFullPath(  ...
                parseCode.IncludePaths,  ...
                parseCode.RootFolder ),  ...
                'Defines', parseCode.Defines );

            obj.ParseInfo.setSuccess( codeInsight.parse( parseArgs{ : } ) );
            if obj.ParseInfo.Success
                obj.ParseInfo.CodeInfo = codeInsight.CodeInfo;
                obj.ParseInfo.computeFunctions( false );
            else
                obj.ParseInfo.setErrors( codeInsight.Errors );
                return ;
            end

        end

        function ret = foundExistingLibrary( obj )
            ret = isfile( fullfile( obj.qualifiedSettings.OutputFolder, obj.LibraryFileName + ".slx" ) );
        end

        function ret = getCachedFunctionSettings( obj, fcnName )

            assert( obj.ParseInfo.Success, "Getting function settings must be after a successful parsing." );
            ret = [  ];
            if isempty( obj.FunctionSettings )
                return ;
            end

            availableFcnNames = { obj.FunctionSettings.Name };
            idxArr = ismember( availableFcnNames, fcnName );
            ret = obj.FunctionSettings( idxArr );
            assert( numel( ret ) <= 1 );
        end

        function cacheFunctionSettings( obj )






            if isempty( obj.ParseInfo.Functions )
                return ;
            end




            fcnObjs = obj.ParseInfo.getFunctions(  );



            obj.FunctionSettings = struct( 'Name', {  }, 'PortSpecArray', {  }, 'ArrayLayout', {  }, 'IsDeterministic', {  } );
            for fcn = fcnObjs
                fcnPortSpec = fcn.getPortSpecDataStruct(  );
                newPortSpecChecksum = cgxe( 'MD5AsString', fcnPortSpec );
                if strcmp( newPortSpecChecksum, fcn.defaultPortSpecChecksum ) &&  ...
                        fcn.ArrayLayout == internal.CodeImporter.FunctionArrayLayout.NotSpecified &&  ...
                        ~fcn.IsDeterministic
                    continue ;
                end
                fcnSettings.Name = char( fcn.Name );
                if ~strcmp( newPortSpecChecksum, fcn.defaultPortSpecChecksum )
                    fcnSettings.PortSpecArray = fcnPortSpec;
                else
                    fcnSettings.PortSpecArray = [  ];
                end
                fcnSettings.ArrayLayout = fcn.ArrayLayout;
                fcnSettings.IsDeterministic = fcn.IsDeterministic;
                obj.FunctionSettings( end  + 1 ) = fcnSettings;
            end
        end

        function metadataInfo = importFromMetadataFile( obj )

            [ ~, ~, fileExt ] = fileparts( obj.qualifiedSettings.CustomCode.MetadataFile );

            if strcmpi( fileExt, '.a2l' )
                if ispc
                    importInfo = obj.qualifiedSettings.CustomCode.MetadataFile;
                else
                    importInfo = [  ];
                    warning( message( 'Simulink:CodeImporter:ASAP2WindowsOnlyWarn' ) );
                end
            else
                assert( strcmpi( fileExt, '.grl' ), 'Expected GRL File' )
                if ispc
                    importInfo = internal.CodeImporter.grlImporter( obj );
                else
                    importInfo = [  ];
                    warning( message( 'Simulink:CodeImporter:GRLWindowsOnlyWarn' ) );
                end
            end
            metadataInfo =  ...
                polyspace.internal.codeinsight.utils.Metadata( importInfo );
        end

        function [ filesToAdd, dirsToAdd ] = getFilesToAddToProject( obj )
            outputFolder = obj.qualifiedSettings.OutputFolder;


            simulinkLib = fullfile( outputFolder, obj.LibraryFileName + ".slx" );

            slddFile = string( [  ] );
            if isfile( fullfile( outputFolder, obj.LibraryFileName + ".sldd" ) )
                slddFile = fullfile( outputFolder, obj.LibraryFileName + ".sldd" );
            end


            slblocksFile = string( [  ] );
            if isfile( fullfile( outputFolder, "slblocks.m" ) )
                slblocksFile = fullfile( outputFolder, "slblocks.m" );
            end


            mldatxFile = string( [  ] );
            if isfile( fullfile( outputFolder, obj.LibraryFileName + ".mldatx" ) )
                mldatxFile = fullfile( outputFolder, obj.LibraryFileName + ".mldatx" );
            end

            if obj.Options.BuildForIPProtection
                packageFolder = fullfile( outputFolder, SLCC.OOP.PrebuiltCC.TopFolder );
                assert( isfolder( packageFolder ), 'The folder for saving packaged prebuilt custom code dependencies must exist.' );

                dirsToAdd = { packageFolder };
                filesToAdd = { simulinkLib, slddFile, mldatxFile, slblocksFile };

                return ;
            end


            sourceFiles = internal.CodeImporter.Tools.convertToFullPath(  ...
                obj.qualifiedSettings.CustomCode.SourceFiles,  ...
                outputFolder );


            includeDirs = internal.CodeImporter.Tools.convertToFullPath(  ...
                obj.qualifiedSettings.CustomCode.IncludePaths,  ...
                obj.qualifiedSettings.CustomCode.RootFolder );
            includeDirs = CGXE.Utils.orderedUniquePaths(  ...
                [ includeDirs, obj.qualifiedSettings.CustomCode.RootFolder ] );

            [ interfaceHeaders, errStr ] = CGXE.Utils.tokenize(  ...
                obj.qualifiedSettings.CustomCode.RootFolder,  ...
                sprintf( '"%s"\n', strip( obj.qualifiedSettings.CustomCode.InterfaceHeaders, '"' ) ),  ...
                'InterfaceHeaders',  ...
                includeDirs );
            interfaceHeaders = string( interfaceHeaders );
            assert( isempty( errStr ), 'CGXE.Utils.tokenize errors when computing interface headers for adding to project.' );


            includePaths = obj.qualifiedSettings.CustomCode.IncludePaths;
            includePaths( strcmpi( includePaths, "." ) ) = [  ];
            includePaths = internal.CodeImporter.Tools.convertToFullPath(  ...
                includePaths,  ...
                outputFolder );
            includePaths( strcmpi( includePaths, outputFolder ) ) = [  ];


            libraryFiles = internal.CodeImporter.Tools.convertToFullPath(  ...
                obj.qualifiedSettings.CustomCode.Libraries,  ...
                obj.qualifiedSettings.OutputFolder );

            filesToAdd = { sourceFiles, interfaceHeaders, libraryFiles,  ...
                simulinkLib, slddFile, mldatxFile,  ...
                slblocksFile };

            dirsToAdd = { includePaths };
        end

        function preParseCheck( ~ )
        end


        function success = build( obj, options )















            arguments
                obj( 1, 1 )Simulink.CodeImporter
                options.Force( 1, 1 )string{ validatestring( options.Force, [ "off", "on" ] ) } = "off"
            end
            forceBuild = strcmp( options.Force, "on" );
            success = true;

            try
                obj.parse(  );

                if forceBuild || ~obj.ParseInfo.BuildInfo.Success
                    internal.CodeImporter.doBuildModel( obj );
                    if ~obj.ParseInfo.BuildInfo.Success
                        baseE = MException( message( 'Simulink:CodeImporter:BuildUnsuccessful' ) );
                        causeE = MException( 'Simulink:CodeImporter:BuildErrors', '%s', obj.ParseInfo.BuildInfo.Errors );
                        baseE = addCause( baseE, causeE );
                        throw( baseE );
                    end
                end
            catch e
                success = false;
                handleError( obj, e );
            end
        end

    end


    methods

        function success = parse( obj, options )















            arguments
                obj( 1, 1 )Simulink.CodeImporter
                options.Force( 1, 1 )string{ validatestring( options.Force, [ "off", "on" ] ) } = "off"
            end
            forceParse = strcmp( options.Force, "on" );
            success = true;

            try

                gIOBefore = obj.qualifiedSettings.CustomCode.GlobalVariableInterface;

                obj.qualifySettings(  );

                gIOAfter = obj.qualifiedSettings.CustomCode.GlobalVariableInterface;
                gIOChanged = ~isequal( gIOBefore, gIOAfter );


                customCodeHasChanged =  ...
                    obj.computeAndUpdateChecksum(  );



                if isempty( obj.ParseInfo ) || ~obj.ParseInfo.Success ||  ...
                        forceParse || customCodeHasChanged
                    obj.preParseCheck(  );
                    obj.doParse(  );
                    if ~obj.ParseInfo.Success
                        baseE = MException( message( 'Simulink:CodeImporter:ParseUnsuccessful' ) );
                        if isempty( obj.ParseInfo.Errors )
                            causeE = MException( message( 'Simulink:CodeImporter:EmptyParseResult' ) );
                        else
                            causeE = MException( 'Simulink:CodeImporter:ParseErrors', '%s', obj.ParseInfo.Errors );
                        end
                        baseE = addCause( baseE, causeE );
                        throw( baseE );
                    end
                elseif gIOChanged
                    obj.ParseInfo.invalidateFunctions(  );
                end

            catch e
                success = false;
                handleError( obj, e );
            end

        end

        
        function success = import( obj, options )
            arguments
                obj( 1, 1 )Simulink.CodeImporter
                options.Functions( 1, : )string = string( [  ] )
                options.Types( 1, : )string = string( [  ] )
                options.Overwrite( 1, 1 )string{ validatestring( options.Overwrite, [ "off", "on" ] ) } = "off"
                options.AddToProject( 1, 1 )string
                options.EntryFunctionsOnly( 1, 1 )string{ validatestring( options.EntryFunctionsOnly, [ "off", "on" ] ) } = "off"
            end

            inputFunctions = options.Functions;
            inputTypes = options.Types;
            success = true;

            try
                obj.parse(  );
                if obj.Options.ValidateBuild || obj.Options.BuildForIPProtection
                    obj.build(  );
                end

                if isempty( inputFunctions )
                    obj.FunctionsToImport = obj.ParseInfo.AvailableFunctions;
                else
                    missingFcns = setdiff( inputFunctions, obj.ParseInfo.AvailableFunctions, 'stable' );
                    if ~isempty( missingFcns )
                        errmsg = MException( message( 'Simulink:CodeImporter:FunctionToImportMismatch',  ...
                            join( missingFcns, ", " ) ) );
                        throw( errmsg );
                    end

                    obj.FunctionsToImport = sort( inputFunctions );
                end

                if strcmpi( options.EntryFunctionsOnly, "on" )
                    obj.FunctionsToImport = intersect( obj.FunctionsToImport, obj.ParseInfo.EntryFunctions );
                end

                typesUsedByFunctions = obj.ParseInfo.computeTypesUsedByFunctions( obj.FunctionsToImport );

                missingTypesUsedByFcns = setdiff( typesUsedByFunctions, obj.ParseInfo.AvailableTypes );
                if ~isempty( missingTypesUsedByFcns )
                    warning( message( 'Simulink:CodeImporter:TypeToImportMismatch', join( missingTypesUsedByFcns, ", " ) ) );
                end


                if isempty( inputTypes )


                    obj.TypesToImport = typesUsedByFunctions;
                else
                    missingTypes = setdiff( inputTypes, obj.ParseInfo.AvailableTypes, 'stable' );
                    if ~isempty( missingTypes )
                        errmsg = MException( message( 'Simulink:CodeImporter:TypeToImportMismatch',  ...
                            join( missingTypes, ", " ) ) );
                        throw( errmsg );
                    end


                    obj.TypesToImport = union( inputTypes, typesUsedByFunctions );
                end

                if isempty( obj.FunctionsToImport ) && isempty( obj.TypesToImport )
                    errmsg = MException( message( 'Simulink:CodeImporter:NothingToImport' ) );
                    throw( errmsg );
                end

                obj.cacheFunctionSettings(  );
                internal.CodeImporter.generateCCallerLibrary( obj, strcmpi( options.Overwrite, "on" ) );

                if isfield( options, 'AddToProject' )
                    [ filesToAdd, dirsToAdd ] = obj.getFilesToAddToProject(  );
                    projectFullPath = options.AddToProject;
                    internal.CodeImporter.createProjectFromImport( obj, filesToAdd, dirsToAdd, projectFullPath );
                end

            catch e
                success = false;
                handleError( obj, e );
            end
        end


        function view( obj )
            if ~isempty( obj.Wizard ) && isvalid( obj.Wizard ) && isvalid( obj.Wizard.Gui ) && isa( obj.Wizard.Gui.Dlg, 'DAStudio.Dialog' )
                obj.Wizard.Gui.show(  );
            else
                if ~isempty( obj.Wizard )
                    obj.Wizard.delete(  );
                end
                obj.Wizard = internal.CodeImporterUI.Wizard.startup;
                obj.Wizard.CodeImporter = obj;
                obj.Wizard.IsSLTest = obj.isSLTest;
            end
        end


        function success = addToProject( obj, projectFullPath )
            arguments
                obj( 1, 1 )Simulink.CodeImporter
                projectFullPath( 1, 1 )string;
            end

            success = true;
            try
                if isempty( obj.ParseInfo ) || ~obj.ParseInfo.Success || ~obj.foundExistingLibrary
                    errmsg = MException( message( 'Simulink:CodeImporter:ImportRequiredBeforeAddToProject' ) );
                    throw( errmsg );
                end
                [ filesToAdd, dirsToAdd ] = obj.getFilesToAddToProject(  );
                internal.CodeImporter.createProjectFromImport( obj, filesToAdd, dirsToAdd, projectFullPath );
            catch e
                success = false;
                handleError( obj, e );
            end
        end


        function inferredHeaders = computeInterfaceHeaders( obj )

            try
                if obj.isSLUnitTest
                    errmsg = MException( message( 'Simulink:CodeImporter:InferHeadersUnsupported' ) );
                    throw( errmsg );
                end
                obj.qualifyProjectLibrarySettings(  );
                obj.qualifyCustomCodeSettings( true );
                obj.qualifyProjectCompilerSettings(  );
                inferredHeaders = internal.CodeImporter.inferHeaderDependenciesFromSrc( obj );
            catch e
                handleError( obj, e );
            end
        end


        function filePath = save( obj, fileName, options )
            arguments
                obj( 1, 1 )Simulink.CodeImporter
                fileName( 1, : ){ validateattributes( fileName, { 'char', 'string' }, { 'scalartext' } ) } = ''
                options.Overwrite( 1, 1 )string{ validatestring( options.Overwrite, [ "off", "on" ] ) } = "off"
            end

            filePath = string( [  ] );
            try
                filePath = obj.verifySaveFilePath( fileName, strcmpi( options.Overwrite, "on" ) );
                dataToBeSaved = obj.prepareSaveData(  );
                obj.saveToJSON( dataToBeSaved, filePath );
            catch causeE
                baseE = MException( message( 'Simulink:CodeImporter:CannotSaveFile' ) );
                baseE = addCause( baseE, causeE );
                handleError( obj, baseE );
            end
        end

        function success = load( obj, file )

            arguments
                obj( 1, 1 )Simulink.CodeImporter
                file( 1, : ){ validateattributes( file, { 'char', 'string' }, { 'scalartext' } ) } = ''
            end

            success = true;
            try
                s = obj.loadSavedDataFromFile( file );
                obj.restoreSavedData( s );
            catch causeE
                success = false;
                baseE = MException( message( 'Simulink:CodeImporter:CannotLoadFile', file ) );
                baseE = addCause( baseE, causeE );
                handleError( obj, baseE );
            end
        end
    end


    methods ( Hidden )
        function handleError( ~, e )
            throwAsCaller( e );
        end
    end
end



