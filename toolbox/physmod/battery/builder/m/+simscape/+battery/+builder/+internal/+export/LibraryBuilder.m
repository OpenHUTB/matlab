classdef ( Sealed = true, Hidden = true )LibraryBuilder

    properties
        LibraryDirectory
        BatteriesPackageName = "Batteries";
        MaskParameters( 1, 1 )string{ mustBeMember( MaskParameters,  ...
            [ "NumericValues", "VariableNames" ] ) } = "NumericValues";
        MaskInitialTargets( 1, 1 )string{ mustBeMember( MaskInitialTargets,  ...
            [ "NumericValues", "VariableNames" ] ) } = "NumericValues";
    end

    properties ( Dependent = true, SetAccess = private )
        FileNameMaskVariableNames;
    end

    properties ( Access = private )
        HighestSscLevel;
        BatteryLevelIterator;
        BlockDatabase = simscape.battery.builder.internal.export.BlockDatabase;
    end

    properties ( Access = private, Constant )
        RelativePackageName = dictionary( [ simscape.battery.builder.ParallelAssembly.Type, simscape.battery.builder.Module.Type ],  ...
            [ "ParallelAssemblies", "Modules" ] );
    end

    methods
        function obj = LibraryBuilder( batteryTree )

            arguments
                batteryTree( 1, 1 ){ mustBeA( batteryTree, [ "simscape.battery.builder.ParallelAssembly",  ...
                    "simscape.battery.builder.Module", "simscape.battery.builder.ModuleAssembly", "simscape.battery.builder.Pack" ] ) }
            end
            obj.BatteryLevelIterator = simscape.battery.builder.internal.export.BatteryLevelIterator( batteryTree );
            obj = obj.setHighestSscLevel( batteryTree );
            obj.LibraryDirectory = cd;
        end

        function buildLibraries( obj )

            obj.assertModelNotLoaded( obj.BatteriesPackageName );
            obj.assertModelNotLoaded( obj.BatteriesPackageName.append( "_lib" ) );
            obj.assertModelDoesNotExist( fullfile( obj.LibraryDirectory, obj.BatteriesPackageName.append( ".slx" ) ) );
            obj.assertModelDoesNotExist( fullfile( obj.LibraryDirectory, obj.BatteriesPackageName.append( "_lib.slx" ) ) );
            obj.assertModelDoesNotExistOnPath( obj.BatteriesPackageName );
            obj.assertModelDoesNotExistOnPath( obj.BatteriesPackageName.append( "_lib" ) );
            obj.assertDirectoryExists( fullfile( obj.LibraryDirectory, "+" + obj.BatteriesPackageName ) );
            if obj.MaskParameters == "VariableNames" || obj.MaskInitialTargets == "VariableNames"
                obj.assertFileExists( obj.FileNameMaskVariableNames );
            end
            obj.assertDirectoryWriteAccess( obj.LibraryDirectory );



            currentDirectory = pwd;
            cd( obj.LibraryDirectory );
            directoryCleanup = onCleanup( @(  )cd( currentDirectory ) );

            fullBuildDirectory = string( pwd );
            obj.assertNoClassFolder( fullBuildDirectory );
            obj.assertNoPackageFolder( fullBuildDirectory );

            while obj.BatteryLevelIterator.hasNextLevel(  )
                batteries = obj.BatteryLevelIterator.getNextLevel(  );
                obj = obj.createBlocksFor( batteries );
            end
            if obj.MaskParameters == "VariableNames" || obj.MaskInitialTargets == "VariableNames"
                obj.createVariableNames;
            end
        end

        function value = get.FileNameMaskVariableNames( obj )

            value = fullfile( obj.BatteriesPackageName + "_param.m" );
        end
    end

    methods ( Access = private )
        function obj = createBlocksFor( obj, batteryObjects )

            arguments
                obj
                batteryObjects( 1, : ){ mustBeA( batteryObjects, [ "simscape.battery.builder.ParallelAssembly",  ...
                    "simscape.battery.builder.Module", "simscape.battery.builder.ModuleAssembly", "simscape.battery.builder.Pack" ] ) }
            end
            import simscape.battery.builder.internal.export.*

            for blockIdx = 1:length( batteryObjects )
                currentBatteryObject = batteryObjects( blockIdx );
                switch currentBatteryObject.Type
                    case simscape.battery.builder.ParallelAssembly.Type
                        relativePackagePath = obj.getRelativePackagePath( currentBatteryObject.Type );
                        obj.createDirectory( relativePackagePath );
                        batteryTypeCreator = ParallelAssemblyCreator( currentBatteryObject, relativePackagePath, obj.isHighestBatteryLevel );
                    case simscape.battery.builder.Module.Type
                        relativePackagePath = obj.getRelativePackagePath( currentBatteryObject.Type );
                        obj.createDirectory( relativePackagePath );
                        batteryTypeCreator = ModuleCreator( currentBatteryObject, relativePackagePath, obj.isHighestBatteryLevel, obj.BlockDatabase );
                    case simscape.battery.builder.ModuleAssembly.Type
                        filePath = string( fullfile( obj.LibraryDirectory ) );
                        batteryTypeCreator = ModuleAssemblyCreator( currentBatteryObject, filePath, obj.isHighestBatteryLevel, obj.BlockDatabase, obj.BatteriesPackageName );
                    case simscape.battery.builder.Pack.Type
                        filePath = string( fullfile( obj.LibraryDirectory ) );
                        batteryTypeCreator = PackCreator( currentBatteryObject, filePath, obj.isHighestBatteryLevel, obj.BlockDatabase, obj.BatteriesPackageName );
                    otherwise

                end


                block = batteryTypeCreator.createBlock;
                obj.BlockDatabase = obj.BlockDatabase.addBlock( block );
            end

            obj = obj.lazySscBuild( currentBatteryObject.Type );
        end

        function obj = createVariableNames( obj )

            if obj.MaskParameters == "VariableNames" || obj.MaskInitialTargets == "VariableNames"

                [ ~, f, ~ ] = fileparts( obj.FileNameMaskVariableNames );
                fprintf( "%s\n", getString( message( "physmod:battery:builder:export:GeneratingScript", f, pwd ) ) );
            end


            packageLibraryShortName = obj.BatteriesPackageName.append( "_lib" );
            packageLibrary = fullfile( obj.LibraryDirectory,  ...
                packageLibraryShortName );
            load_system( packageLibrary );
            packageLibraryCleanup = onCleanup( @(  )bdclose( packageLibrary ) );


            graphicalLibraryShortName = obj.BatteriesPackageName;
            graphicalLibrary = fullfile( obj.LibraryDirectory,  ...
                graphicalLibraryShortName );
            if exist( graphicalLibrary, "file" )
                load_system( graphicalLibrary );
                graphicalLibraryCleanup = onCleanup( @(  )bdclose( graphicalLibrary ) );
                existGraphicalLibrary = true;
            else
                existGraphicalLibrary = false;
            end


            packageLibraryBlocks = foundation.internal.parameterization.SimscapeBlock(  ...
                find_system( packageLibraryShortName, 'BlockType', 'SimscapeBlock' ),  ...
                MaskParameters = "VariableNames" );
            if existGraphicalLibrary

                firstLevelBlocks = find_system( graphicalLibraryShortName,  ...
                    'SearchDepth', 1,  ...
                    'Type', 'block' );
                blockOfInterestIdx = cellfun( @( x )~all( x == 0 ), get_param( firstLevelBlocks, 'Ports' ) );
                mainGraphicalBlock = firstLevelBlocks{ blockOfInterestIdx };
            end

            if obj.MaskParameters == "VariableNames"

                headerName = 'Battery parameters';
                sectionName = 'Type';
                packageLibraryBlocks.exportMaskVariableNamesToFile(  ...
                    obj.FileNameMaskVariableNames, headerName, sectionName );

                set_param( packageLibraryShortName, "Lock", "off" );
                packageLibraryBlocks.updateMaskToVariableNames( sectionName );

                fileattrib( packageLibraryShortName.append( ".slx" ), "+w" );
                save_system( packageLibrary );
                fileattrib( packageLibraryShortName.append( ".slx" ), "-w" );

                if existGraphicalLibrary
                    set_param( graphicalLibraryShortName, "Lock", "off" );
                    for packageLibraryBlockIdx = 1:length( packageLibraryBlocks )
                        thisPackageLibraryBlock = packageLibraryBlocks( packageLibraryBlockIdx );

                        graphicalLibraryBlocks = foundation.internal.parameterization.SimscapeBlock(  ...
                            find_system( graphicalLibraryShortName, 'ReferenceBlock', thisPackageLibraryBlock.Name ),  ...
                            MaskParameters = "VariableNames" );

                        graphicalLibraryBlocks.updateMaskToVariableNames( sectionName );
                    end
                    blocksToUpdate = find_system( mainGraphicalBlock,  ...
                        'ReferenceBlock', 'fl_lib/Electrical/Electrical Elements/Resistor' );

                    if ~isempty( blocksToUpdate )
                        resistorBlocks = foundation.internal.parameterization.SimscapeBlock(  ...
                            blocksToUpdate,  ...
                            MaskParameters = "VariableNames" );

                        headerName = 'Battery resistances';
                        sectionName = 'Name';
                        textToRemove = [ mainGraphicalBlock, '/' ];

                        resistorBlocks.exportMaskVariableNamesToFile(  ...
                            obj.FileNameMaskVariableNames, headerName, sectionName, textToRemove );

                        resistorBlocks.updateMaskToVariableNames( sectionName, textToRemove );
                    end

                    save_system( graphicalLibrary );
                end
            end
            if obj.MaskInitialTargets == "VariableNames"
                if existGraphicalLibrary
                    set_param( graphicalLibraryShortName, "Lock", "off" );

                    blocksToUpdate = find_system( mainGraphicalBlock,  ...
                        'regexp', 'on',  ...
                        'ReferenceBlock', "^" + packageLibraryShortName );
                    graphicalLibraryBlocks = foundation.internal.parameterization.SimscapeBlock(  ...
                        blocksToUpdate,  ...
                        MaskInitialTargets = "VariableNames" );

                    headerName = 'Battery initial targets';
                    sectionName = 'Name';
                    textToRemove = [ mainGraphicalBlock, '/' ];

                    graphicalLibraryBlocks.exportMaskVariableNamesToFile(  ...
                        obj.FileNameMaskVariableNames, headerName, sectionName, textToRemove );

                    graphicalLibraryBlocks.updateMaskToVariableNames( sectionName, textToRemove );

                    save_system( graphicalLibrary );
                else
                    state = warning( "backtrace" );
                    warning( "off", "backtrace" );
                    warning( message( "physmod:battery:builder:export:MaskInitialTargetsNoEffect" ) );
                    warning( state );
                end
            end

        end

        function obj = lazySscBuild( obj, currentType )

            switch currentType
                case obj.HighestSscLevel

                    ssc_build( fullfile( obj.BatteriesPackageName ) );
                    libraryName = obj.BatteriesPackageName + "_lib";
                    obj.BlockDatabase.setSimscapeBlocksLibraryName( libraryName );
                    obj.addSimscapeBlockCallback( libraryName );
                otherwise

            end
        end
    end

    methods ( Access = private )
        function obj = setHighestSscLevel( obj, battery )


            switch battery.Type
                case simscape.battery.builder.ParallelAssembly.Type
                    obj.HighestSscLevel = simscape.battery.builder.ParallelAssembly.Type;
                otherwise
                    obj.HighestSscLevel = simscape.battery.builder.Module.Type;
            end
        end

        function relativePackagePath = getRelativePackagePath( obj, batteryType )

            if obj.isHighestBatteryLevel
                relativePackagePath = "+" + obj.BatteriesPackageName;
            else
                typePackageName = obj.RelativePackageName( batteryType );
                relativePackagePath = fullfile( "+" + obj.BatteriesPackageName, "+" + typePackageName );
            end
        end

        function isHighestLevel = isHighestBatteryLevel( obj )


            isHighestLevel = ~obj.BatteryLevelIterator.hasNextLevel;
        end
    end

    methods ( Access = private, Static )
        function addSimscapeBlockCallback( libraryName )




            load_system( libraryName );
            set_param( libraryName, 'Lock', 'off' )
            copyFcnText = "battery_builder_rtmsupport('copyfcn',gcbh);";
            preCopyFcnText = "battery_builder_rtmsupport('precopyfcn',gcbh);";
            preDeleteFcnText = "battery_builder_rtmsupport('predeletefcn',gcbh);";
            loadFcnText = "battery_builder_rtmsupport('loadfcn',gcbh);";
            libraryBlocks = getfullname( Simulink.findBlocksOfType( libraryName, 'SimscapeBlock' ) );
            if numel( libraryBlocks ) > 30
                libraryBlocks = cellstr( libraryBlocks );
            end
            for libraryBlocksIdx = 1:numel( libraryBlocks )
                existingCopyFcn = convertCharsToStrings( get_param( libraryBlocks{ libraryBlocksIdx }, 'CopyFcn' ) );
                existingPreDeleteFcn = convertCharsToStrings( get_param( libraryBlocks{ libraryBlocksIdx }, 'PreDeleteFcn' ) );
                existingLoadFcn = convertCharsToStrings( get_param( libraryBlocks{ libraryBlocksIdx }, 'LoadFcn' ) );
                existingPreCopyFcn = convertCharsToStrings( get_param( libraryBlocks{ libraryBlocksIdx }, 'PreCopyFcn' ) );
                set_param( libraryBlocks{ libraryBlocksIdx },  ...
                    'CopyFcn', existingCopyFcn + newline + copyFcnText,  ...
                    'PreCopyFcn', existingPreCopyFcn + newline + preCopyFcnText,  ...
                    'PreDeleteFcn', existingPreDeleteFcn + newline + preDeleteFcnText,  ...
                    'LoadFcn', existingLoadFcn + newline + loadFcnText );
            end
            fileattrib( strcat( libraryName, ".slx" ), '+w' );
            set_param( libraryName, 'Lock', 'on' );
            save_system( libraryName );
            fileattrib( strcat( libraryName, ".slx" ), '-w' );
            close_system( libraryName );
        end

        function createDirectory( directory )

            if ~isfolder( directory )
                mkdir( directory );
            end
        end

        function assertModelNotLoaded( model )

            assert( ~bdIsLoaded( model ),  ...
                message( "physmod:battery:builder:export:ModelLoaded", model ) );
        end

        function assertModelDoesNotExist( model )

            assert( ~isfile( model ),  ...
                message( "physmod:battery:builder:export:ModelExists", model ) );
        end

        function assertModelDoesNotExistOnPath( model )

            if exist( model, "file" ) == 4
                p = fileparts( which( model ) );
                assert( false,  ...
                    message( "physmod:battery:builder:export:ModelExistsOnPath", model, p ) );
            end
        end

        function assertDirectoryExists( directory )

            assert( ~isfolder( directory ),  ...
                message( "physmod:battery:builder:export:DirectoryExists", directory ) );
        end

        function assertFileExists( file )

            assert( ~isfile( file ),  ...
                message( "physmod:battery:builder:export:FileExists", file ) );
        end

        function assertDirectoryWriteAccess( directory )

            [ status, values ] = fileattrib( directory );
            hasWritePermissions = status && values.UserWrite;
            assert( hasWritePermissions,  ...
                message( "physmod:battery:builder:export:NoWriteAccess", directory ) );
        end

        function assertNoClassFolder( directory )

            splitDirectory = strsplit( directory, filesep );
            assert( ~splitDirectory( end  ).startsWith( "@" ),  ...
                message( "physmod:battery:builder:export:DirectoryClassFolder", directory ) );
        end

        function assertNoPackageFolder( directory )

            splitDirectory = strsplit( directory, filesep );
            assert( ~any( splitDirectory.startsWith( "+" ) ),  ...
                message( "physmod:battery:builder:export:DirectoryPackageFolder", directory ) );
        end
    end
end


