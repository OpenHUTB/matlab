classdef WebViewDocument < slreportgen.webview.DocumentBase




    properties ( SetAccess = { ?slreportgen.webview.ExportOptions } )

        ExportOptions = [  ];
    end

    properties
        IncludeNotes logical = false;
        OptionalViews;
        IncrementalExport logical = false;
    end

    properties ( Access = private )
        HoleID char;
        CachedExportDiagrams struct = struct(  );
        CachedExportModels struct = struct(  );
        CachedModelHierarchy struct = struct(  );
        CachedWVProject struct = struct(  );
    end

    methods
        function this = WebViewDocument( outputFileName, varargin )
            this@slreportgen.webview.DocumentBase( outputFileName );


            this.TemplatePath = fullfile( slreportgen.webview.TemplatesDir, 'slwebview.htmtx' );


            if isempty( varargin )
                this.ExportOptions = slreportgen.webview.ExportOptions( this );
            else
                for i = 1:numel( varargin )
                    this.ExportOptions = [ this.ExportOptions ...
                        , slreportgen.webview.ExportOptions( this, 'Diagrams', varargin{ i } ) ];
                end
            end
        end


        function fillslwebview( this )
            this.appendWebView( 'slwebview' );
        end


        function appendWebView( this, holeID )
            arguments
                this
                holeID char
            end

            targetPackagePath = [ 'support/', holeID, '.json' ];
            supportPackagePath = [ 'support/', holeID, '_files/' ];
            modelElement = slreportgen.webview.ModelElement( this,  ...
                holeID,  ...
                '100%',  ...
                '100%',  ...
                targetPackagePath );
            this.append( modelElement.createDomElement(  ) );


            if ( slreportgen.webview.internal.version(  ) == 3 )
                wvProject = this.getWVProject( holeID );
                if ( isempty( wvProject.Models ) )
                    error( message( 'slreportgen_webview:document:NoExportDiagrams' ) );
                end

                director = slreportgen.webview.internal.ExportDirector(  );
                director.Project = wvProject;
                director.TargetPackagePath = targetPackagePath;
                director.SupportPackagePath = supportPackagePath;
                director.Indent = 1;
                director.IncludeNotes = this.IncludeNotes;
                director.Cache = this.IncrementalExport;
                director.SystemView = slreportgen.webview.views.SystemViewExporter(  );

                optionalViews = this.getOptionalViews(  );
                if iscell( optionalViews )
                    director.OptionalViews = [ optionalViews{ : } ];
                else
                    director.OptionalViews = optionalViews;
                end


                this.ProgressMonitor.setMaxValue( 0 );
                this.ProgressMonitor.addChild( director.ProgressMonitor );

                director.export( this );
                slreportgen.webview.internal.CacheManager.instance.close(  );
            else

                modelExporter = slreportgen.webview.ModelExporter( modelElement );


                modelExporter.IncludeNotes = this.IncludeNotes;


                modelExporter.OptionalViews = this.getOptionalViews(  );


                this.ProgressMonitor.addChild( modelExporter.ProgressMonitor );

                modelHierarchy = this.getModelHierarchy( holeID );
                if ( modelHierarchy.getNumberOfItems(  ) == 0 )
                    error( message( 'slreportgen_webview:document:NoExportDiagrams' ) );
                end

                modelExporter.export( modelHierarchy, [  ], [  ] );
            end
        end


        function [ diagramPaths, diagramHandles ] = getExportDiagrams( this, holeID )
            arguments
                this
                holeID char = this.getWebViewHoleId(  )
            end

            if isfield( this.CachedExportDiagrams, holeID )
                diagramPaths = this.CachedExportDiagrams.( holeID ).keys(  );
                diagramHandles = this.CachedExportDiagrams.( holeID ).values(  );
                return
            end

            if ( slreportgen.webview.internal.version(  ) == 3 )
                wvProject = this.getWVProject( holeID );
                selector = slreportgen.webview.internal.DiagramSelector(  );
                wvDiagrams = selector.getSelectedDiagrams( wvProject.Models );
                nwvDiagrams = numel( wvDiagrams );
                diagramPaths = cell( nwvDiagrams, 1 );
                diagramHandles = cell( nwvDiagrams, 1 );
                for i = 1:nwvDiagrams
                    diagramPaths{ i } = char( wvDiagrams( i ).path(  ) );
                    diagramHandles{ i } = wvDiagrams( i ).handle(  );
                end
            else
                modelHierarchy = this.getModelHierarchy( holeID );
                items = modelHierarchy.getCheckedItems(  );
                nItems = numel( items );
                diagramPaths = cell( nItems, 1 );
                diagramHandles = cell( nItems, 1 );
                for i = 1:nItems
                    diagramPaths{ i } = char( items( i ).getPath(  ) );
                    diagramHandles{ i } = items( i ).getDiagramBackingHandle(  );
                end
            end

            if this.isOpened(  )
                this.CachedExportDiagrams.( holeID ) = containers.Map( diagramPaths, diagramHandles );
            end
        end


        function [ modelNames, modelHandles ] = getExportModels( this, holeID )
            arguments
                this
                holeID char = this.getWebViewHoleId(  )
            end

            if isfield( this.CachedExportModels, holeID )
                modelNames = this.CachedExportModels.( holeID ).keys(  );
                modelHandles = this.CachedExportModels.( holeID ).values(  );
                return
            end

            if ( slreportgen.webview.internal.version(  ) == 3 )
                wvProject = this.getWVProject( holeID );
                nwvModels = numel( wvProject.Models );
                modelNames = cell( nwvModels, 1 );
                modelHandles = zeros( nwvModels, 1 );
                for i = 1:nwvModels
                    modelNames{ i } = char( wvProject.Models( i ).Name );
                    modelHandles( i ) = wvProject.Models( i ).handle(  );
                end
            else
                modelHierarchy = this.getModelHierarchy( holeID );
                items = modelHierarchy.getRootItems(  );
                nItems = numel( items );
                modelNames = cell( nItems, 1 );
                modelHandles = zeros( [ nItems, 1 ] );
                for i = 1:nItems
                    modelNames{ i } = char( items( i ).getPath(  ) );
                    modelHandles( i ) = items( i ).getDiagramBackingHandle(  );
                end
            end

            if isOpened( this )
                this.CachedExportModels.( holeID ) = containers.Map( modelNames, modelHandles );
            end
        end


        function [ sysPaths, sysHandles ] = getExportSimulinkSubSystems( this, holeID )
            arguments
                this
                holeID char = this.getWebViewHoleId(  )
            end

            function tf = isSubSystem( sys )
                tf = isnumeric( sys ) ...
                    && strcmp( get_param( sys, 'Type' ), 'block' ) ...
                    && strcmp( get_param( sys, 'BlockType' ), 'SubSystem' );
            end

            [ diagramPaths, diagramHandles ] = this.getExportDiagrams( holeID );
            sysIdx = cellfun( @isSubSystem, diagramHandles );
            sysPaths = diagramPaths( sysIdx );
            sysHandles = [ diagramHandles{ sysIdx } ]';
        end


        function [ chartPaths, chartHandles ] = getExportStateflowCharts( this, holeID )
            arguments
                this
                holeID char = this.getWebViewHoleId(  )
            end

            [ diagramPaths, diagramHandles ] = this.getExportDiagrams( holeID );
            chartIdx = cellfun( @( x )isa( x, 'Stateflow.Chart' ), diagramHandles );
            chartPaths = diagramPaths( chartIdx );
            chartHandles = [ diagramHandles{ chartIdx } ];
        end


        function [ sfDiagPaths, sfDiagObjs ] = getExportStateflowDiagrams( this, holeID )
            arguments
                this
                holeID char = this.getWebViewHoleId(  )
            end
            [ diagramPaths, diagramHandles ] = this.getExportDiagrams( holeID );
            chartIdx = cellfun( @( x )isa( x, 'Stateflow.Object' ), diagramHandles );
            sfDiagPaths = diagramPaths( chartIdx );
            sfDiagObjs = [ diagramHandles{ chartIdx } ];
        end


        function tf = isExportDiagram( this, diagram, holeID )
            arguments
                this
                diagram
                holeID char = this.getWebViewHoleId(  )
            end


            tf = false;
            if ( ~istext( diagram ) || slreportgen.utils.isSID( diagram ) )
                hs = slreportgen.utils.HierarchyService;
                diagramHID = hs.getDiagramHID( diagram );
                if hs.isValid( diagramHID )
                    diagramPath = hs.getPath( diagramHID );
                else
                    diagramPath = '';
                end
            else
                diagramPath = regexprep( diagram, '\s', ' ' );
            end

            if ~isempty( diagramPath )
                if isfield( this.CachedExportDiagrams, holeID )
                    tf = this.CachedExportDiagrams.( holeID ).isKey( diagramPath );
                else
                    tf = ismember( diagramPath, this.getExportDiagrams( holeID ) );
                end
            end
        end


        function tf = isExportElement( this, element, holeID )
            arguments
                this
                element
                holeID char = this.getWebViewHoleId(  )
            end

            hs = slreportgen.utils.HierarchyService;

            if ( ~istext( element ) || slreportgen.utils.isSID( element ) )
                elemH = slreportgen.utils.getSlSfHandle( element );
                if isa( elemH, 'Stateflow.Object' )
                    diagram = elemH.SubViewer;
                else
                    diagram = get_param( elemH, 'Parent' );
                end

                diagramHID = hs.getDiagramHID( diagram );
                diagramPath = hs.getPath( diagramHID );



                tf = isExportDiagram( this, diagramPath, holeID );
            else

                diagramPath = char( slreportgen.utils.pathParts( element ) );

                r = slroot(  );
                if ~r.isValidSlObject( element )

                    diagramHID = hs.getDiagramHID( diagramPath );
                    subviewer = slreportgen.utils.getSlSfHandle( diagramHID );
                    if isa( subviewer, 'Stateflow.Object' )
                        [ ~, elementName ] = slreportgen.utils.pathParts( element );
                        isValidElement = ~isempty( subviewer.find( 'Name', elementName, 'SubViewer', subviewer ) );
                        tf = isValidElement && this.isExportDiagram( diagramPath, holeID );
                    else
                        tf = false;
                    end
                else

                    tf = this.isExportDiagram( diagramPath, holeID );
                end
            end
        end
    end

    methods ( Access = protected )
        function holeID = getWebViewHoleId( this )

            if ~isempty( this.HoleID )
                holeID = this.HoleID;
                return
            end

            holeIDs = unique( { this.ExportOptions( : ).WebViewHoleId } );
            nHoleIDs = numel( holeIDs );
            if ( nHoleIDs > 1 )


                quotedHoleIDs = cellfun( @( x )sprintf( '''%s''', x ), holeIDs, 'UniformOutput', false );
                error( message( 'slreportgen_webview:document:MustSpecifyWebViewHoleId',  ...
                    sprintf( '{%s}', strjoin( quotedHoleIDs, ', ' ) ) ) );
            end
            holeID = holeIDs{ 1 };


            if this.isOpened(  )
                this.HoleID = holeID;
            end
        end
    end

    methods ( Access = private )
        function out = getWVProject( this, webviewHoleId )
            if isfield( this.CachedWVProject, webviewHoleId )

                out = this.CachedWVProject.( webviewHoleId );
            else
                out = this.createWVProject( webviewHoleId );
                return ;
            end
        end

        function out = createWVProject( this, webviewHoleId )

            projectBuilder = slreportgen.webview.internal.ProjectBuilder(  ...
                Cache = this.IncrementalExport );
            for i = 1:numel( this.ExportOptions )
                opts = this.ExportOptions( i );
                if strcmp( opts.WebViewHoleId, webviewHoleId )
                    projectBuilder.IncludeMaskedSubsystems = opts.IncludeMaskedSubsystems;
                    projectBuilder.IncludeSimulinkLibraryLinks = opts.IncludeSimulinkLibraryLinks;
                    projectBuilder.IncludeUserLibraryLinks = opts.IncludeUserLibraryLinks;
                    projectBuilder.IncludeReferencedModels = opts.IncludeReferencedModels;
                    projectBuilder.CurrentAndBelowCallback = opts.FilterCallback;

                    if ischar( opts.Diagrams )
                        diagrams = { opts.Diagrams };
                    else
                        diagrams = opts.Diagrams;
                    end

                    for j = 1:numel( diagrams )
                        if iscell( diagrams )
                            diagramName = diagrams{ j };
                        else
                            diagramName = diagrams( j );
                        end
                        switch opts.SearchScope
                            case 'All'
                                projectBuilder.addAll( diagramName );
                            case 'CurrentAndBelow'
                                projectBuilder.addDown( diagramName );
                            case 'CurrentAndAbove'
                                projectBuilder.addUp( diagramName );
                            case 'Current'
                                projectBuilder.add( diagramName );
                        end
                    end
                end
            end
            out = projectBuilder.build(  );


            if isOpened( this )
                this.CachedWVProject.( webviewHoleId ) = out;
            end
        end

        function modelHierarchy = getModelHierarchy( this, holeID )
            arguments
                this
                holeID char = this.getWebViewHoleId(  )
            end

            if isfield( this.CachedModelHierarchy, holeID )
                modelHierarchy = this.CachedModelHierarchy.( holeID );
                return ;
            end

            modelHierarchy = slreportgen.webview.ModelHierarchy(  );
            filter = slreportgen.webview.ModelHierarchyFilter(  );

            for i = 1:numel( this.ExportOptions )
                opts = this.ExportOptions( i );
                if strcmp( opts.WebViewHoleId, holeID )
                    filter.IncludeMaskedSubsystems = opts.IncludeMaskedSubsystems;
                    filter.IncludeSimulinkLibraryLinks = opts.IncludeSimulinkLibraryLinks;
                    filter.IncludeUserLibraryLinks = opts.IncludeUserLibraryLinks;
                    filter.IncludeReferencedModels = opts.IncludeReferencedModels;
                    filter.FilterCallback = opts.FilterCallback;

                    switch ( opts.SearchScope )
                        case 'Current'
                            modelHierarchy.addItems( opts.Diagrams );
                        case 'CurrentAndAbove'
                            modelHierarchy.addItemsAndTheirAncestors( opts.Diagrams );
                        case 'CurrentAndBelow'
                            modelHierarchy.addItemsAndTheirDescendants( opts.Diagrams, filter );
                        case 'All'
                            modelHierarchy.addItemsFromRootAndTheirDescendants( opts.Diagrams, filter );
                    end
                end
            end


            if this.isOpened(  )
                this.CachedModelHierarchy.( holeID ) = modelHierarchy;
            end
        end

        function optViews = getOptionalViews( this )
            optViews = {  };
            if ~isempty( this.OptionalViews )
                if ischar( this.OptionalViews )
                    optViews = resolveOptionalView( this.OptionalViews );
                else
                    n = numel( this.OptionalViews );
                    optViews = cell( 1, n );
                    if iscell( this.OptionalViews )
                        for i = 1:n
                            optViews{ i } = resolveOptionalView( this.OptionalViews{ i } );
                        end
                    else
                        for i = 1:n
                            optViews{ i } = resolveOptionalView( this.OptionalViews( i ) );
                        end
                    end
                    optViews( cellfun( @isempty, optViews ) ) = [  ];
                end
            end
        end
    end
end

function optView = resolveOptionalView( in )
optView = [  ];
if istext( in )
    registeredViews = slreportgen.webview.views.getRegisteredViews(  );
    nRegisteredViews = numel( registeredViews );
    for i = 1:nRegisteredViews
        regView = registeredViews{ i };
        if strcmpi( regView.Id, in )
            regView.WidgetEnableValue = true;
            optView = regView;
            return
        end
    end

    registeredViewIds = strjoin( cellfun( @( x )x.Id, registeredViews, 'UniformOutput', false ), ', ' );
    warning( message( 'slreportgen_webview:webview:InvalidOptionalView', in, registeredViewIds ) );
else
    optView = in;
end
end

function tf = istext( in )
tf = ischar( in ) || isstring( in );
end

