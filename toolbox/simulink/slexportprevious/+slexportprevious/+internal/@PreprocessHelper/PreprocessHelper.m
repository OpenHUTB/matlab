
classdef PreprocessHelper < handle





    properties ( GetAccess = 'public', SetAccess = 'private' )
        modelFile
        modelName
        targetVersion
        origModelName;
    end

    properties ( Access = 'private' )

        breakUserLinks
        breakToolboxLinks

        temporaryModel
        temporaryLibrary
        temporaryViewerLibrary

        replacedBlockCount;
        blockTypesNotified = {  };

        callbackDispatcher;

        generatedRules;
        partSpecificGeneratedRules;

    end

    properties ( Dependent )
        ver;
    end

    properties ( Access = 'public' )
        progressFcn
        errorFcn
        useGUI;
    end

    methods ( Access = 'public' )

        function obj = PreprocessHelper( modelName, modelFile, targetVersion,  ...
                breakUserLinks, breakToolboxLinks )
            obj.modelName = char( modelName );
            obj.modelFile = char( modelFile );
            obj.targetVersion = targetVersion;
            obj.breakUserLinks = breakUserLinks;
            obj.breakToolboxLinks = breakToolboxLinks;
            obj.progressFcn = @( val )fprintf( 'Progress: %2d%%\n', round( val * 100 ) );
            obj.errorFcn = @( E )obj.reportWarning( E.identifier, '%s', E.message );
            obj.replacedBlockCount = 0;
            obj.useGUI = false;
        end

        function delete( obj )
            if ~isempty( obj.temporaryModel )
                if bdIsLoaded( obj.temporaryModel )
                    close_system( obj.temporaryModel, 0 );
                end
                delete( obj.tempFilePath( obj.temporaryModel ) );
            end
            if ~isempty( obj.temporaryLibrary )
                if bdIsLoaded( obj.temporaryLibrary )
                    close_system( obj.temporaryLibrary, 0 );
                end
                delete( obj.tempFilePath( obj.temporaryLibrary ) );
            end
        end

        function dynamicRulesStruct = run( obj, sourceModelName )

            obj.progressFcn( 0 );


            oldbackup = adjustAutosave( obj, 0 );
            cleanup3 = onCleanup( @(  )adjustAutosave( obj, oldbackup ) );


            closesys = onCleanup( @(  )close_system( obj.modelName, 0, 'SkipCloseFcn', true ) );

            try
                dynamicRulesStruct = obj.doPreprocess( sourceModelName );
            catch e


                obj.errorFcn( e );

                dynamicRulesStruct = [  ];



                obj.saveModel;

            end
            obj.progressFcn( 1 );
        end

        function reportReplacedBlocks( obj )
            if obj.replacedBlockCount > 0

                cmd = sprintf( "getfullname(Simulink.findBlocks('%s', 'MaskType', 'Replaced Block'))", obj.modelName );
                if feature( 'hotlinks' )

                    openmodel = sprintf( '<a href="matlab:open_system ''%s''">%s</a>', obj.modelFile, obj.modelName );
                    findblocks = sprintf( '<a href="matlab:%s">%s</a>', cmd, cmd );
                else
                    openmodel = obj.modelName;
                    findblocks = cmd;
                end

                w = warning( 'backtrace', 'off' );
                restore_warn = onCleanup( @(  )warning( w ) );

                ex = MException( message( 'Simulink:ExportPrevious:UnsupportedBlocksReplaced',  ...
                    obj.replacedBlockCount, obj.targetVersion.release, openmodel, findblocks ) );


                Simulink.output.highPriorityWarning( ex );
            end
        end




        function model = getTempMdl( obj )
            model = obj.temporaryModel;
            if isempty( model )
                model = generateTempName( obj );
                obj.temporaryModel = model;
                new_system( model, 'Model' );
                save_system( model, obj.tempFilePath( model ) );
            end
        end




        function lib = getTempLib( obj )
            lib = obj.temporaryLibrary;
            if isempty( lib )
                lib = generateTempName( obj );
                obj.temporaryLibrary = lib;
                new_system( lib, 'Library' );
                save_system( lib, obj.tempFilePath( lib ) );
                set_param( lib, 'lock', 'off' );
            end
        end





        function lib = getTempViewerLib( obj )
            lib = obj.temporaryViewerLibrary;
            if isempty( lib )
                lib = generateTempName( obj );
                obj.temporaryViewerLibrary = lib;
                new_system( lib, 'Library' );
                set_param( lib, 'LibraryType', 'ssMgrViewerLibrary' );
                save_system( lib, obj.tempFilePath( lib ) );
                set_param( lib, 'lock', 'off' );
            end
        end



        function b = findBlocks( obj, varargin )
            b = getfullname( Simulink.findBlocks( obj.modelName, varargin{ : } ) );
            if ~iscell( b )
                b = { b };
            end
        end



        function b = findBlocksOfType( obj, blockType, varargin )
            b = getfullname( Simulink.findBlocksOfType( obj.modelName, blockType, varargin{ : } ) );
            if ~iscell( b )
                b = { b };
            end
        end



        function b = findBlocksWithMaskType( obj, maskType, varargin )
            b = obj.findBlocks( 'MaskType', maskType, varargin{ : } );
        end




        function b = findLibraryLinksTo( obj, refBlock, varargin )
            b = obj.findBlocks( 'ReferenceBlock', refBlock, varargin{ : } );
        end



        function appendRule( obj, rule, targetPart )
            arguments
                obj slexportprevious.internal.PreprocessHelper
                rule char
                targetPart char = ''
            end
            obj.appendRules( { rule }, targetPart );
        end



        function appendRules( obj, rules, targetPart )
            arguments
                obj slexportprevious.internal.PreprocessHelper
                rules
                targetPart char = ''
            end
            if ischar( rules )
                rules = { rules };
            end
            assert( iscellstr( rules ), 'Rules must be a cellstr' );
            for i = 1:numel( rules )
                Simulink.loadsave.ExportRuleProcessor.validateRule( rules{ i } );
            end
            assert( ~isempty( obj.generatedRules ) )
            assert( isa( obj.partSpecificGeneratedRules, 'table' ) );
            if isempty( targetPart )
                obj.generatedRules.appendRules( rules );
            else

                obj.partSpecificGeneratedRules = [ obj.partSpecificGeneratedRules;{ targetPart, rules } ];
            end
        end

        function removeBlocksOfType( obj, type )
            b = obj.findBlocksOfType( type );
            obj.replaceWithEmptySubsystem( b );
        end

        function removeLibraryLinksTo( obj, refblk )
            b = obj.findLibraryLinksTo( refblk );
            obj.replaceWithEmptySubsystem( b );
        end

        function incrementReplacedBlockCount( obj )
            obj.replacedBlockCount = obj.replacedBlockCount + 1;
        end

        function reportWarning( ~, id, varargin )


            if isa( id, 'MException' )
                e = id;
            else
                e = MException( message( id, varargin{ : } ) );
            end
            w = warning( 'backtrace', 'off' );
            MSLDiagnostic( e ).reportAsWarning;
            warning( w );
        end

        function blockTypeStr = getBlockTypeForDisplay( ~, block )
            blockTypeStr = get_param( block, 'MaskType' );
            if isempty( blockTypeStr )
                blockTypeStr = get_param( block, 'BlockType' );
            end
        end

        function enableTestMode( obj )
            obj.callbackDispatcher = slexportprevious.internal.CallbackDispatcher(  ...
                'TestModeSrc', 'TestModeTarget', 'TestVersion' );
            obj.generatedRules = slexportprevious.RuleSet;
            obj.partSpecificGeneratedRules = table( {  }, {  }, 'VariableNames', { 'Part', 'Rules' } );
        end


        function [ rules, partSpecific ] = getGeneratedRules( obj )
            rules = obj.generatedRules;
            partSpecific = obj.partSpecificGeneratedRules;
        end

    end

    methods ( Access = 'private' )

        function rulesStruct = doPreprocess( obj, sourceModelName )



            w = warning( 'off' );
            restorewarn = onCleanup( @(  )warning( w ) );



            harness_feature = slfeature( 'ExternalHarnessInfoMapping', 2 );
            restorefeat = onCleanup( @(  )slfeature( 'ExternalHarnessInfoMapping', harness_feature ) );

            obj.loadSystemFromFile(  );
            slInternal( 'associate_with_file', obj.modelName, obj.modelFile );
            delete( restorewarn );

            set_param( obj.modelName, 'Lock', 'off' );


            w = warning( 'off', 'Simulink:Engine:MdlFileShadowedByFile' );
            restorewarn = onCleanup( @(  )warning( w ) );


            w2 = warning( 'off', 'Simulink:Commands:SaveMdlWithDirtyWorkspace' );
            restorewarn2 = onCleanup( @(  )warning( w2 ) );

            obj.progressFcn( 0.1 );






            if isR2019aOrEarlier( obj.targetVersion )
                slInternal( 'convertAllSSRefBlocksToSubsystemBlocks',  ...
                    get_param( obj.modelName, 'handle' ) );
            end


            if obj.breakUserLinks || obj.breakToolboxLinks
                if obj.breakToolboxLinks
                    if obj.breakUserLinks
                        action = 'all';
                    else
                        action = 'toolbox';
                    end
                else
                    action = 'user';
                end
                slInternal( 'breakLibraryLinks', obj.modelName, action );
            end

            current_progress = 0.15;
            obj.progressFcn( 0.15 );



            if ( isRelease( obj.targetVersion, 'R2019b' ) &&  ...
                    bdIsSubsystem( obj.modelName ) )
                Simulink.harness.internal.deleteSpecificHarnesses( obj.modelName, 'R2019b' )
            elseif ( ~isR2021aOrEarlier( obj.targetVersion ) && isMDL( obj.ver ) )




                Simulink.harness.internal.deleteAllHarnesses( obj.modelName );
            end

            harnessList = Simulink.harness.find( char( obj.modelName ) );
            numHarnesses = numel( harnessList );


            progress_per_bd = 0.75 / ( numHarnesses + 1 );


            oldFcn = obj.progressFcn;
            obj.progressFcn = @( val )oldFcn( current_progress + val * progress_per_bd );
            obj.runPreprocessFunctions( sourceModelName );
            rulesStruct.SystemBlockDiagram = obj.generatedRules;
            obj.generatedRules = [  ];
            obj.progressFcn = oldFcn;


            for h = 1:numHarnesses
                current_progress = current_progress + progress_per_bd;

                harnessName = harnessList( h ).name;
                Simulink.harness.load( harnessList( h ).ownerFullPath,  ...
                    harnessName );
                harness_cleanup = onCleanup( @(  )close_system( harnessName, 0 ) );

                ph = slexportprevious.internal.PreprocessHelper(  ...
                    harnessName, obj.modelFile, obj.targetVersion,  ...
                    false, false );
                ph.errorFcn = obj.errorFcn;
                ph.progressFcn = @( val )obj.progressFcn( current_progress + val * progress_per_bd );



                harnessID = get_param( harnessName, 'HarnessID' );
                ph.runPreprocessFunctions( harnessName );
                rulesStruct.Harnesses.( harnessID ) = ph.generatedRules;
                obj.partSpecificGeneratedRules = [ obj.partSpecificGeneratedRules;ph.partSpecificGeneratedRules ];


                set_param( harnessName, 'Dirty', 'on' );

                delete( harness_cleanup );




            end

            rulesStruct.PartSpecific = obj.partSpecificGeneratedRules;


            delete( restorewarn );



            obj.saveModel;

            obj.progressFcn( 1 );

            obj.generatedRules = [  ];
            obj.partSpecificGeneratedRules = [  ];
        end

        function runPreprocessFunctions( obj, sourceModelName )




            roblks = find_system( char( obj.modelName ), 'RegExp', 'on',  ...
                'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
                'Permissions', 'ReadOnly', 'LinkStatus', 'none|inactive' );
            nrblks = find_system( char( obj.modelName ), 'RegExp', 'on',  ...
                'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
                'Permissions', 'NoReadOrWrite', 'LinkStatus', 'none|inactive' );
            fixedblks = [ roblks, nrblks ];

            for i = 1:length( fixedblks )
                set_param( fixedblks{ i }, 'Permissions', 'ReadWrite' );
            end

            obj.progressFcn( 0.1 );


            d = slexportprevious.internal.CallbackDispatcher( sourceModelName,  ...
                char( obj.modelName ),  ...
                obj.targetVersion );
            obj.callbackDispatcher = d;
            d.errorFcn = obj.errorFcn;

            d.progressFcn = @( val )obj.progressFcn( 0.1 + val * 0.8 );
            d.useGUI = obj.useGUI;

            obj.generatedRules = slexportprevious.RuleSet;
            obj.partSpecificGeneratedRules = table( {  }, {  }, 'VariableNames', { 'Part', 'Rules' } );

            obj.origModelName = sourceModelName;
            d.runCallbacks( obj );
            obj.origModelName = [  ];

            obj.callbackDispatcher = [  ];


            for i = 1:length( roblks )
                set_param( roblks{ i }, 'Permissions', 'ReadOnly' );
            end
            for i = 1:length( nrblks )
                set_param( nrblks{ i }, 'Permissions', 'NoReadOrWrite' );
            end

            if isR2007aOrEarlier( obj.targetVersion )


                len = get_param( obj.modelName, 'MaxMDLFileLineLength' );
                if len > 128
                    set_param( obj.modelName, 'MaxMDLFileLineLength', 128 );
                end
            end
        end

        function saveModel( obj )


            set_param( obj.modelName, 'Dirty', 'on' );





            save_system( obj.modelName, obj.modelFile,  ...
                'TargetReleaseFormat', obj.targetVersion.release,  ...
                'SkipSaveFcns', true );
        end




        function old_backup = adjustAutosave( ~, new_backup )

            cur = get_param( 0, 'AutoSaveOptions' );
            if nargout
                old_backup = cur.SaveBackupOnVersionUpgrade;
            end
            if nargin
                cur.SaveBackupOnVersionUpgrade = new_backup;
                set_param( 0, 'AutoSaveOptions', cur );
            end
        end

    end

    methods ( Access = 'public' )

        function name = generateTempName( ~ )
            [ ~, name ] = slfileparts( tempname );
            name = [ 'slexportprevious_', name ];
            if ~exist( name )%#ok
                if ~bdIsLoaded( name )
                    return ;
                end
            end
        end

        function filename = tempFilePath( ~, name )
            filename = slfullfile( tempdir, [ name, '.slx' ] );
        end

    end

    methods
        function v = get.ver( obj )
            v = saveas_version( obj.targetVersion );
        end

    end
    methods ( Access = 'protected' )

        function loadSystemFromFile( obj )
            Simulink.internal.newSystemFromFile( obj.modelName, obj.modelFile, ExecuteCallbacks = false );
        end
    end
end

