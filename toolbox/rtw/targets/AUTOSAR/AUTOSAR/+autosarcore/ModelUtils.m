classdef ( Hidden )ModelUtils

    methods ( Static )
        function modelMapping = modelMapping( modelName )


            mappingManager = get_param( modelName, 'MappingManager' );
            if autosarcore.ModelUtils.isMappedToComponent( modelName )
                modelMapping = mappingManager.getActiveMappingFor( 'AutosarTarget' );
            elseif autosarcore.ModelUtils.isMappedToComposition( modelName )
                modelMapping = mappingManager.getActiveMappingFor( 'AutosarComposition' );
            elseif autosarcore.ModelUtils.isMappedToAdaptiveApplication( modelName )
                modelMapping = mappingManager.getActiveMappingFor( 'AutosarTargetCPP' );
            else
                autosar.validation.AutosarUtils.reportErrorWithFixit(  ...
                    'Simulink:Engine:RTWCGAutosarEmptyConfigurationError',  ...
                    getfullname( modelName ) );
            end
        end

        function m3iElementFactory = getM3IElementFactory( modelName )


            m3iModelLocal = autosar.api.Utils.m3iModel( modelName );
            if autosar.dictionary.Utils.hasReferencedModels( m3iModelLocal )
                m3iModelShared = autosar.dictionary.Utils.getUniqueReferencedModel( m3iModelLocal );
                m3iElementFactory = Simulink.metamodel.arplatform.ElementFactory( m3iModelLocal, m3iModelShared );
            else
                m3iElementFactory = Simulink.metamodel.arplatform.ElementFactory( m3iModelLocal, m3iModelLocal );
            end
        end

        function writeM3IModelToFile( m3iModel, xmiFileName, exportToVersion )




            opts = M3I.XmiWriterSettings;
            opts.AutoFlush = false;
            opts.WriteModelObject = true;
            xwf = M3I.XmiWriterFactory;
            targetVersion = simulink_version( exportToVersion );
            currentVersion = simulink_version;
            isExportToPreviousRelease = ~strcmp( currentVersion.release, targetVersion.release );
            if isExportToPreviousRelease
                transform = autosarcore.mm.compatibility.transform(  );
                sv = saveas_version( targetVersion.release );
                transform.addExportersToFactory( xwf, sv.version );
            end
            xw = xwf.createXmiWriter( opts );




            reRegisterListener = autosarcore.unregisterListenerCBTemporarily( m3iModel );%#ok<NASGU>





            if Simulink.AutosarDictionary.ModelRegistry.hasReferencedModels( m3iModel )
                origWarn = warning( 'off', 'M3I:Serializer:XmiWriter:NonPortableUri' );
                restoreOrigWarn = onCleanup( @(  )warning( origWarn ) );
            end

            xw.write( xmiFileName, m3iModel );
        end

        function [ isSharedDict, dictFiles ] = isUsingSharedAutosarDictionary( modelName, namedargs )




            arguments
                modelName
                namedargs.IsUIMode = false
                namedargs.RunDictChecks = true
            end

            import autosar.dictionary.internal.DictionaryLinkUtils

            isSharedDict = false;
            dictFiles = {  };





            if Simulink.internal.isArchitectureModel( modelName, 'AUTOSARArchitecture' )
                [ isSharedDict, dictFiles ] = DictionaryLinkUtils.isModelLinkedToAUTOSARInterfaceDictionary( modelName );
                return ;
            end

            if autosarcore.ModelUtils.isMapped( modelName )
                if ~isempty( autosarcore.ModelUtils.getMappingSharedDictUUID( modelName ) )



                    [ isLinkedToInterfaceDict, dictFiles ] =  ...
                        autosar.dictionary.internal.DictionaryLinkUtils.isModelLinkedToAUTOSARInterfaceDictionary( modelName );
                    if isLinkedToInterfaceDict
                        assert( numel( dictFiles ) == 1, 'Expected model to be linked to a single interface dictionary.' );
                        dictFile = dictFiles{ 1 };
                        ddName = autosar.utils.File.dropPath( dictFile );
                    else



                        ddName = get_param( modelName, 'DataDictionary' );
                    end


                    if namedargs.RunDictChecks
                        autosarcore.M3IModelLoader.runSharedAUTOSARDictChecks(  ...
                            modelName, ddName );
                    end

                    isSharedDict = true;
                    ddConn = Simulink.dd.open( ddName );
                    dictFiles = { ddConn.filespec(  ) };
                end
            end
        end


        function m3iComp = m3iMappedComponent( modelName )
            assert( autosarcore.ModelUtils.isMapped( modelName ),  ...
                'cannot call m3iMappedComponent because model "%s" is not mapped.',  ...
                getfullname( modelName ) );
            m3iModel = autosarcore.M3IModelLoader.loadM3IModel( modelName );
            modelMapping = autosarcore.ModelUtils.modelMapping( modelName );




            componentId = modelMapping.MappedTo.UUID;
            compQName = autosarcore.ModelUtils.convertComponentIdToQName( componentId );
            autosarcore.ModelUtils.checkQualifiedName( modelName, compQName, 'absPathShortName' );


            m3iComp = autosarcore.MetaModelFinder.findChildByName( m3iModel, compQName );
            assert( m3iComp.isvalid(  ), 'Did not find mapped Component' );
        end





        function m3iModel = getSharedElementsM3IModel( modelName )
            if autosar.api.Utils.isUsingSharedAutosarDictionary( modelName )
                m3iModel = autosarcore.M3IModelLoader.loadSharedM3IModel( modelName );
            else
                m3iModel = autosarcore.M3IModelLoader.loadM3IModel( modelName );
            end
        end





        function m3iModel = getLocalElementsM3IModel( modelName )
            m3iModel = autosarcore.M3IModelLoader.loadM3IModel( modelName );
        end

        function dictUUID = getMappingSharedDictUUID( modelName )
            dictUUID = [  ];
            if ~autosarcore.ModelUtils.isMappedToAdaptiveApplication( modelName )
                mapping = autosarcore.ModelUtils.modelMapping( modelName );
                dictUUID = mapping.SharedAUTOSARDictionaryUUID;
            end
        end

        function [ isMapped, modelMapping ] = isMapped( modelName )


            [ isMapped, modelMapping ] = autosarcore.ModelUtils.isMappedToComponent( modelName );
            if ~isMapped
                [ isMapped, modelMapping ] = autosarcore.ModelUtils.isMappedToComposition( modelName );
            end
            if ~isMapped
                [ isMapped, modelMapping ] = autosarcore.ModelUtils.isMappedToAdaptiveApplication( modelName );
            end
        end


        function [ isMapped, modelMapping ] = isMappedToComponent( modelName )
            modelMapping = [  ];
            mappingManager = get_param( modelName, 'MappingManager' );
            mapping = mappingManager.getActiveMappingFor( 'AutosarTarget' );
            isMapped = isa( mapping, 'Simulink.AutosarTarget.ModelMapping' );
            if isMapped
                modelMapping = mapping;
            end
        end

        function [ isMapped, modelMapping ] = isMappedToAdaptiveApplication( modelName )
            modelMapping = [  ];
            mappingManager = get_param( modelName, 'MappingManager' );
            mapping = mappingManager.getActiveMappingFor( 'AutosarTargetCPP' );
            isMapped = isa( mapping, 'Simulink.AutosarTarget.AdaptiveModelMapping' );
            if isMapped
                modelMapping = mapping;
            end
        end

        function [ isMapped, modelMapping ] = isMappedToComposition( modelName )
            modelMapping = [  ];
            mappingManager = get_param( modelName, 'MappingManager' );
            mapping = mappingManager.getActiveMappingFor( 'AutosarComposition' );
            isMapped = isa( mapping, 'Simulink.AutosarTarget.CompositionModelMapping' );
            if isMapped
                modelMapping = mapping;
            end
        end

        function uniquifyMappingName( model )


            modelName = get_param( model, 'Name' );
            mapping = autosarcore.ModelUtils.modelMapping( modelName );
            mappingType = autosarcore.ModelUtils.getMappingType( modelName );
            mapping.Name = autosarcore.ModelUtils.createMappingName( modelName, mappingType );
        end

        function mappingName = createMappingName( modelName, mappingType )


            assert( any( strcmp( mappingType,  ...
                { 'AutosarTarget', 'AutosarTargetCPP', 'AutosarComposition' } ) ),  ...
                'Invalid mapping type' );

            mappingName = [ get_param( modelName, 'Name' ), '_', mappingType ];
            if length( mappingName ) > namelengthmax
                mappingName = mappingName( 1:namelengthmax );
            end
        end

        function mappingType = getMappingType( modelName )

            if autosarcore.ModelUtils.isMappedToComponent( modelName )
                mappingType = 'AutosarTarget';
            elseif autosarcore.ModelUtils.isMappedToComposition( modelName )
                mappingType = 'AutosarComposition';
            elseif autosarcore.ModelUtils.isMappedToAdaptiveApplication( modelName )
                mappingType = 'AutosarTargetCPP';
            else
                DAStudio.error( 'Simulink:Engine:RTWCGAutosarEmptyConfigurationError', getfullname( modelName ) );
            end
        end

        function compQName = convertComponentIdToQName( componentId )

            if contains( componentId, '.' )

                compQName = regexprep( componentId, '^AUTOSAR', '' );
                compQName = strrep( compQName, '.', '/' );
            else


                compQName = componentId;
            end
        end

        function checkQualifiedName( modelName, qualifiedName, idType )
            isAUTOSAR = strcmp( get_param( modelName, 'AutosarCompliant' ), 'on' );
            if ~isAUTOSAR

                return ;
            end

            maxShortNameLength = get_param( modelName, 'AutosarMaxShortNameLength' );
            autosarcore.ModelUtils.checkQualifiedName_impl( qualifiedName, idType, maxShortNameLength );
        end

        function isCompositionDomain = isModelInCompositionDomain( model )
            modelH = get_param( model, 'Handle' );
            isCompositionDomain = strcmp( get_param( modelH, 'Type' ), 'block_diagram' ) &&  ...
                Simulink.internal.isArchitectureModel( modelH, 'AUTOSARArchitecture' );
        end











        function extraInfo = getExtraExternalToolInfo( m3iObj, toolId, fields, fmt )

            assert( ( ischar( toolId ) || isStringScalar( toolId ) ) &&  ...
                ( iscellstr( fields ) || isstring( fields ) ) && ( iscellstr( fmt ) || isstring( fmt ) ) &&  ...
                ( numel( fields ) == numel( fmt ) ) );


            values = repmat( { [  ] }, size( fields ) );
            extraInfo = cell2struct( values, fields, 2 );


            tok = regexp( m3iObj.getExternalToolInfo( toolId ).externalId,  ...
                '#', 'split' );
            for ii = 1:numel( tok )
                extraInfo.( fields{ ii } ) = sscanf( tok{ ii }, fmt{ ii } );
            end
        end



        function toolId = setExternalToolInfo( obj, toolName, toolId )
            narginchk( 2, 3 );

            if nargin < 3 || ~( ischar( toolId ) || isStringScalar( toolId ) )
                toolId = char( matlab.lang.internal.uuid(  ) );
            end

            obj.setExternalToolInfo( M3I.ExternalToolInfo( toolName, toolId ) );
        end







        function externalId = setExtraExternalToolInfo( m3iObj, toolId, fmt, values )

            assert( ( ischar( toolId ) || isStringScalar( toolId ) ) &&  ...
                ( iscellstr( fmt ) || isstring( fmt ) ) && iscell( values ) &&  ...
                ( numel( values ) == numel( fmt ) ) );

            externalId = '';
            sep = '';
            for ii = 1:numel( fmt )
                externalId = sprintf( [ '%s', sep, fmt{ ii } ], externalId, values{ ii } );
                sep = '#';
            end
            externalId = autosarcore.ModelUtils.setExternalToolInfo( m3iObj, toolId, externalId );
        end
    end

    methods ( Hidden, Static )
        function checkQualifiedName_impl( qualifiedName, idType, maxShortNameLength )

            [ isValid, errmsg, errId ] = autosarcore.checkIdentifier( qualifiedName, idType, maxShortNameLength );
            if ~isValid
                exception = MSLException( [  ], errId, '%s', errmsg );
                throwAsCaller( exception );
            end
        end
    end
end


