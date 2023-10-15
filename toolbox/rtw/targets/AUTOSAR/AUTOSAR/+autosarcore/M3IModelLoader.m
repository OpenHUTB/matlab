classdef M3IModelLoader < handle




    methods ( Static )

        function m3iModel = loadM3IModel( modelOrInterfaceDictName, namedargs )


            arguments
                modelOrInterfaceDictName
                namedargs.ShowProgressBar = false




                namedargs.LoadReferencedM3IModels = true







                namedargs.ReTargetExternalDanglingReferences = true

                namedargs.IsUIMode = false
            end


            if ( ischar( modelOrInterfaceDictName ) || isstring( modelOrInterfaceDictName ) ) &&  ...
                    endsWith( modelOrInterfaceDictName, '.sldd' )
                m3iModel = autosarcore.M3IModelLoader.loadDictionaryM3IModel( modelOrInterfaceDictName );
            else
                modelName = get_param( modelOrInterfaceDictName, 'Name' );
                m3iModel = autosarcore.M3IModelLoader.loadSLModelM3IModel( modelName, namedargs );
            end
        end

        function m3iModel = loadSLModelM3IModel( modelName, namedargs )


            mapping = autosarcore.ModelUtils.modelMapping( modelName );
            m3iModel = mapping.AUTOSAR_ROOT;

            refM3IModelsLoaded = false;
            m3iModelLoaded = false;

            if isempty( m3iModel ) || ~m3iModel.isvalid(  )
                opts = Simulink.internal.BDLoadOptions( modelName );
                arPartName = '/autosar/autosar.xmi';
                if isempty( opts.readerHandle ) || ~opts.readerHandle.hasPart( arPartName )
                    return ;
                end

                xmiFileName = Simulink.slx.getUnpackedFileNameForPart( modelName, arPartName );
                if ~exist( xmiFileName, 'file' )
                    opts.readerHandle.readPartToFile( arPartName, xmiFileName );
                end


                mdlhandle = get_param( modelName, 'Handle' );
                srcRelease = get_param( mdlhandle, 'VersionLoaded' );
                xmiReader = autosarcore.M3IModelLoader.createXmiReader( srcRelease );

                if namedargs.ShowProgressBar
                    pb = Simulink.internal.ScopedProgressBar( DAStudio.message( 'autosarstandard:ui:uiLoadAUTOSAR' ) );%#ok<NASGU>
                end




                if namedargs.LoadReferencedM3IModels
                    refM3IModels = autosarcore.M3IModelLoader.loadReferencedM3IModels(  ...
                        modelName, namedargs.IsUIMode );
                    for idx = 1:length( refM3IModels )
                        xmiReader.addReferencedModel( refM3IModels( idx ) );
                    end
                end


                mapping.AUTOSAR_ROOT = xmiReader.read( xmiFileName );
                m3iModel = mapping.AUTOSAR_ROOT;

                if namedargs.LoadReferencedM3IModels && ~isempty( refM3IModels )
                    refM3IModelsLoaded = true;


                    for idx = 1:length( refM3IModels )
                        Simulink.AutosarDictionary.ModelRegistry.addReferencedModel( m3iModel, refM3IModels( idx ) );
                    end
                end

                m3iModelLoaded = true;
            else


                if namedargs.LoadReferencedM3IModels &&  ...
                        namedargs.ReTargetExternalDanglingReferences &&  ...
                        Simulink.AutosarDictionary.ModelRegistry.hasReferencedModels( m3iModel )
                    refM3IModelsLoaded = autosarcore.M3IModelLoader.reTargetAnyDanglingReferences( modelName,  ...
                        m3iModel, namedargs.IsUIMode );
                end
            end

            if refM3IModelsLoaded
                if ~autosarcore.ModelUtils.isMappedToComposition( modelName )


                    autosar.dictionary.MappingUpdaterForSharedDictionary.handleMappingForDeletedReferences( modelName );
                end
            end

            if m3iModelLoaded || refM3IModelsLoaded

                autosarcore.importFromPreviousVersion( get_param( modelName, 'Handle' ) );
            end
        end

        function m3iModel = loadSharedM3IModel( modelName )

            m3iModel = [  ];
            [ isSharedDict, dictFiles ] = autosarcore.ModelUtils.isUsingSharedAutosarDictionary( modelName );
            if isSharedDict
                dictFile = dictFiles{ 1 };
                m3iModel = autosarcore.M3IModelLoader.loadDictionaryM3IModel( dictFile );
            end
        end

        function xmiReader = createXmiReader( srcRelease )


            autosar.mm.util.MessageStreamHandler.initMessageStreamHandler(  );

            xf = M3I.XmiReaderFactory;
            if ~isempty( srcRelease )
                assert( isnumeric( srcRelease ), 'srcRelease must be numeric' );
                transform = autosarcore.mm.compatibility.transform(  );
                transform.addImportersToFactory( xf, srcRelease );
            end
            xmiReader = xf.createXmiReader;
            initialModel = Simulink.metamodel.foundation.Factory.createNewModel(  );
            xmiReader.setInitialModel( initialModel );
        end
    end

    methods ( Static )
        function runSharedAUTOSARDictChecks( modelName, dictName )




            if isempty( dictName )
                autosar.validation.AutosarUtils.reportErrorWithFixit(  ...
                    'autosarstandard:dictionary:UnexpectedDictionaryFileForARProperties',  ...
                    modelName );
            end


            ddConn = Simulink.data.dictionary.open( dictName );
            dictFile = ddConn.filepath;


            if ~autosar.dictionary.Utils.isSharedAutosarDictionary( dictFile )
                autosar.validation.AutosarUtils.reportErrorWithFixit(  ...
                    'autosarstandard:dictionary:UnexpectedDictionaryFileForARProperties',  ...
                    modelName );
            end



            mappingDictUUID = autosarcore.ModelUtils.getMappingSharedDictUUID( modelName );
            if ~isempty( mappingDictUUID )
                refM3IModel = Simulink.AutosarDictionary.ModelRegistry.getOrLoadM3IModel( dictFile );
                dictionaryUUID = autosar.dictionary.Utils.getDictionaryUUID( refM3IModel );

                if ~strcmp( mappingDictUUID, dictionaryUUID )
                    autosar.validation.AutosarUtils.reportErrorWithFixit(  ...
                        'autosarstandard:dictionary:UnexpectedDictionaryFileForARProperties',  ...
                        modelName );
                end
            end
        end
    end

    methods ( Static, Access = private )
        function m3iModel = loadDictionaryM3IModel( dictName )
            ddConn = Simulink.data.dictionary.open( dictName );
            m3iModel = Simulink.AutosarDictionary.ModelRegistry.getOrLoadM3IModel( ddConn.filepath(  ) );
        end

        function needToRetarget = reTargetAnyDanglingReferences( modelName, m3iModel, isUIMode )

            needToRetarget = false;
            refModels = Simulink.AutosarDictionary.ModelRegistry.getReferencedModels( m3iModel );
            for idx = 1:refModels.size
                if ~refModels.at( idx ).isvalid(  )



                    needToRetarget = true;
                    break ;
                end
            end

            if needToRetarget

                refM3IModels = autosarcore.M3IModelLoader.loadReferencedM3IModels( modelName, isUIMode );



                Simulink.AutosarDictionary.ModelRegistry.removeAllReferencedModels( m3iModel );
                addRefModels = onCleanup( @(  ) ...
                    autosarcore.M3IModelLoader.registerAsReferencedM3IModels( m3iModel, refM3IModels ) );


                m3iPkgElms = autosar.mm.Model.findPackageableElements( m3iModel );
                tran = autosar.utils.M3ITransaction( m3iModel, DisableListeners = true );
                for i = 1:m3iPkgElms.size(  )
                    M3I.deepReTargetExternalDanglingReferences( m3iPkgElms.at( i ) );
                end
                tran.commit(  );
            end
        end

        function registerAsReferencedM3IModels( m3iModel, refM3IModels )
            for idx = 1:length( refM3IModels )
                Simulink.AutosarDictionary.ModelRegistry.addReferencedModel( m3iModel, refM3IModels( idx ) );
            end
        end

        function [ refM3IModels, dictFiles ] = loadReferencedM3IModels( modelName, isUIMode )

            refM3IModels = [  ];

            [ isUsingSharedDict, dictFiles ] = autosarcore.ModelUtils.isUsingSharedAutosarDictionary(  ...
                modelName, IsUIMode = isUIMode );

            if isUsingSharedDict
                mapping = autosarcore.ModelUtils.modelMapping( modelName );
                for dictIdx = 1:length( dictFiles )
                    dictFile = dictFiles{ dictIdx };



                    mapping.DDConnectionToSharedAUTOSARDictionary =  ...
                        [ mapping.DDConnectionToSharedAUTOSARDictionary ...
                        , Simulink.dd.open( dictFile ) ];


                    refM3IModel = Simulink.AutosarDictionary.ModelRegistry.getOrLoadM3IModel( dictFile );


                    refM3IModels = [ refM3IModels, refM3IModel ];%#ok<AGROW>
                end
            end
        end
    end
end


