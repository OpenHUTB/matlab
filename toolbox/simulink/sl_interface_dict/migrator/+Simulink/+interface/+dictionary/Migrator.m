classdef Migrator < handle

























    properties ( Access = private )

        ContextName;
        InterfaceDictionaryName;


        ComponentsDictionaryMap
        ContextVariables
        VariablesToDelete;
        InterfaceDictionaryHandle;
        DAInterfaceDictionary;
        DASourceContext;
        AppliedFlag = false;
        LinkToDictionary = false;
    end

    properties ( Hidden, Access = public )
        UpdateDictionaryReferences;
    end

    properties ( Access = public )






        DeleteFromOriginalSource ...
            { mustBeNumericOrLogical }
        ConflictResolutionPolicy ...
            { mustBeMember( ConflictResolutionPolicy, [ "OverwriteInterfaceDictionary", "KeepInterfaceDictionary", "Error" ] ) } = "Error";
    end

    properties ( SetAccess = private )



        DataTypesToMigrate;
        InterfacesToMigrate;
        ConflictObjects;
        UnusedObjects;
        UnsupportedMigration
    end

    methods ( Access = public )

        function this = Migrator( contextName, namedargs )


            arguments
                contextName{ mustBeTextScalar, mustBeNonzeroLengthText }
                namedargs.InterfaceDictionaryName{ mustBeTextScalar } = ''
                namedargs.DeleteFromOriginalSource{ mustBeNumericOrLogical } = true
                namedargs.ConflictResolutionPolicy{ mustBeMember( namedargs.ConflictResolutionPolicy, [ "OverwriteInterfaceDictionary", "KeepInterfaceDictionary", "Error" ] ) } = "Error";
            end

            this.ContextName = contextName;
            this.InterfaceDictionaryName = convertStringsToChars( namedargs.InterfaceDictionaryName );
            this.InterfaceDictionaryName = this.dropPath( this.InterfaceDictionaryName );
            this.DeleteFromOriginalSource = namedargs.DeleteFromOriginalSource;
            this.ConflictResolutionPolicy = namedargs.ConflictResolutionPolicy;


            this.UpdateDictionaryReferences = true;


            this.ComponentsDictionaryMap = containers.Map;


            loadContextModel( this );
        end

        function analyze( this )



            this.DataTypesToMigrate = {  };
            this.InterfacesToMigrate = {  };
            this.ConflictObjects = {  };
            this.UnusedObjects = {  };
            this.UnsupportedMigration = {  };

            this.VariablesToDelete = {  };
            this.AppliedFlag = false;
            remove( this.ComponentsDictionaryMap, keys( this.ComponentsDictionaryMap ) );



            this.DAInterfaceDictionary = Simulink.data.DataAccessor.createForOutputData( this.InterfaceDictionaryName );

            initAnalyzeForModelContext( this );

            for i = 1:size( this.ContextVariables )
                varId = this.DASourceContext.identifyByName( this.ContextVariables( i ).Name );

                if ~isempty( varId )
                    variable = this.DASourceContext.getVariable( varId( 1 ) );



                    if ~this.doesMigratorHandleClass( variable )
                        continue ;
                    end


                    if this.isLibrarySLDDSource( this.ContextVariables( i ).Users, varId( 1 ).getDataSourceFriendlyName )
                        unsupportedItem.Name = varId( 1 ).Name;
                        unsupportedItem.Source = varId( 1 ).getDataSourceFriendlyName;
                        unsupportedItem.Reason = message( 'interface_dictionary:migrator:unsupportedLibrarySLDDMigrate' ).getString;
                        this.UnsupportedMigration{ end  + 1 } = unsupportedItem;
                        continue ;
                    end
                end



                migrate = length( varId ) == 1 && ~this.DAInterfaceDictionary.hasVariable( varId.Name );



                if length( varId ) > 1
                    migrate = this.handleDuplicates( varId );




                elseif length( varId ) == 1 && this.DAInterfaceDictionary.hasVariable( varId.Name )

                    this.handleInterfaceDictionaryDuplicates( varId );
                    migrate = false;
                end

                if migrate

                    this.addElementsToMigrate( varId( 1 ), this.ContextVariables( i ) );
                end
            end
        end

        function apply( this )


            if isAnalysisPerformed( this )
                DAStudio.warning( 'interface_dictionary:migrator:emptyAnalysis' );
                return ;
            end

            if this.AppliedFlag
                DAStudio.warning( 'interface_dictionary:migrator:alreadyApplied' );
                return ;
            end


            this.DAInterfaceDictionary.captureVisibleVariableNames(  );


            switch ( this.ConflictResolutionPolicy )
                case 'OverwriteInterfaceDictionary'
                    overwriteDictionaryEntriesInConflict( this );

                case 'KeepInterfaceDictionary'


                case 'Error'
                    if ~isempty( this.ConflictObjects )
                        DAStudio.error( 'interface_dictionary:migrator:conflicts' );
                    end
            end


            interfaceEntries = '';
            dataTypesEntries = '';


            for i = 1:length( this.InterfacesToMigrate )
                varId = this.DASourceContext.identifyByName( this.InterfacesToMigrate{ i }.Name );
                entry = this.DASourceContext.getVariable( varId( 1 ) );
                interfaceEntries{ end  + 1 } = entry;%#ok
            end


            for i = 1:length( this.DataTypesToMigrate )
                varId = this.DASourceContext.identifyByName( this.DataTypesToMigrate{ i }.Name );
                entry = this.DASourceContext.getVariable( varId( 1 ) );



                entry = this.adapt( entry );
                dataTypesEntries{ end  + 1 } = entry;%#ok
            end


            this.DASourceContext.captureVariableValues( [ this.VariablesToDelete{ : } ] );


            for i = 1:length( this.VariablesToDelete )
                this.DASourceContext.deleteVariable( this.VariablesToDelete{ i } );
            end


            for i = 1:length( this.InterfacesToMigrate )
                entry = interfaceEntries{ i };
                this.InterfaceDictionaryHandle.addDataInterface( this.InterfacesToMigrate{ i }.Name, 'SimulinkBus', entry );
            end


            for i = 1:length( this.DataTypesToMigrate )
                entry = dataTypesEntries{ i };
                this.InterfaceDictionaryHandle.addDataTypeUsingSLObj( this.DataTypesToMigrate{ i }.Name, entry );
            end


            updateModelDictionaryReferences( this )

            this.AppliedFlag = true;
        end

        function analyzeAndApply( this )


            this.analyze(  );
            this.apply(  );
        end

        function revert( this )


            this.DAInterfaceDictionary.restoreCapturedVariableValues(  );
            this.DAInterfaceDictionary.removeCruft(  );
            this.DASourceContext.restoreCapturedVariableValues(  );
        end

        function save( this )


            if ~this.AppliedFlag
                DAStudio.warning( 'interface_dictionary:migrator:nothingToSave' );
                return ;
            end

            this.DAInterfaceDictionary.saveDataSources(  );
            this.DASourceContext.saveDataSources(  );
        end
    end

    methods ( Hidden )
        function closeDictionaries( this, namedargs )


            arguments
                this
                namedargs.RevertDictionary = false
            end


            for key = keys( this.ComponentsDictionaryMap )
                dictionaryName = this.ComponentsDictionaryMap( key{ 1 } );
                if ~isempty( Simulink.data.dictionary.getOpenDictionaryPaths( dictionaryName ) )
                    if namedargs.RevertDictionary
                        Simulink.data.dictionary.closeAll( dictionaryName, '-discard' )
                    else
                        Simulink.data.dictionary.closeAll( dictionaryName, '-save' )
                    end
                end
            end
            this.InterfaceDictionaryHandle.close( DiscardChanges = namedargs.RevertDictionary );
        end
    end

    methods ( Access = private )


        function addElementsToMigrate( this, varId, contextVariable )
            entry = this.DASourceContext.getVariable( varId );

            item.Name = varId.Name;
            item.Source = varId.getDataSourceFriendlyName;

            if isInterface( this, entry, item.Name, contextVariable )
                if ~any( cellfun( @( toMigrate )strcmp( toMigrate.Name, item.Name ), this.InterfacesToMigrate ) )
                    this.InterfacesToMigrate{ end  + 1 } = item;
                end
            else
                if ~any( cellfun( @( toMigrate )strcmp( toMigrate.Name, item.Name ), this.DataTypesToMigrate ) )
                    this.DataTypesToMigrate{ end  + 1 } = item;
                end
            end


            this.removeNonInterfaceDictionaryDuplicatedVariable( varId );
        end


        function handleInterfaceDictionaryDuplicates( this, varIds )


            varIds( 2 ) = this.DAInterfaceDictionary.identifyByName( varIds( 1 ).Name );
            firstElement = this.DASourceContext.getVariable( varIds( 1 ) );
            secondElement = this.DAInterfaceDictionary.getVariable( varIds( 2 ) );

            if ~isequal( firstElement, secondElement )

                this.trackConflict( varIds );
            else


            end


            this.removeNonInterfaceDictionaryDuplicatedVariable( varIds );
        end


        function migrate = handleDuplicates( this, varIds )
            hasConflicts = false;
            for ll = 1:length( varIds )
                for jj = ll:length( varIds )

                    firstElement = this.DASourceContext.getVariable( varIds( ll ) );
                    secondElement = this.DASourceContext.getVariable( varIds( jj ) );

                    if ~isequal( firstElement, secondElement )

                        this.trackConflict( varIds );
                        hasConflicts = true;
                    end
                end
            end



            migrate = ~hasConflicts && ~this.DAInterfaceDictionary.hasVariable( varIds( 1 ).Name );


            this.removeNonInterfaceDictionaryDuplicatedVariable( varIds );
        end


        function removeNonInterfaceDictionaryDuplicatedVariable( this, varId )
            if this.DeleteFromOriginalSource
                for i = 1:length( varId )
                    var = varId( i );
                    if ~strcmp( var.getDataSourceFriendlyName, this.InterfaceDictionaryName ) &&  ...
                            ~any( cellfun( @( toDelete )isequal( toDelete, var ), this.VariablesToDelete ) )
                        this.VariablesToDelete{ end  + 1 } = var;
                    end
                end
            end
        end


        function trackUnsupportedConflicts( this, items )
            sources = join( cellfun( @( item )item.Source, items, 'UniformOutput', false ), ', ' );




            if length( items ) - sum( cellfun( @( toTrack )strcmp( toTrack.Source, this.InterfaceDictionaryName ), items ) ) > 1
                unsupportedItem.Name = items{ 1 }.Name;
                unsupportedItem.Source = sources{ 1 };
                unsupportedItem.Reason = message( 'interface_dictionary:migrator:unsupportedInconsistencyMigrate' ).getString;

                if ~any( cellfun( @( unsupportedToTrack )isequal( unsupportedToTrack, unsupportedItem ), this.UnsupportedMigration ) )
                    this.UnsupportedMigration{ end  + 1 } = unsupportedItem;
                end
            end
        end


        function trackConflict( this, varIds )
            items = cell( size( varIds ) );
            for i = 1:length( varIds )
                item.Name = varIds( i ).Name;
                item.Source = varIds( i ).getDataSourceFriendlyName;
                items{ i } = item;
            end

            this.trackUnsupportedConflicts( items );

            if ( ~any( cellfun( @( toTrack )isequal( toTrack, items ), this.ConflictObjects ) ) )
                this.ConflictObjects{ end  + 1 } = items;
            end
        end


        function result = isAnalysisPerformed( this )
            result = isempty( this.ConflictObjects ) && isempty( this.DataTypesToMigrate ) &&  ...
                isempty( this.InterfacesToMigrate ) && isempty( this.UnusedObjects );
        end


        function loadContextModel( this )
            interfaceDicts = SLDictAPI.getTransitiveInterfaceDictsForModel( get_param( this.ContextName, 'handle' ) );



            if ( numel( interfaceDicts ) == 1 && ~isempty( this.InterfaceDictionaryName ) &&  ...
                    ~strcmp( this.InterfaceDictionaryName, this.dropPath( interfaceDicts{ 1 } ) ) )
                DAStudio.error( 'interface_dictionary:migrator:differentInterfaceDictionary', this.ContextName, interfaceDicts{ 1 } );
            end



            if numel( interfaceDicts ) > 1
                DAStudio.error( 'interface_dictionary:migrator:moreInterfaceDictionaries', this.ContextName );
            end


            dictionaries = SLDictAPI.getTransitiveDataDictsForModel( get_param( this.ContextName, 'handle' ) );
            for i = 1:numel( dictionaries )
                if Simulink.DDSDictionary.ModelRegistry.hasDDSPart( Simulink.dd.whichSldd( dictionaries{ i } ) )
                    DAStudio.error( 'interface_dictionary:migrator:unsupportedDDSDictionaries', this.ContextName, dictionaries{ 1 } );
                end
            end


            if isempty( this.InterfaceDictionaryName )

                this.InterfaceDictionaryName = get_param( this.ContextName, 'DataDictionary' );
            else

                this.LinkToDictionary = ~strcmp( this.InterfaceDictionaryName, get_param( this.ContextName, 'DataDictionary' ) );



                if ~exist( this.InterfaceDictionaryName, 'file' )
                    Simulink.interface.dictionary.create( this.InterfaceDictionaryName );
                end
            end


            if isempty( this.InterfaceDictionaryName ) || ~sl.interface.dict.api.isInterfaceDictionary( this.InterfaceDictionaryName )
                DAStudio.error( 'interface_dictionary:migrator:interfaceDictionaryUnavailable', this.ContextName );
            end

            this.InterfaceDictionaryHandle = Simulink.interface.dictionary.open( this.InterfaceDictionaryName );

        end


        function updateModelDictionaryReferences( this )
            if this.UpdateDictionaryReferences && ( ~isempty( this.DataTypesToMigrate ) || ~isempty( this.InterfacesToMigrate ) )















                for i = 1:size( this.ContextVariables )
                    for l = 1:size( this.ContextVariables( i ).Users, 1 )
                        destModel = bdroot( this.ContextVariables( i ).Users{ l } );
                        oldLinkedDictionary = get_param( destModel, 'DataDictionary' );



                        if ~isKey( this.ComponentsDictionaryMap, destModel )



                            if isempty( oldLinkedDictionary )
                                set_param( destModel, 'DataDictionary', this.InterfaceDictionaryName );
                            end
                            this.ComponentsDictionaryMap( destModel ) = oldLinkedDictionary;
                        end
                    end
                end

                isInterfaceDictionaryAlreadyLinked = false;



                migratedVariables = [ this.InterfacesToMigrate( : )', this.DataTypesToMigrate( : )' ];
                dictionariesToLink = {  };
                for i = 1:size( migratedVariables, 2 )



                    if strcmp( migratedVariables{ i }.Source, 'base workspace' )




                        if ~isInterfaceDictionaryAlreadyLinked
                            source = get_param( this.ContextName, 'DataDictionary' );
                            isAlreadyProcessed = isequal( this.InterfaceDictionaryName, source );
                        else
                            isAlreadyProcessed = true;
                        end


                    else
                        source = migratedVariables{ i }.Source;
                        isAlreadyProcessed = any( strcmp( dictionariesToLink, source ) );
                    end

                    if ~isAlreadyProcessed
                        ddObj = Simulink.data.dictionary.open( source );
                        if ~any( contains( ddObj.DataSources, this.InterfaceDictionaryName ) )
                            ddObj.addDataSource( this.InterfaceDictionaryName );
                            isInterfaceDictionaryAlreadyLinked = true;
                        end
                        dictionariesToLink{ end  + 1 } = source;%#ok
                    end
                end
            end
        end


        function [ varIdToRemove, varIdToAdd ] = getVariableToOverride( this, varToOverwrite )


            varIds = this.DASourceContext.identifyByName( varToOverwrite );

            if length( varIds ) ~= 2
                varIds( 2 ) = this.DAInterfaceDictionary.identifyByName( varIds( 1 ).Name );
            end

            if strcmp( varIds( 1 ).getDataSourceFriendlyName, this.InterfaceDictionaryName )
                varIdToRemove = varIds( 1 );
                varIdToAdd = varIds( 2 );
            else
                varIdToRemove = varIds( 2 );
                varIdToAdd = varIds( 1 );
            end
        end


        function result = isOverwriteSupported( this, item )
            result = ~any( cellfun( @( unsupportedToTrack )strcmp( unsupportedToTrack.Name, item ), this.UnsupportedMigration ) );
        end


        function overwriteDictionaryEntriesInConflict( this )
            variablesToCapture = '';

            for i = 1:size( this.ConflictObjects, 2 )
                items = this.ConflictObjects{ i };


                varToOverwrite = items{ 1 }.Name;

                if ~this.isOverwriteSupported( varToOverwrite )
                    continue ;
                end

                [ varIdToRemove, ~ ] = getVariableToOverride( this, varToOverwrite );
                variablesToCapture{ end  + 1 } = varIdToRemove;%#ok
            end


            if ~isempty( variablesToCapture )
                this.DAInterfaceDictionary.captureVariableValues( [ variablesToCapture{ : } ] );
            end

            for i = 1:size( this.ConflictObjects, 2 )
                items = this.ConflictObjects{ i };


                varToOverwrite = items{ 1 }.Name;

                if ~this.isOverwriteSupported( varToOverwrite )
                    continue ;
                end

                [ varIdToRemove, varIdToAdd ] = getVariableToOverride( this, varToOverwrite );

                entryToRemove = this.DAInterfaceDictionary.getVariable( varIdToRemove );
                entryAdd = this.DASourceContext.getVariable( varIdToAdd );
                indexes = arrayfun( @( x )strcmp( x.Name, varIdToRemove.Name ), this.ContextVariables );
                index = find( indexes, 1 );

                dictionaryInterfaces = this.InterfaceDictionaryHandle.getInterfaceNames(  );

                if isInterface( this, entryToRemove, varToOverwrite, this.ContextVariables( index ) ) && any( strcmp( dictionaryInterfaces, varToOverwrite ) )
                    this.InterfaceDictionaryHandle.removeInterface( varToOverwrite );
                    this.InterfaceDictionaryHandle.addDataInterface( varToOverwrite, 'SimulinkBus', entryAdd );
                else


                    entryAdd = this.adapt( entryAdd );

                    this.InterfaceDictionaryHandle.removeDataType( varToOverwrite );
                    this.InterfaceDictionaryHandle.addDataTypeUsingSLObj( varToOverwrite, entryAdd );
                end
            end
        end


        function initAnalyzeForModelContext( this )






            this.ContextVariables = Simulink.findVars( this.ContextName, 'SearchReferencedModels', 'on', 'IncludeEnumTypes', 'on' );



            if this.LinkToDictionary
                oldLinkedDictionary = get_param( this.ContextName, 'DataDictionary' );
                if Simulink.internal.isArchitectureModel( this.ContextName ) || isempty( oldLinkedDictionary )
                    this.DAInterfaceDictionary.addDataSourceToDest( this.ContextName );
                end
            end

            this.DASourceContext = Simulink.data.DataAccessor.createForGlobalNameSpaceClosure( this.ContextName );
            visibleVariables = this.DASourceContext.identifyVisibleVariables(  );


            for i = 1:size( visibleVariables )
                varId = visibleVariables( i );
                variable = this.DASourceContext.getVariable( varId );



                if ~this.doesMigratorHandleClass( variable )
                    continue ;
                end

                isUsed = any( arrayfun( @( x )strcmp( varId.Name, x.Name ), this.ContextVariables ) );

                if ~isUsed && ~any( cellfun( @( x )strcmp( varId.Name, x.Name ), this.UnusedObjects ) )
                    item.Name = varId.Name;
                    item.Source = varId.getDataSourceFriendlyName;

                    this.UnusedObjects{ end  + 1 } = item;
                end
            end
        end


        function result = doesMigratorHandleClass( ~, variable )
            result = false;


            if isa( variable, 'Simulink.NumericType' ) ||  ...
                    Simulink.dd.doesInterfaceDictionaryAcceptClass( class( variable ) )
                result = true;
            end
        end


        function adaptedType = adapt( ~, typeToAdapt )


            if isa( typeToAdapt, 'Simulink.NumericType' )

                signed = false;
                if strcmp( typeToAdapt.Signedness, 'Signed' )
                    signed = true;
                end

                switch ( typeToAdapt.DataTypeMode )
                    case 'Double'
                        baseType = 'double';
                    case 'Single'
                        baseType = 'single';
                    case 'Half'
                        baseType = 'half';
                    case 'Fixed-point: binary point scaling'
                        baseType = sprintf( 'fixdt(%d,%d,%d)', signed, typeToAdapt.WordLength, typeToAdapt.FractionLength );
                    case 'Fixed-point: unspecified scaling'
                        baseType = sprintf( 'fixdt(%d,%d)', signed, typeToAdapt.WordLength );
                    case 'Fixed-point: slope and bias scaling'
                        baseType = sprintf( 'fixdt(%d,%d,%d,%d)', signed, typeToAdapt.WordLength, typeToAdapt.Slope, typeToAdapt.Bias );
                end

                adaptedType = Simulink.AliasType;
                adaptedType.BaseType = baseType;
                adaptedType.Description = typeToAdapt.Description;
                adaptedType.DataScope = typeToAdapt.DataScope;
                adaptedType.HeaderFile = typeToAdapt.HeaderFile;
            else
                adaptedType = typeToAdapt;
            end

        end



        function isInterface = isInterface( this, entry, entryName, variable )
            if isfield( variable, 'IsInterface' )
                isInterface = variable.IsInterface;
                return ;
            end

            if isempty( variable.Users )
                isInterface = false;
                return ;
            end

            isInterface = false;

            for i = 1:length( variable.Users )
                block = variable.Users{ i };
                blockHandle = get_param( block, 'Handle' );

                isBusElementPort = this.isBusElementPortBlock( blockHandle );

                if isa( entry, 'Simulink.Bus' ) && isBusElementPort


                    pb = Simulink.BlockDiagram.Internal.getInterfaceModelBlock( blockHandle );
                    treeRoot = pb.port.tree;
                    rootType = Simulink.internal.CompositePorts.TreeNode.getDataType( treeRoot );
                    isInterface = strcmp( rootType, sprintf( "Bus: %s", entryName ) );
                end



                if isInterface
                    return ;
                end
            end
        end


        function result = isBusElementPortBlock( ~, blockHandle )
            result = strcmp( get_param( blockHandle, 'Type' ), 'block' ) &&  ...
                any( strcmp( get_param( blockHandle, 'BlockType' ), { 'Inport', 'Outport' } ) ) &&  ...
                strcmp( get_param( blockHandle, 'IsBusElementPort' ), 'on' );
        end


        function fileName = dropPath( ~, filePath )
            [ ~, n, e ] = fileparts( filePath );
            fileName = [ n, e ];
        end


        function result = isLibrarySLDDSource( ~, users, sourceName )
            result = false;



            if ~strcmp( sourceName, 'base workspace' )

                parentBlock = get_param( users{ 1 }, 'Parent' );

                if ~isempty( parentBlock )

                    libraryInfoData = libinfo( parentBlock );

                    for i = 1:size( libraryInfoData, 1 )
                        libraryBlockInfo = libraryInfoData( i );
                        if ~isempty( libraryBlockInfo ) && ~isempty( libraryBlockInfo.Library )


                            if ~bdIsLoaded( libraryBlockInfo.Library )
                                load_system( libraryBlockInfo.Library );
                                cleanupObj = onCleanup( @(  )close_system( libraryBlockInfo.Library ) );
                            end

                            librarySLDD = get_param( libraryBlockInfo.Library, 'DataDictionary' );

                            if ~isempty( librarySLDD ) && strcmp( sourceName, librarySLDD )
                                result = true;
                                break ;
                            end
                        end
                    end
                end
            end
        end

    end
end


