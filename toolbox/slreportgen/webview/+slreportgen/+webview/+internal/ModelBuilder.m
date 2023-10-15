classdef ModelBuilder < handle


















    properties ( Access = private, Constant )



        UnsupportedSFClasses = {  ...
            'Stateflow.StateTransitionTableChart',  ...
            'Stateflow.TruthTableChart',  ...
            'Stateflow.TruthTable' ...
            };

        CacheFileName = "hierarchy.mat";
    end

    properties ( Access = private )
        TreeFilter SLM3I.SLTreeFilter
        NeedsToCloseCache logical
        Libraries
        ModelCache
        IsSFLicensed logical
    end

    methods
        function this = ModelBuilder(  )
            treeFilter = SLM3I.SLTreeFilter(  );
            treeFilter.ShowSystemsWithMaskedParameters = true;
            treeFilter.ShowReferencedModels = true;
            treeFilter.ShowUserLinks = true;
            treeFilter.ShowMathworksLinks = true;
            this.TreeFilter = treeFilter;
            this.IsSFLicensed = license( "test", "Stateflow" );
        end

        function delete( this )
            try


                if this.NeedsToCloseCache
                    slreportgen.webview.internal.CacheManager.instance(  ).close(  );
                end
            catch ME
                warning( ME.message );
            end
        end

        function model = build( this, modelName, options )

            arguments
                this
                modelName string{ mustBeNonempty, mustBeNonzeroLengthText }
                options.Force logical = false;
                options.LoadLibraries logical = true;
                options.Cache logical = true;
            end

            if ( options.Force || ~options.Cache )
                model = this.buildImpl( modelName, options );
            else
                model = this.cacheImpl( modelName );
                if isempty( model ) ||  ...
                        ( ~model.isBuiltWithLibrariesLoaded && options.LoadLibraries )
                    model = this.buildImpl( modelName, options );
                end
            end
        end
    end

    methods ( Access = private )
        function model = buildImpl( this, modelName, options )
            hs = slreportgen.utils.HierarchyService;

            load_system( modelName );
            modelH = slreportgen.utils.getSlSfHandle( modelName );

            if options.LoadLibraries
                this.loadLibraries( modelH );
            end

            model = slreportgen.webview.internal.Model(  );
            model.setIsBuiltWithLibrariesLoaded( options.LoadLibraries );
            model.setIsBuiltWithCacheEnabled( options.Cache );


            diagramBuilder = slreportgen.webview.internal.DiagramBuilder( model );
            diagramBuilder.HID = hs.getDiagramHID( modelH );
            diagramBuilder.Handle = modelH;
            [ rootDiagram, dbcache ] = diagramBuilder.build(  );
            model.setRootDiagram( rootDiagram );

            stack = { rootDiagram };
            top = 1;
            while ( top > 0 )
                diagram = stack{ top };
                top = top - 1;

                diagramHID = diagram.hid( Validate = false );
                childElementHIDs = hs.getChildren( diagramHID );
                nChildElementHIDs = numel( childElementHIDs );

                if ( top + nChildElementHIDs ) > numel( stack )
                    stack{ top + nChildElementHIDs } = [  ];
                end

                for i = 1:nChildElementHIDs
                    childElementHID = childElementHIDs( i );
                    if this.TreeFilter.keepHid( childElementHID )
                        childElementHnd = slreportgen.utils.getSlSfHandle( childElementHID );

                        if slreportgen.utils.isModelReferenceBlock( childElementHnd, Resolve = false )
                            slreportgen.webview.internal.ReferenceDiagramInterface.saveReferencedModel( diagram, childElementHnd );
                        elseif slreportgen.utils.isSubsystemReferenceBlock( childElementHnd, Resolve = false )
                            slreportgen.webview.internal.ReferenceDiagramInterface.saveReferencedSubsystem( diagram, childElementHnd );
                        else
                            childDiagramHID = hs.getChildren( childElementHID );
                            if ~isempty( childDiagramHID )
                                childDiagramHID = childDiagramHID( 1 );
                                childDiagramHnd = slreportgen.utils.getSlSfHandle( childDiagramHID );
                                if this.isSupported( childDiagramHID, childDiagramHnd )
                                    diagramBuilder = slreportgen.webview.internal.DiagramBuilder( model, dbcache );
                                    diagramBuilder.Parent = diagram;
                                    diagramBuilder.HID = childDiagramHID;
                                    diagramBuilder.Handle = childDiagramHnd;
                                    diagramBuilder.EHID = childElementHID;
                                    diagramBuilder.EHandle = childElementHnd;
                                    diagramBuilder.IsModelReference = false;
                                    diagramBuilder.IsSubsystemReference = false;
                                    [ childDiagram, dbcache ] = diagramBuilder.build(  );
                                    top = top + 1;
                                    stack{ top } = childDiagram;
                                end
                            end
                        end
                    end
                end

                diagram.sortChildren(  );
            end

            part = slreportgen.webview.internal.Part( model );


            model.addPart( part );


            model.setNotes( get_param( model.handle(  ), "Notes" ) );


            if options.Cache
                this.saveToModelCache( model );
            end
        end

        function model = cacheImpl( this, modelName )
            model = [  ];

            cacheManager = slreportgen.webview.internal.CacheManager.instance(  );
            if cacheManager.isEnabled(  )
                if ~cacheManager.isOpen(  )
                    cacheManager.open(  );
                    this.NeedsToCloseCache = true;
                end

                modelCache = cacheManager.get( modelName );
                if ~isempty( modelCache )
                    if modelCache.hasFile( this.CacheFileName )

                        cacheFile = modelCache.getFile( this.CacheFileName );
                        tmp = load( cacheFile );
                        model = tmp.model;
                        model.setIsBuiltWithCacheEnabled( true );
                    end
                    this.ModelCache = modelCache;
                else
                    this.ModelCache = [  ];
                end
            end
        end

        function saveToModelCache( this, model )
            if ~isempty( this.ModelCache )
                for i = 1:numel( this.Libraries )
                    lib = this.Libraries{ i };
                    if ~strcmpi( lib, "simulink" ) && ~strcmp( lib, "simulink_extras" )
                        this.ModelCache.addLibraryDependency( lib );
                    end
                end
                cacheFilePath = this.ModelCache.createFile( this.CacheFileName );
                save( cacheFilePath, "model" );
                this.ModelCache = [  ];
            end
        end

        function modelCache = getModelCache( this, modelName )
            cacheManager = slreportgen.webview.internal.CacheManager.instance(  );
            if ( cacheManager.IsEnabled && ~cacheManager.IsOpen )
                cacheManager.open(  );
                this.NeedsToCloseCache = true;
            end
            modelCache = cacheManager.get( modelName );
        end

        function loadLibraries( this, modelH )
            libdata = libinfo( modelH,  ...
                'RegExp', 'on',  ...
                'MatchFilter', @Simulink.match.allVariants,  ...
                'FollowLinks', 'on',  ...
                'LookUnderMasks', 'all',  ...
                'LinkStatus', '^resolved|implicit' );

            this.Libraries = unique( { libdata.Library } );
            for i = 1:numel( this.Libraries )
                library = this.Libraries{ i };
                try
                    load_system( library );
                catch ME
                    warning( ME.identifier, "%s", ME.message );
                end
            end
        end

        function tf = isSupported( this, diagramHID, diagramHnd )

            tf = this.IsSFLicensed || ( isnumeric( diagramHnd ) && ~strcmpi( get_param( diagramHnd, "MaskType" ), "INVALID" ) );

            if tf
                hs = slreportgen.utils.HierarchyService;
                domain = hs.getDomain( diagramHID );


                tf = strcmp( domain, 'Simulink' ) ...
                    || strcmp( domain, 'Stateflow' ) && ~ismember( class( diagramHnd ), this.UnsupportedSFClasses );



                if tf && isa( diagramHnd, 'Stateflow.Chart' ) && Stateflow.ReqTable.internal.isRequirementsTable( sfprivate( 'getChartOf', diagramHnd.Id ) )
                    tf = false;
                end
            end
        end
    end
end
