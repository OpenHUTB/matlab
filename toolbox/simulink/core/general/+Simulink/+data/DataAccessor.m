classdef DataAccessor < handle





    properties ( SetAccess = protected, GetAccess = protected )
        Context

        ModelWorkspaceDataSource

        DictionaryDataSources



        SubDictionaryToTopDictionaryMap

        DictionaryNameToDataSourceMap
        DataSourceBroker
        BaseWorkspaceDataSource


        AdapterReadDataSources

        ContextScope

        BWSBackingFile

    end

    properties ( Hidden, Access = private )
        numericTypes = { 'int8',  ...
            'int16',  ...
            'int32',  ...
            'int64',  ...
            'uint8',  ...
            'uint16',  ...
            'uint32',  ...
            'uint64',  ...
            'single',  ...
            'double',  ...
            'embedded.fi' }
        isNewCreationLocal = false;
    end


    methods ( Access = public )




        function varIDs = identifyVisibleVariables( obj )


            obj.refreshDataSources;
            varIDs = Simulink.data.VariableIdentifier.empty( 0, 0 );


            if ~isempty( obj.DictionaryDataSources )
                newVarIDs = obj.getVisibleVariablesFromSLDD(  );
                varIDs = [ varIDs;newVarIDs ];
            end


            if ~isempty( obj.DataSourceBroker )
                newVarIDs = obj.DataSourceBroker.identifyVisibleVariables;
                varIDs = [ varIDs;newVarIDs ];
            end


            if ~isempty( obj.BaseWorkspaceDataSource )
                newVarIDs = obj.BaseWorkspaceDataSource.identifyVisibleVariables;
                varIDs = [ varIDs;newVarIDs ];
            end


            if ~isempty( obj.ModelWorkspaceDataSource )
                mwsVarIDs = obj.ModelWorkspaceDataSource.identifyVisibleVariables;
                varIDs = obj.removeShadowVars( mwsVarIDs, varIDs );
            end

            if ~isempty( obj.AdapterReadDataSources )
                newVarIDs = obj.AdapterReadDataSources.identifyVisibleVariables;
                varIDs = [ varIDs;newVarIDs ];
            end
        end


        function varIDs = identifyVisibleVariablesByClass( obj, classType )


            classType = convertStringsToChars( classType );
            obj.refreshDataSources;
            varIDs = Simulink.data.VariableIdentifier.empty( 0, 0 );


            if ~isempty( obj.DictionaryDataSources )
                ddEntries = Simulink.dd.getEntryInfoFromDictionaries( obj.DictionaryNameToDataSourceMap.keys, 'Design Data', 'Class', { classType } );
                if ~isempty( ddEntries )
                    newVarIDs = obj.createVarIdsFromDictEntries( ddEntries );
                    varIDs = [ varIDs;newVarIDs ];
                end
            end


            if ~isempty( obj.DataSourceBroker )
                newVarIDs = obj.DataSourceBroker.identifyVisibleVariablesByClass( classType );
                varIDs = [ varIDs;newVarIDs ];
            end


            if ~isempty( obj.BaseWorkspaceDataSource )
                newVarIDs = obj.BaseWorkspaceDataSource.identifyVisibleVariablesByClass( classType );
                varIDs = [ varIDs;newVarIDs ];
            end


            if ~isempty( obj.ModelWorkspaceDataSource )
                mwsVarIDs = obj.ModelWorkspaceDataSource.identifyVisibleVariablesByClass( classType );
                varIDs = obj.removeShadowVars( mwsVarIDs, varIDs );
            end
        end

        function varIDs = identifyVisibleVariablesDerivedFromClass( obj, baseClassType )


            baseClassType = convertStringsToChars( baseClassType );
            obj.refreshDataSources;
            varIDs = Simulink.data.VariableIdentifier.empty( 0, 0 );


            if ~isempty( obj.DictionaryDataSources )


                for idx = 1:size( obj.DictionaryDataSources, 1 )
                    newVarIDs = obj.DictionaryDataSources{ idx }.identifyVisibleVariablesDerivedFromClass( baseClassType );
                    varIDs = [ varIDs;newVarIDs ];
                end
            end


            if ~isempty( obj.DataSourceBroker )
                newVarIDs = obj.DataSourceBroker.identifyVisibleVariablesDerivedFromClass( baseClassType );
                varIDs = [ varIDs;newVarIDs ];
            end


            if ~isempty( obj.BaseWorkspaceDataSource )
                newVarIDs = obj.BaseWorkspaceDataSource.identifyVisibleVariablesDerivedFromClass( baseClassType );
                varIDs = [ varIDs;newVarIDs ];
            end

            if ~isempty( obj.ModelWorkspaceDataSource )
                mwsVarIDs = obj.ModelWorkspaceDataSource.identifyVisibleVariablesDerivedFromClass( baseClassType );
                varIDs = obj.removeShadowVars( mwsVarIDs, varIDs );
            end
        end

        function varIDs = identifyVisibleVariablesOfNumericType( obj )


            obj.refreshDataSources;
            varIDs = Simulink.data.VariableIdentifier.empty( 0, 0 );


            if ~isempty( obj.DictionaryDataSources )
                ddEntries = Simulink.dd.getEntryInfoFromDictionaries( obj.DictionaryNameToDataSourceMap.keys, 'Design Data', 'Class', obj.numericTypes );
                if ~isempty( ddEntries )
                    newVarIDs = obj.createVarIdsFromDictEntries( ddEntries );
                    varIDs = [ varIDs;newVarIDs ];
                end
            end


            if ~isempty( obj.DataSourceBroker )
                newVarIDs = obj.DataSourceBroker.identifyVisibleVariablesOfNumericType( obj.numericTypes );
                varIDs = [ varIDs;newVarIDs ];
            end


            if ~isempty( obj.BaseWorkspaceDataSource )
                newVarIDs = obj.BaseWorkspaceDataSource.identifyVisibleVariablesOfNumericType( obj.numericTypes );
                varIDs = [ varIDs;newVarIDs ];
            end


            if ~isempty( obj.ModelWorkspaceDataSource )
                mwsVarIDs = obj.ModelWorkspaceDataSource.identifyVisibleVariablesOfNumericType( obj.numericTypes );
                varIDs = obj.removeShadowVars( mwsVarIDs, varIDs );
            end
        end




        function varIDs = identifyByName( obj, varName )
            varName = convertStringsToChars( varName );
            varIDs = Simulink.data.VariableIdentifier.empty( 0, 0 );


            if ~isempty( obj.ModelWorkspaceDataSource )
                mwsVarId = obj.ModelWorkspaceDataSource.identifyByName( varName );
                if ~isempty( mwsVarId )
                    varIDs = mwsVarId;
                    return ;
                end
            end


            if ~isempty( obj.DictionaryDataSources )
                ddEntries = Simulink.dd.getEntryInfoFromDictionaries( obj.DictionaryNameToDataSourceMap.keys, 'Design Data', 'Name', { varName } );
                if ~isempty( ddEntries )
                    newVarIDs = obj.createVarIdsFromDictEntries( ddEntries );
                    varIDs = [ varIDs;newVarIDs ];
                end
            end


            if ~isempty( obj.DataSourceBroker )
                newVarIDs = obj.DataSourceBroker.identifyByName( varName );
                varIDs = [ varIDs;newVarIDs ];
            end


            if ~isempty( obj.BaseWorkspaceDataSource )
                newVarId = obj.BaseWorkspaceDataSource.identifyByName( varName );
                varIDs = [ varIDs;newVarId ];
            end

        end


        function isUnique = isName2IDUnique( obj, varName )
            varName = convertStringsToChars( varName );

            isUnique = false;
            varIDs = obj.identifyByName( varName );
            if size( varIDs ) == 1
                isUnique = true;
            end
        end


        function varID = name2UniqueID( obj, varName )
            varName = convertStringsToChars( varName );

            varIDs = obj.identifyByName( varName );
            if size( varIDs, 1 ) > 1 || isempty( varIDs )

                DAStudio.error( 'Simulink:Data:NameToUniqueIDFail', varName );
            end
            varID = varIDs;
        end



        function isVisible = isVariableVisible( obj, varId )
            isVisible = false;



            obj.refreshDataSources;





            dataSource = obj.findGatewayDataSourceFromId( varId.DataSourceId );
            if ~isempty( dataSource )
                isVisible = dataSource.isVariableVisible( varId );
            end
        end


        function value = getVariable( obj, varId )
            value = [  ];
            dataSource = obj.findGatewayDataSourceFromId( varId.DataSourceId );
            if ~isempty( dataSource )
                value = dataSource.getVariable( varId );
            end
        end


        function infoStructs = getShadowedVariables( obj )

            infoStructs = struct( 'Name', '',  ...
                'PrecedentSource', '',  ...
                'ShadowedSources', {  } );


            mwsDA = Simulink.data.DataAccessor.createForLocalData( obj.Context );
            mwsVarIDs = mwsDA.identifyVisibleVariables;


            externalDA = Simulink.data.DataAccessor.createForExternalData( obj.Context );
            for i = 1:length( mwsVarIDs )
                varName = mwsVarIDs( i ).Name;
                externalVarIDs = externalDA.identifyByName( varName );
                if ~isempty( externalVarIDs )

                    shadowedSources = unique( arrayfun( @( x )x.getDataSourceFriendlyName, externalVarIDs, 'UniformOutput', false )' );
                    s = struct( 'Name', mwsVarIDs( i ).Name,  ...
                        'PrecedentSource', mwsVarIDs( i ).getDataSourceFriendlyName,  ...
                        'ShadowedSources', { shadowedSources } );
                    infoStructs( end  + 1 ) = s;%#ok<*AGROW>
                end
            end
        end


        function infoStructs = getDuplicateVariablesInExternalSources( obj )
            infoStructs = struct( 'Name', '',  ...
                'DuplicateSources', {  } );


            if isempty( obj.Context )


                return ;
            elseif strcmp( obj.ContextScope, 'External' ) || strcmp( obj.ContextScope, 'Dictionary' )
                externalDA = obj;
            else
                externalDA = Simulink.data.DataAccessor.createForExternalData( obj.Context );
            end
            externalVarIDs = externalDA.identifyVisibleVariables(  );


            externalVarIDsMap = containers.Map;
            for i = 1:length( externalVarIDs )
                varName = externalVarIDs( i ).Name;
                oldVal = {  };
                if externalVarIDsMap.isKey( varName )
                    oldVal = externalVarIDsMap( varName );
                end
                externalVarIDsMap( varName ) = [ oldVal, externalVarIDs( i ).getDataSourceFriendlyName ];
            end



            for k = keys( externalVarIDsMap )
                externalVarDataSourceIDs = unique( externalVarIDsMap( k{ 1 } ) );
                if length( externalVarDataSourceIDs ) > 1
                    infoStructs( end  + 1 ) = struct( 'Name', k,  ...
                        'DuplicateSources', { externalVarDataSourceIDs } );
                end
            end
        end






        function varId = createVariableInDefaultSource( obj, variableName, value )




            if obj.isNewCreationLocal
                [ varId, ~ ] = obj.createVariableAsLocalData( variableName, value );
            else
                [ varId, ~ ] = obj.createVariableAsExternalData( variableName, value );
            end
        end


        function [ varId, isCreatedInPersistentSource ] = createVariableAsExternalData( obj, variableName, value )
            assert( strcmp( obj.ContextScope, 'Model' ) ...
                || strcmp( obj.ContextScope, 'External' ) ...
                || strcmp( obj.ContextScope, 'GlobalNameSpaceClosure' ),  ...
                'Only model context not with local scope is supported for createVariableAsExternalData.' )

            variableName = convertStringsToChars( variableName );
            ddName = get_param( obj.Context, 'DataDictionary' );
            if ~isempty( obj.DictionaryDataSources ) && ~strcmp( ddName, '' ) &&  ...
                    Simulink.dd.isClassAcceptableInDesignData( class( value ) )
                dataSourceId = ddName;
            elseif ~isempty( obj.DataSourceBroker )


                [ varId, isCreatedInPersistentSource ] = obj.DataSourceBroker.createVariable( variableName, value );
                return ;
            else
                dataSourceId = 'base workspace';
            end
            if endsWith( dataSourceId, '.sldd' ) &&  ...
                    any( contains( obj.SubDictionaryToTopDictionaryMap.keys, dataSourceId ) ) &&  ...
                    ~isequal( dataSourceId, obj.SubDictionaryToTopDictionaryMap( dataSourceId ) )
                source = Simulink.data.internal.DataDictionary( dataSourceId );
            else
                source = obj.findGatewayDataSourceFromId( dataSourceId );
            end
            if ~isempty( source )
                [ varId, isCreatedInPersistentSource ] = source.createVariable( variableName, value );
            else
                DAStudio.error( 'Simulink:Data:InvalidExternalDataSource', variableName );
            end
        end


        function success = updateVariable( obj, varId, value )
            success = false;
            dataSource = obj.findGatewayDataSourceFromId( varId.DataSourceId );
            if ~isempty( dataSource )
                success = dataSource.updateVariable( varId, value );
            end
        end


        function success = deleteVariable( obj, varId )
            success = false;
            dataSource = obj.findGatewayDataSourceFromId( varId.DataSourceId );
            if ~isempty( dataSource )
                success = dataSource.deleteVariable( varId );
            end
        end


        function [ varId, isCreatedInPersistentSource ] = createVariableAsLocalData( obj, variableName, value )
            variableName = convertStringsToChars( variableName );
            if isempty( obj.Context )
                dataSourceId = 'base workspace';
            else
                [ ~, fileName, ext ] = fileparts( obj.Context );
                dataSourceId = [ fileName, ext ];
            end

            source = obj.findGatewayDataSourceFromId( dataSourceId );
            if ~isempty( source )
                [ varId, isCreatedInPersistentSource ] = source.createVariable( variableName, value );
            else
                assert( false, 'Cannot find a valid local data source' );
            end
        end








        function saveState = saveDataSourceOfVariables( obj, varIds )


            assert( numel( varIds ), 'The varIds should not be empty' )

            saveState = false( 1, numel( varIds ) );
            for i = 1:numel( varIds )
                varId = varIds( i );
                varSource = varIds.getDataSourceFriendlyName;
                if endsWith( varSource, '.sldd' ) &&  ...
                        any( contains( obj.SubDictionaryToTopDictionaryMap.keys, varSource ) ) &&  ...
                        ~isequal( varSource, obj.SubDictionaryToTopDictionaryMap( varSource ) )
                    dataSource = Simulink.data.internal.DataDictionary( varSource );
                else
                    dataSource = obj.findGatewayDataSourceFromId( varId.DataSourceId );
                end
                if ~isempty( dataSource ) && dataSource.IsPersistent
                    saveState( i ) = dataSource.save;
                end
            end
        end


        function setBWSBackingFile( obj, filename )
            filename = convertStringsToChars( filename );
            obj.BWSBackingFile = filename;

            obj.refreshDataSources;


            if ~isempty( obj.BaseWorkspaceDataSource ) && isempty( which( obj.BWSBackingFile ) )
                obj.BaseWorkspaceDataSource.save;
            end
        end

        function success = saveDataSources( obj )


            obj.refreshDataSources;

            success = true;

            for idx = 1:size( obj.DictionaryDataSources, 1 )
                success = obj.DictionaryDataSources{ idx }.save && success;
            end


            if ~isempty( obj.DataSourceBroker )
                success = obj.DataSourceBroker.save && success;
            end


            if ~isempty( obj.BaseWorkspaceDataSource )
                success = obj.BaseWorkspaceDataSource.save && success;
            end


            if ~isempty( obj.ModelWorkspaceDataSource )
                success = obj.ModelWorkspaceDataSource.save && success;
            end
        end

        function success = revertDataSources( obj )


            obj.refreshDataSources;

            success = true;

            for idx = 1:size( obj.DictionaryDataSources, 1 )
                success = obj.DictionaryDataSources{ idx }.revert && success;
            end


            if ~isempty( obj.DataSourceBroker )
                success = obj.DataSourceBroker.revert && success;
            end


            if ~isempty( obj.BaseWorkspaceDataSource )
                success = obj.BaseWorkspaceDataSource.revert && success;
            end


            if ~isempty( obj.ModelWorkspaceDataSource )
                success = obj.ModelWorkspaceDataSource.revert && success;
            end
        end


        function addDataSourceToDest( obj, destModel )



            destModel = convertStringsToChars( destModel );
            obj.refreshDataSources;
            if strcmp( obj.ContextScope, 'Model' ) || strcmp( obj.ContextScope, 'External' )
                Simulink.data.DataSourceUtils.copyExternalDataSourceReferences( obj.Context, destModel, false );
            elseif strcmp( obj.ContextScope, 'Dictionary' )
                set_param( destModel, 'DataDictionary', obj.Context );
            elseif strcmp( obj.ContextScope, 'GlobalNameSpaceClosure' )
                globalNameSpaceDictionaries = obj.DictionaryNameToDataSourceMap.keys(  );
                Simulink.data.DataSourceUtils.appendDictionarySources( globalNameSpaceDictionaries, destModel );
            else


                assert( isempty( obj.ContextScope ), 'This specified context is not support for addDataSourceToDest' );
            end
        end


        function showVariableInUI( obj, variableId )
            assert( ~isempty( variableId ), 'Trying to open UI for a variable that does not exist' );

            objOfVariable = obj.getVariable( variableId );
            if isa( objOfVariable, 'Simulink.Bus' )
                obj.openBusEditor( variableId );
            else
                dataSource = obj.findGatewayDataSourceFromId( variableId.DataSourceId );
                dataSource.showVariableInUI( variableId );
            end
        end

        function showVariableInModelExplorer( obj, variableId )
            assert( ~isempty( variableId ), 'Trying to open Model Explorer for a variable that does not exist' );

            dataSource = obj.findGatewayDataSourceFromId( variableId.DataSourceId );
            if ~isempty( dataSource )
                dataSource.showVariableInModelExplorer( variableId );
            end
        end


        function parentDataSource = getConnectedSource( obj, variableId )
            assert( ~isempty( variableId ) );
            assert( contains( variableId.DataSourceId, '.sldd' ),  ...
                'Source of variable ID is not a data dictionary.' );


            parentDataSource = obj.SubDictionaryToTopDictionaryMap( variableId.DataSourceId );
        end


        function [ writableList, readonlyList ] = identifyPersistentStorageGateway( obj, varIds )




            writableList = {  };
            readonlyList = {  };
            visitedSourceMap = containers.Map;
            for i = 1:numel( varIds )
                varId = varIds( i );
                dataSource = obj.findGatewayDataSourceFromId( varId.DataSourceId );
                if ~isempty( dataSource ) && dataSource.IsPersistent
                    if contains( varId.DataSourceId, '.sldd' )
                        parentDataSource = obj.SubDictionaryToTopDictionaryMap( varId.DataSourceId );
                    else
                        parentDataSource = varId.DataSourceId;
                    end
                    if ~isKey( visitedSourceMap, parentDataSource )
                        [ isWritable, isReadonly ] = obj.getFileAccessAttributes( parentDataSource );
                        if isWritable
                            writableList = [ writableList, { parentDataSource } ];
                        elseif isReadonly
                            readonlyList = [ readonlyList, { parentDataSource } ];
                        end
                        dummyValue = true;
                        visitedSourceMap( parentDataSource ) = dummyValue;
                    end
                end
            end
        end


        function [ nonPersistent, persistentWritable, persistentReadonly ] = classifyForPersistency( obj, varIds )

            nonPersistent = Simulink.data.VariableIdentifier.empty( 0, 0 );
            persistentWritable = Simulink.data.VariableIdentifier.empty( 0, 0 );
            persistentReadonly = Simulink.data.VariableIdentifier.empty( 0, 0 );
            visitedSourceMap = containers.Map;
            for i = 1:numel( varIds )
                varId = varIds( i );
                dataSource = obj.findGatewayDataSourceFromId( varId.DataSourceId );
                if ~isempty( dataSource )
                    if dataSource.IsPersistent
                        sourceName = varId.DataSourceId;
                        if ~isKey( visitedSourceMap, sourceName )
                            [ isWritable, isReadonly ] = obj.getFileAccessAttributes( sourceName );
                            fileAttributes.isWritable = isWritable;
                            fileAttributes.isReadonly = isReadonly;
                            visitedSourceMap( sourceName ) = fileAttributes;
                        else
                            isWritable = visitedSourceMap( sourceName ).isWritable;
                            isReadonly = visitedSourceMap( sourceName ).isReadonly;
                        end
                        if isWritable
                            persistentWritable = [ persistentWritable;varId ];
                        elseif isReadonly
                            persistentReadonly = [ persistentReadonly;varId ];
                        end
                    else
                        nonPersistent = [ nonPersistent;varId ];
                    end
                end
            end
        end


        function captureVariableValues( obj, varIds )

            obj.refreshDataSources;


            resetFlag = true;
            for idx = 1:size( obj.DictionaryDataSources, 1 )
                obj.DictionaryDataSources{ idx }.captureVariableValues( varIds, resetFlag );
                resetFlag = false;
            end


            if ~isempty( obj.DataSourceBroker )
                obj.DataSourceBroker.captureVariableValues( varIds );
            end


            if ~isempty( obj.BaseWorkspaceDataSource )
                obj.BaseWorkspaceDataSource.captureVariableValues( varIds );
            end


            if ~isempty( obj.ModelWorkspaceDataSource )
                obj.ModelWorkspaceDataSource.captureVariableValues( varIds );
            end
        end


        function captureVisibleVariableNames( obj )

            obj.refreshDataSources;


            if ~isempty( obj.DictionaryDataSources )
                varIDs = obj.getVisibleVariablesFromSLDD(  );
                obj.DictionaryDataSources{ 1 }.captureVisibleVariableNames( varIDs );
            end


            if ~isempty( obj.DataSourceBroker )
                obj.DataSourceBroker.captureVisibleVariableNames;
            end


            if ~isempty( obj.BaseWorkspaceDataSource )
                obj.BaseWorkspaceDataSource.captureVisibleVariableNames;
            end


            if ~isempty( obj.ModelWorkspaceDataSource )
                obj.ModelWorkspaceDataSource.captureVisibleVariableNames;
            end
        end


        function [ varId, secondaryVarId ] = name2UniqueIdWithCheck( obj, varName )












            varName = convertStringsToChars( varName );
            secondaryVarId = Simulink.data.VariableIdentifier.empty( 0, 0 );
            duplicateVarIds = obj.identifyByName( varName );
            if numel( duplicateVarIds ) == 1
                varId = duplicateVarIds;
            elseif numel( duplicateVarIds ) > 1

                dataSourceList = {  };
                for i = 1:numel( duplicateVarIds )
                    dataSourceList{ end  + 1 } = duplicateVarIds( i ).getDataSourceFriendlyName;
                end
                if ismember( 'base workspace', dataSourceList )
                    if numel( dataSourceList ) == 2

                        varValue1 = obj.getVariable( duplicateVarIds( 1 ) );
                        varValue2 = obj.getVariable( duplicateVarIds( 2 ) );
                        if isequal( varValue1, varValue2 )
                            idxBWS = find( contains( dataSourceList, 'base workspace' ) );


                            idxES = numel( dataSourceList ) + 1 - idxBWS;

                            MSLDiagnostic( 'SLDD:sldd:ConsistentDuplicatesInDataDictAndBWS',  ...
                                varName, dataSourceList{ idxES }, 'Base workspace' ).reportAsWarning;


                            varId = duplicateVarIds( idxES );
                            secondaryVarId = duplicateVarIds( idxBWS );
                        else
                            dataSourceList = unique( dataSourceList );
                            obj.throwOutDuplicateSymbolError( dataSourceList, varName );
                        end
                    else
                        dataSourceList = unique( dataSourceList );
                        obj.throwOutDuplicateSymbolError( dataSourceList, varName );
                    end
                else
                    if numel( dataSourceList ) >= 2
                        dataSourceList = unique( dataSourceList );
                        obj.throwOutDuplicateSymbolError( dataSourceList, varName );
                    end
                end
            else
                varId = Simulink.data.VariableIdentifier.empty( 0, 0 );
            end
        end

        function restoreCapturedVariableValues( obj )









            for idx = 1:size( obj.DictionaryDataSources, 1 )
                obj.DictionaryDataSources{ idx }.restoreCapturedVariableValues;
            end


            if ~isempty( obj.DataSourceBroker )
                obj.DataSourceBroker.restoreCapturedVariableValues;
            end


            if ~isempty( obj.BaseWorkspaceDataSource )
                obj.BaseWorkspaceDataSource.restoreCapturedVariableValues;
            end


            if ~isempty( obj.ModelWorkspaceDataSource )
                obj.ModelWorkspaceDataSource.restoreCapturedVariableValues;
            end
        end


        function removeCruft( obj )








            if ~isempty( obj.DictionaryDataSources )
                varIDs = obj.getVisibleVariablesFromSLDD(  );
                for idx = 1:size( obj.DictionaryDataSources, 1 )
                    obj.DictionaryDataSources{ idx }.removeCruft( varIDs );
                end
            end


            if ~isempty( obj.DataSourceBroker )
                obj.DataSourceBroker.removeCruft;
            end


            if ~isempty( obj.BaseWorkspaceDataSource )
                obj.BaseWorkspaceDataSource.removeCruft;
            end


            if ~isempty( obj.ModelWorkspaceDataSource )
                obj.ModelWorkspaceDataSource.removeCruft;
            end
        end


        function varExist = hasVariable( obj, varName )





            varName = convertStringsToChars( varName );
            varExist = false;


            if ~isempty( obj.BaseWorkspaceDataSource )
                varExist = obj.BaseWorkspaceDataSource.hasVariable( varName );
                if varExist
                    return ;
                end
            end


            if ~isempty( obj.DictionaryDataSources )
                for idx = 1:numel( obj.DictionaryDataSources )
                    varExist = obj.DictionaryDataSources{ idx }.hasVariable( varName );
                    if varExist
                        return ;
                    end
                end
            end


            if ~isempty( obj.DataSourceBroker )
                varExist = obj.DataSourceBroker.hasVariable( varName );
                if varExist
                    return ;
                end
            end


            if ~isempty( obj.ModelWorkspaceDataSource )
                varExist = obj.ModelWorkspaceDataSource.hasVariable( varName );
                if varExist
                    return ;
                end
            end
        end





    end

    methods ( Access = public, Static )






        function obj = create( context )
            context = convertStringsToChars( context );
            obj = Simulink.data.DataAccessor;
            obj.Context = context;
            obj.ContextScope = 'Model';
            obj.refreshDataSources;
        end



        function obj = createForLocalData( context )
            context = convertStringsToChars( context );
            obj = Simulink.data.DataAccessor;
            obj.Context = context;
            obj.ContextScope = 'Local';
            obj.refreshDataSources;
            obj.isNewCreationLocal = true;
        end



        function obj = createForExternalData( context )
            context = convertStringsToChars( context );
            obj = Simulink.data.DataAccessor;
            obj.Context = context;
            obj.ContextScope = 'External';
            obj.refreshDataSources;
        end



        function obj = createForGlobalNameSpaceClosure( context )
            context = convertStringsToChars( context );
            obj = Simulink.data.DataAccessor;
            obj.Context = context;
            obj.ContextScope = 'GlobalNameSpaceClosure';
            obj.refreshDataSources;
        end



        function obj = createWithNoContext
            obj = Simulink.data.DataAccessor;
            obj.Context = [  ];
            obj.BaseWorkspaceDataSource = Simulink.data.internal.BaseWorkspace;
            obj.isNewCreationLocal = true;
        end


        function obj = createForOutputData( dataSource, options )
            arguments
                dataSource{ mustBeTextScalar }
                options.Section{ mustBeText, mustBeVector }
            end

            source = convertStringsToChars( dataSource );
            [ ~, ~, ext ] = fileparts( source );
            if strcmp( ext, '.sldd' )

                if isfield( options, 'Section' )
                    section = string( options.Section );
                    if ~strcmpi( "Design Data", section )
                        throwAsCaller( MException( message( 'SLDD:sldd:InvalidSectionNameForSLDDFile', options.Section, dataSource ) ) );
                    end
                end
                obj = Simulink.data.DataAccessor;
                obj.Context = source;
                obj.ContextScope = 'Dictionary';
                obj.refreshDataSources;
                obj.isNewCreationLocal = true;
            else
                obj = Simulink.data.DataAccessor;
                obj.Context = source;
                obj.ContextScope = 'OutputData';
                obj.isNewCreationLocal = true;

                namedArgsCell = namedargs2cell( options );
                try
                    obj.AdapterReadDataSources = Simulink.data.internal.AdapterReadDataSource( obj.Context, namedArgsCell{ : } );
                catch ME
                    throwAsCaller( ME );
                end
            end

        end
    end

    methods ( Access = private )


        function effectiveAccessToBWS = updateDictionaryInfo( obj, ddName )
            assert( ~isempty( ddName ), ' Dictionary Name cannot be empty' );
            ddConn = Simulink.dd.open( ddName );
            ddClosureList = ddConn.DependencyClosure;


            ddClosureList = cellfun( @( x )Simulink.data.DataAccessor.filenameFromFullPath( x ),  ...
                ddClosureList, 'UniformOutput', false );

            for ddInClosure = ddClosureList'
                obj.SubDictionaryToTopDictionaryMap( ddInClosure{ 1 } ) = ddName;
            end

            effectiveAccessToBWS = ddConn.HasAccessToBaseWorkspace;
            ddConn.close;
        end

        function refreshDataSources( obj )
            if ~isempty( obj.Context )
                systemName = obj.Context;
                if ishandle( obj.Context )
                    systemName = get_param( obj.Context, 'Name' );
                end

                if ~strcmp( obj.ContextScope, 'Dictionary' ) &&  ...
                        ~strcmp( obj.ContextScope, 'OutputData' ) && ~bdIsLoaded( systemName )
                    load_system( obj.Context );
                end
                obj.DictionaryDataSources = {  };
                obj.DataSourceBroker = {  };
                obj.BaseWorkspaceDataSource = {  };
                obj.ModelWorkspaceDataSource = {  };
                obj.SubDictionaryToTopDictionaryMap = containers.Map;
                obj.DictionaryNameToDataSourceMap = containers.Map;
                switch obj.ContextScope
                    case 'GlobalNameSpaceClosure'
                        obj.findGlobalDataNameSpaceClosureSources;
                    case 'External'
                        obj.findExternalDataSources( obj.Context );
                    case 'Local'
                        obj.findLocalDataSources;
                    case 'Model'
                        obj.findLocalDataSources;
                        obj.findExternalDataSources( obj.Context );
                    case 'Dictionary'
                        obj.findDictionarySources;
                end
                if ~isempty( obj.BaseWorkspaceDataSource ) && ~isempty( obj.BWSBackingFile )
                    obj.BaseWorkspaceDataSource.setBWSBackingFile( obj.BWSBackingFile );
                end
            end
        end


        function findExternalDataSources( obj, model )

            effectiveAccessToBWS = false;

            if strcmp( get_param( model, 'HasAccessToBaseWorkspace' ), 'on' )
                effectiveAccessToBWS = true;
            end


            ddSources = slprivate( 'getAllDataDictionaries', model );

            for i = 1:length( ddSources )
                ddName = ddSources{ i };
                if ~isempty( ddName )
                    curDDHasBWSAccess = obj.updateDictionaryInfo( ddName );
                    effectiveAccessToBWS = effectiveAccessToBWS || curDDHasBWSAccess;
                end
            end


            topDDList = unique( obj.SubDictionaryToTopDictionaryMap.values );
            for aTopDD = topDDList
                obj.DictionaryNameToDataSourceMap( aTopDD{ 1 } ) = Simulink.data.internal.DataDictionary( aTopDD{ 1 } );
                obj.DictionaryDataSources{ end  + 1 } = obj.DictionaryNameToDataSourceMap( aTopDD{ 1 } );
            end
            obj.DictionaryDataSources = obj.DictionaryDataSources';


            broker = obj.getBroker(  );
            if obj.isBrokerSourceAvailable( broker )
                obj.DataSourceBroker = Simulink.data.internal.DataSourceBroker( broker );
            end


            if effectiveAccessToBWS
                obj.BaseWorkspaceDataSource = Simulink.data.internal.BaseWorkspace;
            end
        end


        function broker = getBroker( obj )
            bd = get_param( obj.Context, 'SlObject' );
            assert( isvalid( bd ), 'Block diagram does not exist' );
            broker = bd.getBroker(  );
            assert( isvalid( broker ), 'Broker does not exist' );
        end


        function isSourceAvailable = isBrokerSourceAvailable( ~, broker )
            brokerConfig = broker.getActiveBrokerConfig(  );
            sourceList = brokerConfig.getExplicitExternalSourceList(  );
            isSourceAvailable = ~isempty( sourceList );
        end


        function findGlobalDataNameSpaceClosureSources( obj )


            hierarchy = find_mdlrefs( obj.Context, 'AllLevels', true,  ...
                'MatchFilter', @Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices );

            findExternalDataSources( obj, obj.Context );
            for i = 1:length( hierarchy )
                if ~strcmp( hierarchy{ i }, obj.Context )
                    forceLoad = false;
                    if ~bdIsLoaded( hierarchy{ i } )
                        load_system( hierarchy{ i } );
                        forceLoad = true;
                    end
                    findExternalDataSources( obj, hierarchy{ i } )
                    if forceLoad
                        close_system( hierarchy{ i }, 0 );
                    end
                end
            end
        end


        function findLocalDataSources( obj )
            obj.ModelWorkspaceDataSource = Simulink.data.internal.ModelWorkspace( obj.Context );
        end


        function findDictionarySources( obj )
            effectiveAccessToBWS = false;

            ddName = obj.Context;
            if ~isempty( ddName )
                curDDHasBWSAccess = obj.updateDictionaryInfo( ddName );
                effectiveAccessToBWS = effectiveAccessToBWS || curDDHasBWSAccess;
            end


            topDDList = unique( obj.SubDictionaryToTopDictionaryMap.values );
            for aTopDD = topDDList
                obj.DictionaryNameToDataSourceMap( aTopDD{ 1 } ) = Simulink.data.internal.DataDictionary( aTopDD{ 1 } );
                obj.DictionaryDataSources{ end  + 1 } = obj.DictionaryNameToDataSourceMap( aTopDD{ 1 } );
            end
            obj.DictionaryDataSources = obj.DictionaryDataSources';


            if effectiveAccessToBWS
                obj.BaseWorkspaceDataSource = Simulink.data.internal.BaseWorkspace;
            end
        end


        function dataSource = findGatewayDataSourceFromId( obj, dataSrcId )
            dataSource = [  ];

            if ~isempty( obj.BaseWorkspaceDataSource ) &&  ...
                    strcmp( obj.BaseWorkspaceDataSource.DataSourceId, dataSrcId )
                dataSource = obj.BaseWorkspaceDataSource;
                return
            end

            if ~isempty( obj.ModelWorkspaceDataSource ) &&  ...
                    strcmp( obj.ModelWorkspaceDataSource.DataSourceId, dataSrcId )
                dataSource = obj.ModelWorkspaceDataSource;
                return
            end

            if ~isempty( obj.SubDictionaryToTopDictionaryMap ) &&  ...
                    obj.SubDictionaryToTopDictionaryMap.isKey( dataSrcId )
                topDD = obj.SubDictionaryToTopDictionaryMap( dataSrcId );
                if ~isempty( obj.DictionaryNameToDataSourceMap ) &&  ...
                        obj.DictionaryNameToDataSourceMap.isKey( topDD )
                    dataSource = obj.DictionaryNameToDataSourceMap( topDD );
                    return
                end
            end

            if ~isempty( obj.DataSourceBroker )
                isSourceExist = obj.DataSourceBroker.isSource( dataSrcId );
                if isSourceExist
                    dataSource = obj.DataSourceBroker;
                    return
                end
            end

            if ~isempty( obj.AdapterReadDataSources ) &&  ...
                    strcmp( obj.AdapterReadDataSources.ResolvedDataSourceId, dataSrcId )
                dataSource = obj.AdapterReadDataSources;
                return
            end
        end


        function openBusEditor( obj, variableId )
            dataSource = obj.findGatewayDataSourceFromId( variableId.DataSourceId );
            dataSource.openBusEditor( variableId );
        end



        function varIDs = createVarIdsFromDictEntries( ~, allEntries )
            varIDs = Simulink.data.VariableIdentifier.empty( 0, 0 );
            for idx = 1:length( allEntries )
                [ ~, fileName, ext ] = fileparts( allEntries( idx ).DataSource );
                dataSourceFileName = [ fileName, ext ];

                varIDs( idx ) =  ...
                    Simulink.data.VariableIdentifier( allEntries( idx ).Name,  ...
                    allEntries( idx ).Name,  ...
                    dataSourceFileName );
            end
            varIDs = varIDs';
        end


        function throwOutDuplicateSymbolError( ~, dataSourceList, varName )
            ex = MException( message( 'SLDD:sldd:DuplicateSymbol', varName ) );
            for i = 1:numel( dataSourceList )
                if strcmp( dataSourceList{ i }, 'base workspace' )
                    ex = ex.addCause( MException( message( 'SLDD:sldd:DataSourceHyperLinkHref',  ...
                        dataSourceList{ i }, '', 'base', varName ) ) );
                else
                    ex = ex.addCause( MException( message( 'SLDD:sldd:DataSourceHyperLinkHref',  ...
                        dataSourceList{ i }, which( dataSourceList{ i } ),  ...
                        'dictionary', varName ) ) );
                end
            end
            throw( ex );
        end


        function varIds = getVisibleVariablesFromSLDD( obj )
            varIds = Simulink.data.VariableIdentifier.empty( 0, 0 );
            ddEntries = Simulink.dd.getEntryInfoFromDictionaries( obj.DictionaryNameToDataSourceMap.keys, 'Design Data' );
            if ~isempty( ddEntries )
                varIds = obj.createVarIdsFromDictEntries( ddEntries );
            end
        end

        function [ isWritable, isReadonly ] = getFileAccessAttributes( ~, fileName )
            isWritable = false;
            isReadonly = false;
            if contains( fileName, '.sldd' ) || ~contains( fileName, '.' )

                [ status, attributes ] = fileattrib( which( fileName ) );
                if status == 1 && attributes.UserWrite
                    isWritable = true;
                end
                if status == 1 && ~attributes.UserWrite && attributes.UserRead
                    isReadonly = true;
                end
            else



                isWritable = false;
                isReadonly = true;
            end
        end

    end

    methods ( Static )

        function fileName = filenameFromFullPath( fullspec )
            [ ~, name, ext ] = fileparts( fullspec );
            fileName = [ name, ext ];
        end




        function varIDs = removeShadowVars( highScopedVarIDs, lowScopedVarIDs )
            highScopedVarNames = arrayfun( @( x )x.Name,  ...
                highScopedVarIDs, 'UniformOutput', false );

            if ~isempty( highScopedVarNames )
                lowScopedVarNames = arrayfun( @( x )x.Name,  ...
                    lowScopedVarIDs, 'UniformOutput', false );
                dummyValues = ones( 1, length( highScopedVarNames ) );
                highScopedVarNameMap = containers.Map( highScopedVarNames, dummyValues );
                indices = [  ];
                for i = 1:length( lowScopedVarNames )
                    if ~isKey( highScopedVarNameMap, lowScopedVarNames( i ) )
                        indices( end  + 1 ) = i;
                    end
                end
                varIDs = [ highScopedVarIDs;lowScopedVarIDs( indices ) ];
            else
                varIDs = lowScopedVarIDs;
            end
        end
    end
end

