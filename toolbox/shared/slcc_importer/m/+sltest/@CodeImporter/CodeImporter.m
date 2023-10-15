




























classdef CodeImporter < Simulink.CodeImporter

    properties






        TestType( 1, 1 )internal.CodeImporter.TestTypeEnum =  ...
            internal.CodeImporter.TestTypeEnum.UnitTest




















        SandboxSettings( 1, 1 )sltest.CodeImporter.SandboxSettings
    end

    properties ( Hidden, SetAccess = protected )
        AutoStubSource( 1, 1 )string
        AutoStubInclude( 1, 1 )string
    end

    properties ( Hidden )
        AggregatedHeaderFileName( 1, 1 )string = "aggregatedHeader.h"
        InterfaceHeaderFileName( 1, 1 )string = "interfaceHeader.h"
        ManStubPath( 1, 1 )string
        AutoStubPath( 1, 1 )string
        SbxCustomCode( 1, 1 )Simulink.CodeImporter.CustomCode;
    end

    properties ( Dependent, Hidden, SetAccess = private )
        SandboxPath( 1, 1 )string
    end


    methods
        function obj = CodeImporter( name )
            if nargin == 0
                name = 'untitled';
            end
            obj@Simulink.CodeImporter( name );


            if ~obj.HasSLTest
                err = MException( message( "Simulink:Harness:LicenseNotAvailable" ) );
                throw( err );
            else
                stm.internal.util.checkLicense(  );
            end
            obj.SandboxSettings = sltest.CodeImporter.SandboxSettings;
            obj.CustomCode.GlobalVariableInterface = true;
            obj.qualifiedSettings.CustomCode.GlobalVariableInterface = true;
            obj.SbxCustomCode = Simulink.CodeImporter.CustomCode;
        end
    end


    methods
        function set.TestType( obj, testTypeEnum )











            if obj.TestType ~= testTypeEnum
                obj.initializeParseInfo(  );
            end
            obj.TestType = testTypeEnum;
        end

        function sbxPath = get.SandboxPath( obj )

            assert( obj.qualifiedSettings.OutputFolder ~= "" );
            sbxPath = fullfile( obj.qualifiedSettings.OutputFolder,  ...
                [ obj.LibraryFileName.char, '_sandbox' ] );
        end

    end


    methods

        function success = createSandbox( obj, options )
            arguments
                obj( 1, 1 )sltest.CodeImporter
                options.Overwrite( 1, 1 )string{ validatestring( options.Overwrite, [ "off", "on" ] ) } = "off"
            end

            success = true;

            obj.initializeParseInfo(  );

            try
                if obj.TestType == internal.CodeImporter.TestTypeEnum.IntegrationTest
                    errMsg = MException( message(  ...
                        'Simulink:CodeImporter:IncorrectTestTypeForSandboxCreation' ) );
                    throw( errMsg );
                end
                if obj.SandboxSettings.Mode == internal.CodeImporter.SandboxTypeEnum.GenerateAggregatedHeader

                    numSrc = length( obj.CustomCode.SourceFiles );
                    if numSrc > 1
                        srcList = sprintf( '\n%s', obj.CustomCode.SourceFiles );
                        errMsg = MException( message(  ...
                            'Simulink:CodeImporter:MoreThanOneSrcSingleSrcSbxError',  ...
                            numSrc, srcList ) );
                        throw( errMsg );
                    end
                end




















                if ( strcmpi( options.Overwrite, "off" ) && cgxe( 'Feature', 'EditCodeImporterSandbox' ) )


                    editableSbxExists = obj.editSandbox(  );
                    if editableSbxExists
                        return ;
                    end
                end


                obj.originalSourceParse(  );







                if strcmpi( options.Overwrite, "on" )
                    if exist( obj.SandboxPath, 'dir' ) == 7

                        rmdir( obj.SandboxPath, 's' );
                    end
                else




                    if exist( obj.SandboxPath, 'dir' ) == 7
                        sandboxIncludeDir =  ...
                            fullfile( obj.SandboxPath, 'include' );
                        if exist( sandboxIncludeDir, 'dir' ) == 7
                            rmdir( sandboxIncludeDir, 's' );
                        end

                        sandboxAutostubDir =  ...
                            fullfile( obj.SandboxPath, 'autostub' );
                        if exist( sandboxAutostubDir, 'dir' ) == 7
                            rmdir( sandboxAutostubDir, 's' );
                        end

                        sandboxSrcDir = fullfile( obj.SandboxPath, 'src' );
                        if exist( sandboxSrcDir, 'dir' ) == 7
                            rmdir( sandboxSrcDir, 's' );
                        end
                    end
                end


                shouldCreateSandbox = true;
                sandboxSettings = { 'ResultsDir', obj.SandboxPath };


                if ( obj.SandboxSettings.Mode == internal.CodeImporter.SandboxTypeEnum.GenerateAggregatedHeader )
                    sandboxSettings = [ sandboxSettings,  ...
                        { 'AggregateHeaderFiles' }, { true },  ...
                        { 'AggregatedHeaderFileName' }, { obj.AggregatedHeaderFileName },  ...
                        { 'CopySourceFile' }, { obj.SandboxSettings.CopySourceFiles },  ...
                        { 'RemoveAllPragmas' }, { obj.SandboxSettings.RemoveAllPragma },  ...
                        { 'RemoveVariableDefinitionInHeader' }, { obj.SandboxSettings.RemoveVariableDefinitionInHeader } ];
                elseif ( obj.SandboxSettings.Mode == internal.CodeImporter.SandboxTypeEnum.GeneratePreprocessedSource )
                    sandboxSettings = [ sandboxSettings,  ...
                        { 'PreprocessSourceFiles' }, { true },  ...
                        { 'RemoveAllPragmas' }, { obj.SandboxSettings.RemoveAllPragma } ];
                else





                    if ~obj.SandboxSettings.CopySourceFiles
                        shouldCreateSandbox = false;
                    end

                    sandboxSettings = [ sandboxSettings,  ...
                        { 'CopySourceFile' }, { obj.SandboxSettings.CopySourceFiles } ];
                end

                if shouldCreateSandbox
                    ok = obj.CodeInsight.createSandbox( sandboxSettings{ : } );

                    if ~ok
                        topErrMsg = MException( message(  ...
                            'Simulink:CodeImporter:SandboxCreationFailedError' ) );
                        if ~isempty( obj.CodeInsight.SandboxInfo ) && ~isempty( obj.CodeInsight.SandboxInfo.Errors )
                            causeStr = obj.CodeInsight.SandboxInfo.Errors;
                        else
                            causeStr = obj.CodeInsight.Errors;
                        end
                        causeErrMsg = MException( message(  ...
                            'Simulink:CodeImporter:SLTestCodeImporterFailureCause',  ...
                            causeStr ) );
                        topErrMsg = addCause( topErrMsg, causeErrMsg );
                        throw( topErrMsg );
                    end
                else







                    obj.CodeInsight.SandboxInfo = polyspace.internal.codeinsight.CodeInsight( 'SourceFiles', obj.CodeInsight.SourceFiles,  ...
                        'IncludeDirs', obj.CodeInsight.IncludeDirs,  ...
                        'Defines', obj.CodeInsight.Defines );
                end


                obj.ManStubPath = fullfile( obj.SandboxPath, "manualstub" );
                if exist( obj.ManStubPath, 'dir' ) ~= 7
                    mkdir( obj.ManStubPath );
                end





                if exist( fullfile( obj.ManStubPath, "man_stub.h" ), 'file' ) ~= 2
                    manStubHeaderFileName = 'man_stub.h';
                    [ fid, errMsg ] = fopen( fullfile( obj.ManStubPath,  ...
                        manStubHeaderFileName ), 'w' );
                    if fid ==  - 1

                        error( errMsg );
                    end
                    commentHeader =  ...
                        "/*************************************************************************/" + newline +  ...
                        "/* Automatically generated " + string( datestr( now ) ) + "                          */" + newline +  ...
                        "/* This file can be edited/modified by hand to adapt functionality.      */" + newline +  ...
                        "/* All source files in manualstub folder should include man_stub.h.      */" + newline +  ...
                        "/*************************************************************************/" + newline + newline;
                    includeGuardMacro = "_MANUAL_STUB_HEADER_";
                    includeGuardStart =  ...
                        sprintf( "#ifndef %s", includeGuardMacro ) +  ...
                        newline +  ...
                        sprintf( "#define %s", includeGuardMacro ) +  ...
                        newline;
                    includeGuardEnd = "#endif";
                    beginEdittingFromHere =  ...
                        "/**********************Begin editting from here***************************/" + newline + newline;
                    doNotEditHeaderStart =  ...
                        "/*************************************************************************/" + newline +  ...
                        "/* Do not edit this header include statement                             */" + newline +  ...
                        "/*************************************************************************/" + newline + newline;
                    includeHeader = "";
                    if ( obj.SandboxSettings.Mode == internal.CodeImporter.SandboxTypeEnum.GenerateAggregatedHeader )
                        includeHeader = doNotEditHeaderStart + sprintf( '#include "' ) +  ...
                            obj.AggregatedHeaderFileName + sprintf( '"' );


                    end
                    headerContent =  ...
                        commentHeader +  ...
                        includeGuardStart + newline + newline +  ...
                        includeHeader +  ...
                        newline +  ...
                        newline +  ...
                        beginEdittingFromHere +  ...
                        newline + newline +  ...
                        includeGuardEnd;
                    fprintf( fid, "%s", headerContent );
                    fclose( fid );
                end



                fileList = dir( fullfile( obj.ManStubPath, '*.c' ) );
                if isempty( fileList )


                    manStubSrcFileName = 'man_stub.c';
                    [ fid, errMsg ] = fopen( fullfile( obj.ManStubPath, manStubSrcFileName ), 'w' );
                    if fid ==  - 1

                        error( errMsg );
                    end
                    commentSource =  ...
                        "/*************************************************************************/" + newline +  ...
                        "/* Automatically generated " + string( datestr( now ) ) + "                          */" + newline +  ...
                        "/* This file can be edited/modified by hand to adapt functionality.      */" + newline +  ...
                        "/*************************************************************************/" + newline + newline;
                    sourceInclude = sprintf( '#include "man_stub.h"' );
                    sourceContent = commentSource +  ...
                        doNotEditHeaderStart +  ...
                        sourceInclude +  ...
                        newline +  ...
                        newline +  ...
                        beginEdittingFromHere;
                    fprintf( fid, "%s", sourceContent );
                    fclose( fid );
                end



                fullManStubFilePathList =  ...
                    internal.CodeImporter.searchFilesInDir( obj.ManStubPath, '*.c' );

                obj.CodeInsight.SandboxInfo.SourceFiles = unique( [ obj.CodeInsight.SandboxInfo.SourceFiles,  ...
                    fullManStubFilePathList{ : } ] );

                obj.CodeInsight.SandboxInfo.IncludeDirs( end  + 1 ) = obj.ManStubPath;




                obj.sbxCodeInsightParse( obj.CodeInsight.SandboxInfo, true );


                obj.AutoStubPath = fullfile( obj.SandboxPath, "autostub" );
                if exist( obj.AutoStubPath, 'dir' ) ~= 7
                    mkdir( obj.AutoStubPath );
                end

                OutputFile = fullfile( obj.AutoStubPath, "auto_stub.c" );
                OutputHeader = fullfile( obj.AutoStubPath, "auto_stub.h" );
                obj.AutoStubSource = internal.CodeImporter.computeRelativePath( OutputFile, obj.qualifiedSettings.OutputFolder );
                obj.AutoStubInclude = internal.CodeImporter.computeRelativePath( OutputHeader, obj.qualifiedSettings.OutputFolder );


                ok = obj.CodeInsight.SandboxInfo.generateStubFile(  ...
                    'OutputFile', OutputFile,  ...
                    'Metadata', obj.MetadataInfo,  ...
                    'DoSimulinkImportCompliance', true,  ...
                    'AddOriginalIncludeList', obj.SandboxSettings.Mode == internal.CodeImporter.SandboxTypeEnum.UseOriginalCode );
                if ~ok
                    topErrMsg = MException( message(  ...
                        'Simulink:CodeImporter:AutoStubGenerationFailedError' ) );
                    if ~isempty( obj.CodeInsight.SandboxInfo.StubInfo )
                        causeErrMsg = MException( message(  ...
                            'Simulink:CodeImporter:SLTestCodeImporterFailureCause',  ...
                            obj.CodeInsight.SandboxInfo.StubInfo.Errors ) );
                    else
                        causeErrMsg = MException( message(  ...
                            'Simulink:CodeImporter:SLTestCodeImporterFailureCause',  ...
                            obj.CodeInsight.SandboxInfo.Errors ) );
                    end
                    topErrMsg = addCause( topErrMsg, causeErrMsg );
                    throw( topErrMsg );
                end








                if obj.SandboxSettings.generateInterfaceHeader(  )

                    interfaceHeaderFile =  ...
                        fullfile( obj.SandboxPath, 'include', obj.InterfaceHeaderFileName );
                    if ~isempty( obj.CodeInsight.SandboxInfo.StubInfo ) &&  ...
                            ~isempty( obj.CodeInsight.SandboxInfo.StubInfo.SourceFiles ) &&  ...
                            ~isempty( obj.CodeInsight.SandboxInfo.StubInfo.HeaderFiles )
                        codeInsightObj = obj.CodeInsight.SandboxInfo.StubInfo;
                    else
                        codeInsightObj = obj.CodeInsight.SandboxInfo;
                    end




                    obj.sbxCodeInsightParse( codeInsightObj, true );




                    includeDir = fullfile( obj.SandboxPath, 'include' );
                    if exist( includeDir, 'dir' ) ~= 7
                        mkdir( includeDir )
                    end
                    interfaceHeaderSettings = { 'CodeInsightObj', codeInsightObj ...
                        , 'OutputFile', interfaceHeaderFile };
                    if obj.SandboxSettings.Mode == internal.CodeImporter.SandboxTypeEnum.GeneratePreprocessedSource
                        interfaceHeaderSettings = [ interfaceHeaderSettings,  ...
                            { 'IsPreprocessed' }, { true } ];
                    end

                    codeInsightObj.CodeInfo.generateInterfaceHeader( interfaceHeaderSettings{ : } );
                end



                obj.updateSandboxCustomCode(  );
                [ cSettingsChecksum, cInterfaceChecksum, cFullCheckSum ] =  ...
                    obj.SbxCustomCode.computeChecksum(  );
                obj.SbxCustomCode.updateChecksum(  ...
                    cSettingsChecksum, cInterfaceChecksum, cFullCheckSum );

            catch e
                success = false;
                handleError( obj, e );
            end
        end
    end


    methods ( Hidden )

        function tf = isUnitTest( obj )
            tf = ( obj.TestType == internal.CodeImporter.TestTypeEnum.UnitTest );
        end

        function tf = isAutoStubFile( obj, filepath )
            autoStubFolder = fullfile( obj.SandboxPath, 'autostub' );
            tf = contains( lower( filepath ), lower( autoStubFolder ) );
        end

        function tf = isManualStubFile( obj, filepath )
            manStubfolder = fullfile( obj.SandboxPath, 'manualstub' );
            tf = contains( lower( filepath ), lower( manStubfolder ) );
        end

        function sbxCodeInsightParse( obj, codeInsight, removeUnneededEntities )

            parseOptions.DoSimulinkImportCompliance = true;
            parseOptions.Lang = obj.qualifiedSettings.CustomCode.Language;
            if nargin > 2
                parseOptions.RemoveUnneededEntities = removeUnneededEntities;
            end
            args = namedargs2cell( parseOptions );
            try
                success = codeInsight.parse( args{ : } );
            catch causeErr
                topErrMsg = MException( message(  ...
                    'Simulink:CodeImporter:SandboxParseFailedError' ) );
                topErrMsg = addCause( topErrMsg, causeErr );
                throw( topErrMsg );
            end
            if ~success
                topErrMsg = MException( message(  ...
                    'Simulink:CodeImporter:SandboxParseFailedError' ) );
                causeErrMsg = MException( message(  ...
                    'Simulink:CodeImporter:SLTestCodeImporterFailureCause',  ...
                    obj.CodeInsight.SandboxInfo.Errors ) );
                topErrMsg = addCause( topErrMsg, causeErrMsg );
                throw( topErrMsg );
            end
        end

        function saveData = prepareSaveData( obj )
            saveData = prepareSaveData@Simulink.CodeImporter( obj );
            saveData.TestType = obj.TestType;
            saveData.SandboxSettings = obj.SandboxSettings;
        end

        function performCleanup( obj )
            performCleanup@Simulink.CodeImporter( obj );
            obj.TestType = internal.CodeImporter.TestTypeEnum.UnitTest;
            obj.SandboxSettings = sltest.CodeImporter.SandboxSettings;


            obj.AutoStubSource = "";
            obj.AutoStubInclude = "";
            obj.ManStubPath = "";
            obj.AutoStubPath = "";
            obj.SbxCustomCode = Simulink.CodeImporter.CustomCode;
        end


        function restoreSavedData( obj, savedData )

            obj.performCleanup(  );

            restoreSavedData@Simulink.CodeImporter( obj, savedData );
            if isfield( savedData, 'TestType' )
                obj.TestType = savedData.TestType;
            end
            if isfield( savedData, 'SandboxSettings' )
                if isfield( savedData.SandboxSettings, 'Mode' )
                    obj.SandboxSettings.Mode = savedData.SandboxSettings.Mode;
                end
                if isfield( savedData.SandboxSettings, 'CopySourceFiles' )
                    obj.SandboxSettings.CopySourceFiles = savedData.SandboxSettings.CopySourceFiles;
                end
                if isfield( savedData.SandboxSettings, 'RemoveAllPragma' )
                    obj.SandboxSettings.RemoveAllPragma = savedData.SandboxSettings.RemoveAllPragma;
                end
                if isfield( savedData.SandboxSettings, 'RemoveVariableDefinitionInHeader' )
                    obj.SandboxSettings.RemoveVariableDefinitionInHeader = savedData.SandboxSettings.RemoveVariableDefinitionInHeader;
                end
            end
        end



        function originalSourceParse( obj )
            try

                obj.qualifySettings(  );



                [ settingsChecksum, interfaceChecksum, fullChecksum ] = obj.qualifiedSettings.CustomCode.computeChecksum(  );
                settingsChecksumChange = ( settingsChecksum ~= obj.qualifiedSettings.CustomCode.settingsChecksum );
                fullCheckSumChange = ( fullChecksum ~= obj.qualifiedSettings.CustomCode.fullChecksum );
                obj.qualifiedSettings.CustomCode.updateChecksum( settingsChecksum, interfaceChecksum, fullChecksum );

                if isempty( obj.CodeInsight ) || ~isempty( obj.CodeInsight.Errors ) ||  ...
                        isempty( obj.CodeInsight.CodeInfo ) ||  ...
                        settingsChecksumChange || fullCheckSumChange
                    options.DoSimulinkImportCompliance = true;
                    options.Lang = obj.qualifiedSettings.CustomCode.Language;
                    obj.CodeInsight = polyspace.internal.codeinsight.CodeInsight( 'SourceFiles', internal.CodeImporter.Tools.convertToFullPath(  ...
                        obj.qualifiedSettings.CustomCode.SourceFiles,  ...
                        obj.qualifiedSettings.OutputFolder ),  ...
                        'IncludeDirs', internal.CodeImporter.Tools.convertToFullPath(  ...
                        obj.qualifiedSettings.CustomCode.IncludePaths,  ...
                        obj.qualifiedSettings.OutputFolder ),  ...
                        'Defines', obj.qualifiedSettings.CustomCode.Defines );
                    args = namedargs2cell( options );
                    success = obj.CodeInsight.parse( args{ : } );

                    if ~success
                        baseE = MException( message( 'Simulink:CodeImporter:ParseUnsuccessful' ) );
                        if isempty( obj.CodeInsight.Errors )
                            causeE = MException( message( 'Simulink:CodeImporter:EmptyParseResult' ) );
                        else
                            causeE = MException( message( 'Simulink:CodeImporter:ParseErrors', obj.CodeInsight.Errors ) );
                        end
                        baseE = addCause( baseE, causeE );
                        throw( baseE );
                    end
                end
            catch e
                handleError( obj, e );
            end
        end

        function updateSandboxCustomCode( obj )












            obj.SbxCustomCode.SourceFiles = [  ];
            obj.SbxCustomCode.InterfaceHeaders = [  ];
            obj.SbxCustomCode.IncludePaths = [  ];
            obj.SbxCustomCode.Defines = [  ];

            if exist( obj.SandboxPath, 'dir' ) == 7
                obj.SbxCustomCode.updateRootFolder( obj.SandboxPath );





                if obj.SandboxSettings.generateInterfaceHeader(  )
                    interfaceH = fullfile( obj.SandboxPath, 'include',  ...
                        obj.InterfaceHeaderFileName );
                    if exist( interfaceH, 'file' ) == 2
                        obj.SbxCustomCode.InterfaceHeaders = interfaceH;
                    end
                else
                    aggregatedH = fullfile( obj.SandboxPath, 'include',  ...
                        obj.AggregatedHeaderFileName );
                    autostubH = fullfile( obj.SandboxPath, 'autostub',  ...
                        'auto_stub.h' );
                    manStubH = fullfile( obj.SandboxPath, 'manualstub',  ...
                        'man_stub.h' );
                    if exist( aggregatedH, 'file' ) == 2
                        obj.SbxCustomCode.InterfaceHeaders = aggregatedH;
                    end
                    if exist( autostubH, 'file' ) == 2
                        obj.SbxCustomCode.InterfaceHeaders( end  + 1 ) = autostubH;
                    end
                    if exist( manStubH, 'file' ) == 2
                        obj.SbxCustomCode.InterfaceHeaders( end  + 1 ) = manStubH;
                    end
                end






                fullFilePathList = [  ];
                isPreprocessed = obj.SandboxSettings.Mode ==  ...
                    internal.CodeImporter.SandboxTypeEnum.GeneratePreprocessedSource;
                if exist( fullfile( obj.SandboxPath, 'src' ), 'dir' ) == 7
                    fullFilePathList =  ...
                        internal.CodeImporter.searchFilesInDir(  ...
                        fullfile( obj.SandboxPath, 'src' ), '*.c' );
                end




                if isempty( fullFilePathList ) && ~obj.SandboxSettings.CopySourceFiles ...
                        && ~isPreprocessed






                    obj.SbxCustomCode.SourceFiles = internal.CodeImporter.Tools.convertToFullPath(  ...
                        obj.qualifiedSettings.CustomCode.SourceFiles,  ...
                        obj.qualifiedSettings.OutputFolder );
                else
                    obj.SbxCustomCode.SourceFiles = fullFilePathList;
                end



                if exist( fullfile( obj.SandboxPath, 'manualstub' ), 'dir' ) == 7
                    fullFilePathList =  ...
                        internal.CodeImporter.searchFilesInDir(  ...
                        fullfile( obj.SandboxPath, 'manualstub' ), '*.c' );
                    obj.SbxCustomCode.SourceFiles = [ obj.SbxCustomCode.SourceFiles,  ...
                        fullFilePathList{ : } ];
                end


                if exist( fullfile( obj.SandboxPath, 'autostub' ), 'dir' ) == 7
                    autostubC = fullfile( obj.SandboxPath, 'autostub', 'auto_stub.c' );
                    if exist( autostubC, 'file' ) == 2
                        obj.SbxCustomCode.SourceFiles = [ obj.SbxCustomCode.SourceFiles,  ...
                            autostubC ];
                    end
                end


                if isempty( obj.CodeInsight.SandboxInfo.StubInfo )
                    obj.SbxCustomCode.IncludePaths =  ...
                        obj.CodeInsight.SandboxInfo.IncludeDirs;
                    obj.SbxCustomCode.Defines =  ...
                        obj.CodeInsight.SandboxInfo.Defines;
                else
                    obj.SbxCustomCode.IncludePaths =  ...
                        obj.CodeInsight.SandboxInfo.StubInfo.IncludeDirs;
                    obj.SbxCustomCode.Defines =  ...
                        obj.CodeInsight.SandboxInfo.StubInfo.Defines;
                end
            end
        end

        function checkIfSandboxHasChanged( obj )





            [ ~, ~, nCCFullCheckSum ] =  ...
                obj.qualifiedSettings.CustomCode.computeChecksum(  );
            sbxChanged = ~strcmp( obj.qualifiedSettings.CustomCode.fullChecksum, nCCFullCheckSum );
            if sbxChanged
                if cgxe( 'Feature', 'EditCodeImporterSandbox' )
                    warning( message(  ...
                        'Simulink:CodeImporter:CustomCodeChangedSandboxUpdateError' ) );
                else
                    errMsg = MException( message(  ...
                        'Simulink:CodeImporter:CustomCodeChangedSandboxUpdateError' ) );
                    throw( errMsg );
                end
            end


            obj.updateSandboxCustomCode(  );
            [ ~, ~, nSbxFullCheckSum ] =  ...
                obj.SbxCustomCode.computeChecksum(  );
            sbxChanged = ~strcmp( obj.SbxCustomCode.fullChecksum, nSbxFullCheckSum );

            if sbxChanged
                errMsg = MException( message(  ...
                    'Simulink:CodeImporter:SandboxUpdateError' ) );
                throw( errMsg );
            end

        end

        function customCodeHasChanged = computeAndUpdateChecksum( obj )


            if obj.TestType == internal.CodeImporter.TestTypeEnum.IntegrationTest
                customCodeHasChanged =  ...
                    computeAndUpdateChecksum@Simulink.CodeImporter( obj );
                return ;
            end





            if exist( obj.SandboxPath, 'dir' ) ~= 7 ||  ...
                    isempty( obj.CodeInsight.SandboxInfo )
                errMsg = MException( message(  ...
                    'Simulink:CodeImporter:SandboxDoesNotExistError' ) );
                throw( errMsg );
            end



            obj.checkIfSandboxHasChanged(  );




            customCodeHasChanged = false;
        end

        function parseCode = getCodeToParse( obj )
            if obj.isUnitTest
                parseCode = obj.SbxCustomCode;
            else
                parseCode = getCodeToParse@Simulink.CodeImporter( obj );
            end
        end

        function preParseCheck( obj )
            if obj.isSLUnitTest(  )








                if obj.sbxHasMissingSymbols(  )
                    missingFcnsChar = [  ];
                    missingTypesChar = [  ];
                    missingFcnDec =  ...
                        obj.CodeInsight.SandboxInfo.CodeInfo.MissingFunctionDeclaration;
                    missingTypesDec =  ...
                        obj.CodeInsight.SandboxInfo.CodeInfo.MissingTypeDefinition;

                    if ~isempty( missingFcnDec )
                        catalogText = message( 'Simulink:CodeImporter:SymbolsMissingFunction' );
                        missingFcnsStr = catalogText.string;
                        fcnList = sprintf( "\t%s\n", missingFcnDec );
                        missingFcnsChar = [ missingFcnsStr.char, newline, fcnList.char ];
                    end

                    if ~isempty( missingTypesDec )
                        catalogText = message( 'Simulink:CodeImporter:SymbolsMissingType' );
                        missingTypesStr = catalogText.string;
                        typeList = sprintf( "\t%s\n", missingTypesDec );
                        missingTypesChar = [ newline, newline, missingTypesStr.char, newline, typeList.char ];
                    end
                    missingSymbols = [ newline, missingFcnsChar, missingTypesChar ];
                    mE = MException( message( 'Simulink:CodeImporter:MissingSymbolsInSandbox' ) );
                    mECause = MException( message( 'Simulink:CodeImporter:SymbolsMissingInSandbox', missingSymbols ) );
                    mE = addCause( mE, mECause );
                    throw( mE );
                end
            end
        end

        function tf = sbxHasMissingSymbols( obj )
            tf = ~isempty( obj.CodeInsight.SandboxInfo.CodeInfo.MissingFunctionDeclaration ) ||  ...
                ~isempty( obj.CodeInsight.SandboxInfo.CodeInfo.MissingTypeDefinition );
        end

        function [ filesToAdd, dirsToAdd ] = getFilesToAddToProject( obj )
            outputFolder = obj.qualifiedSettings.OutputFolder;


            simulinkLib = fullfile( outputFolder, obj.LibraryFileName + ".slx" );

            slddFile = string( [  ] );
            if isfile( fullfile( outputFolder, obj.LibraryFileName + ".sldd" ) )
                slddFile = fullfile( outputFolder, obj.LibraryFileName + ".sldd" );
            end


            mldatxFile = string( [  ] );
            if isfile( fullfile( outputFolder, obj.LibraryFileName + ".mldatx" ) )
                mldatxFile = fullfile( outputFolder, obj.LibraryFileName + ".mldatx" );
            end

            filesToAdd = { simulinkLib, slddFile, mldatxFile };

            dirsToAdd = {  };
            if exist( obj.SandboxPath, 'dir' ) == 7
                dirsToAdd = { obj.SandboxPath };
            end
        end



        function loadProjectFile( obj, file )
            try
                fullFilePath = internal.CodeImporter.Tools.convertToFullPath( file, obj.OutputFolder );
                validateFileOnAbsolutePath( obj, fullFilePath, file );
                [ fullPath, filename, ~ ] = fileparts( fullFilePath );
                currDir = pwd;
                cd( fullPath );
                def = feval( filename );
                cd( currDir );


                if isempty( def ) || ~isstruct( def ) || ( ~isfield( def, 'SourceFiles' ) && ~isfield( def, 'IncludeFiles' ) )

                    error( 'The project file is not recognizable. It needs to define a struct with fields containing at least ''SourceFiles'' or ''IncludeFiles''.' );
                end



                f = fields( def );
                for i = 1:length( f )
                    currentField = f{ i };
                    if isprop( obj, currentField )
                        obj.( currentField ) = def.( currentField );
                    end
                    if isprop( obj.CustomCode, currentField )
                        obj.CustomCode.( currentField ) = def.( currentField );
                    end
                    if any( strcmp( currentField, { 'ProjectFolder', 'LibraryRootFolder' } ) )
                        obj.OutputFolder = def.( currentField );
                    end
                    if ( strcmp( currentField, 'ProjectName' ) == 1 )
                        obj.LibraryFileName = def.( currentField );
                    end
                    if ( strcmp( currentField, 'AutoStub' ) == 1 )
                        obj.AutoStubSource = def.( currentField );
                    end
                    if ( strcmp( currentField, 'IncludeFiles' ) == 1 )
                        obj.CustomCode.InterfaceHeaders = def.( currentField );
                    end
                    if ( strcmp( currentField, 'GRL' ) == 1 )
                        obj.CustomCode.MetadataFile = def.( currentField );
                    end
                end

            catch e
                handleError( obj, e );
            end
        end

        function editableSbxExists = editSandbox( obj )












            obj.qualifySettings(  );

            editableSbxExists = false;
            if ~( exist( obj.SandboxPath, 'dir' ) == 7 )

                return ;
            end

            if isempty( obj.CodeInsight.SandboxInfo )


                return ;
            end



            for i = 1:length( obj.CodeInsight.SandboxInfo.HeaderFiles )
                if ~isfile( obj.CodeInsight.SandboxInfo.HeaderFiles( i ) )
                    return ;
                end
            end


            for i = 1:length( obj.CodeInsight.SandboxInfo.IncludeDirs )
                if ~isfolder( obj.CodeInsight.SandboxInfo.IncludeDirs( i ) )
                    return ;
                end
            end













            assert( ~isempty( obj.CodeInsight.SandboxInfo.SourceFiles ),  ...
                "SandboxInfo source file list is empty" );
            isManualStubSrc = contains( obj.CodeInsight.SandboxInfo.SourceFiles,  ...
                fullfile( obj.SandboxPath, 'manualstub' ), 'IgnoreCase', true );

            sourceFilesList = obj.CodeInsight.SandboxInfo.SourceFiles( ~isManualStubSrc );


            for i = 1:length( sourceFilesList )
                if ~isfile( sourceFilesList( i ) )
                    return ;
                end
            end


            if exist( fullfile( obj.SandboxPath, 'manualstub' ), 'dir' ) == 7
                manualStubScrs =  ...
                    internal.CodeImporter.searchFilesInDir(  ...
                    fullfile( obj.SandboxPath, 'manualstub' ), '*.c' );
                sourceFilesList = [ sourceFilesList, manualStubScrs ];
            end

            obj.CodeInsight.SandboxInfo.SourceFiles = sourceFilesList;


            editableSbxExists = true;


            obj.sbxCodeInsightParse( obj.CodeInsight.SandboxInfo, true );






            sandboxAutostubDir = fullfile( obj.SandboxPath, 'autostub' );
            if exist( sandboxAutostubDir, 'dir' ) == 7
                rmdir( sandboxAutostubDir, 's' );
            end


            obj.AutoStubPath = fullfile( obj.SandboxPath, "autostub" );
            if exist( obj.AutoStubPath, 'dir' ) ~= 7
                mkdir( obj.AutoStubPath );
            end

            OutputFile = fullfile( obj.AutoStubPath, "auto_stub.c" );
            OutputHeader = fullfile( obj.AutoStubPath, "auto_stub.h" );
            obj.AutoStubSource = internal.CodeImporter.computeRelativePath( OutputFile, obj.qualifiedSettings.OutputFolder );
            obj.AutoStubInclude = internal.CodeImporter.computeRelativePath( OutputHeader, obj.qualifiedSettings.OutputFolder );


            ok = obj.CodeInsight.SandboxInfo.generateStubFile(  ...
                'OutputFile', OutputFile,  ...
                'Metadata', obj.MetadataInfo,  ...
                'DoSimulinkImportCompliance', true,  ...
                'AddOriginalIncludeList', obj.SandboxSettings.Mode == internal.CodeImporter.SandboxTypeEnum.UseOriginalCode );
            if ~ok
                topErrMsg = MException( message(  ...
                    'Simulink:CodeImporter:AutoStubGenerationFailedError' ) );
                if ~isempty( obj.CodeInsight.SandboxInfo.StubInfo )
                    causeErrMsg = MException( message(  ...
                        'Simulink:CodeImporter:SLTestCodeImporterFailureCause',  ...
                        obj.CodeInsight.SandboxInfo.StubInfo.Errors ) );
                else
                    causeErrMsg = MException( message(  ...
                        'Simulink:CodeImporter:SLTestCodeImporterFailureCause',  ...
                        obj.CodeInsight.SandboxInfo.Errors ) );
                end
                topErrMsg = addCause( topErrMsg, causeErrMsg );
                throw( topErrMsg );
            end








            if obj.SandboxSettings.generateInterfaceHeader(  )

                interfaceHeaderFile =  ...
                    fullfile( obj.SandboxPath, 'include', obj.InterfaceHeaderFileName );
                if ~isempty( obj.CodeInsight.SandboxInfo.StubInfo ) &&  ...
                        ~isempty( obj.CodeInsight.SandboxInfo.StubInfo.SourceFiles ) &&  ...
                        ~isempty( obj.CodeInsight.SandboxInfo.StubInfo.HeaderFiles )
                    codeInsightObj = obj.CodeInsight.SandboxInfo.StubInfo;
                else
                    codeInsightObj = obj.CodeInsight.SandboxInfo;
                end




                obj.sbxCodeInsightParse( codeInsightObj, true );




                includeDir = fullfile( obj.SandboxPath, 'include' );
                if exist( includeDir, 'dir' ) ~= 7
                    mkdir( includeDir )
                end
                interfaceHeaderSettings = { 'CodeInsightObj', codeInsightObj ...
                    , 'OutputFile', interfaceHeaderFile };
                if obj.SandboxSettings.Mode == internal.CodeImporter.SandboxTypeEnum.GeneratePreprocessedSource
                    interfaceHeaderSettings = [ interfaceHeaderSettings,  ...
                        { 'IsPreprocessed' }, { true } ];
                end

                codeInsightObj.CodeInfo.generateInterfaceHeader( interfaceHeaderSettings{ : } );
            end

            obj.updateSandboxCustomCode(  );
            [ cSettingsChecksum, cInterfaceChecksum, cFullCheckSum ] =  ...
                obj.SbxCustomCode.computeChecksum(  );
            obj.SbxCustomCode.updateChecksum(  ...
                cSettingsChecksum, cInterfaceChecksum, cFullCheckSum );
        end
    end
end


