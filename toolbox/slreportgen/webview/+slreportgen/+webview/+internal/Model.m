classdef ( ConstructOnLoad )Model < handle






































    properties ( SetAccess = private )

        Name = string.empty(  )


        RootDiagram
    end

    properties ( Dependent )

        Diagrams
    end

    properties ( SetAccess = private )

        Parts = slreportgen.webview.internal.Part.empty(  )


        Notes string


        HasReferencedModels logical = false;


        HasReferencedSubsystems logical = false;

        DiagramCount uint64 = 0;
    end

    properties ( Transient )

        ExportData slreportgen.webview.internal.ModelExportData
    end

    properties ( Transient, Access = private )
        IsReferencedModelLoaded logical = false;
        IsReferencedSubsystemsLoaded logical = false;
        CachedDiagramsValue
        ElementListRegistry slreportgen.webview.internal.ElementListRegistry
    end

    properties ( Access = private )
        IsBuiltWithLibrariesLoaded logical = true;
        IsBuiltWithCacheEnabled logical = false;
    end

    properties ( Constant, Access = private )
        LOAD_REFERENCED_MODEL_TYPE int8 = 1;
        LOAD_REFERENCED_SUBSYSTEM_TYPE int8 = 2;
    end

    methods
        function out = get.Diagrams( this )
            out = this.diagrams(  );
        end

        function out = handle( this )


            out = this.RootDiagram.handle(  );
        end

        function out = paths( this )



            n = numel( this.Diagrams );
            out = string.empty( 0, n );
            for i = 1:n
                out( i ) = this.Diagrams( i ).path(  );
            end
        end

        function out = resolveDiagram( this, name )









            out = slreportgen.webview.internal.Diagram.empty(  );
            if ( ischar( name ) || isstring( name ) )
                if slreportgen.utils.isSID( name )
                    out = this.queryDiagrams( SID = name, Count = 1 );
                else

                    out = this.queryDiagrams( FullName = name, Count = 1 );


                    if isempty( out )
                        out = this.queryDiagrams( path = name, Count = 1 );
                    end
                end
            else
                try
                    sysH = slreportgen.utils.getSlSfHandle( name );
                    out = this.queryDiagrams( handle = sysH, Count = 1 );
                catch
                end
            end
        end

        function out = queryDiagrams( this, varargin )












            out = slreportgen.webview.internal.query( this.Diagrams, varargin{ : } );
        end

        function loadReferencedModels( this, options )





            arguments
                this
                options.Force logical = false
            end
            if ( this.HasReferencedModels && ~this.IsReferencedModelLoaded )
                this.loadReferences( this.LOAD_REFERENCED_MODEL_TYPE, options );
                this.IsReferencedModelLoaded = true;
            end
        end

        function loadReferencedSubsystems( this, options )





            arguments
                this
                options.Force logical = false
            end
            if ( this.HasReferencedSubsystems && ~this.IsReferencedSubsystemsLoaded )
                this.loadReferences( this.LOAD_REFERENCED_SUBSYSTEM_TYPE, options );
                this.IsReferencedSubsystemsLoaded = true;
            end
        end
    end

    methods ( Hidden )
        function tf = isBuiltWithLibrariesLoaded( this )
            tf = this.IsBuiltWithLibrariesLoaded;
        end

        function tf = isBuiltWithCacheEnabled( this )
            tf = this.IsBuiltWithCacheEnabled;
        end
    end

    methods ( Access = {  ...
            ?slreportgen.webview.internal.Diagram,  ...
            ?slreportgen.webview.internal.ModelBuilder,  ...
            ?slreportgen.webview.internal.ReferenceDiagramInterface } )
        function addDiagram( this, ~ )
            this.DiagramCount = this.DiagramCount + 1;
            this.CachedDiagramsValue = slreportgen.webview.internal.Diagram.empty(  );
        end

        function addPart( this, part )
            this.Parts( end  + 1 ) = part;
        end
    end

    methods ( Access = ?slreportgen.webview.internal.ReferenceDiagramInterface )
        function setHasReferencedModels( this, value )
            this.HasReferencedModels = value;
        end

        function setHasReferencedSubsystems( this, value )
            this.HasReferencedSubsystems = value;
        end
    end

    methods ( Access = ?slreportgen.webview.internal.Diagram )
        function out = getElementList( this, diagram )
            out = this.ElementListRegistry.get( diagram );
        end

        function loadElementHandles( this, diagram )
            this.ElementListRegistry.loadElementHandles( diagram );
        end

        function buildElementList( this, diagram, options )
            arguments
                this
                diagram
                options.SlProxyObjects = [  ]
            end
            this.ElementListRegistry.build( diagram, options.SlProxyObjects );
        end
    end

    methods ( Access = ?slreportgen.webview.internal.ModelBuilder )
        function this = Model(  )
            this.ElementListRegistry = slreportgen.webview.internal.ElementListRegistry(  );
        end

        function setRootDiagram( this, diagram )
            this.RootDiagram = diagram;
            this.Name = diagram.Name;
        end

        function setIsBuiltWithLibrariesLoaded( this, value )
            this.IsBuiltWithLibrariesLoaded = value;
        end

        function setIsBuiltWithCacheEnabled( this, value )
            this.IsBuiltWithCacheEnabled = value;
        end

        function setNotes( this, value )
            if ( strlength( value ) == 0 )
                this.Notes = string.empty(  );
            else
                this.Notes = value;
            end
        end
    end

    methods ( Access = private )
        function out = diagrams( this )


            if isempty( this.CachedDiagramsValue )
                out = slreportgen.webview.internal.Diagram.empty( 0, this.DiagramCount );
                it = slreportgen.webview.internal.DiagramIterator( this );
                count = 0;
                while it.hasNext(  )
                    count = count + 1;
                    diagram = it.next(  );






                    out( count ) = diagram;
                end
                assert( this.DiagramCount == count );
                this.CachedDiagramsValue = out;
            end
            out = this.CachedDiagramsValue;
        end

        function loadReferences( this, type, options )
            diagramsToLoad = this.Diagrams;
            while ~isempty( diagramsToLoad )
                nNextDiagramsToLoad = 0;
                nDiagramsToLoad = numel( diagramsToLoad );
                nextDiagramsToLoad = cell( 1, nDiagramsToLoad );
                for i = 1:nDiagramsToLoad
                    diagram = diagramsToLoad( i );

                    if ( type == this.LOAD_REFERENCED_MODEL_TYPE )
                        refDiagrams = diagram.loadReferencedModels( "Force", options.Force );
                    else
                        refDiagrams = diagram.loadReferencedSubsystems( "Force", options.Force );
                    end

                    nRefDiagrams = numel( refDiagrams );
                    refDiagramsToLoad = cell( 1, nRefDiagrams );
                    for j = 1:nRefDiagrams
                        refDiagramsToLoad{ j } = [ refDiagrams, refDiagrams( j ).descendants ];
                        nNextDiagramsToLoad = nNextDiagramsToLoad + numel( refDiagramsToLoad{ j } );
                    end
                    nextDiagramsToLoad{ i } = refDiagramsToLoad;
                end

                diagramsToLoad = slreportgen.webview.internal.Diagram.empty( 0, nNextDiagramsToLoad );

                idx = 0;
                for i = 1:nDiagramsToLoad
                    for j = 1:numel( nextDiagramsToLoad{ i } )
                        nextDiagrams = nextDiagramsToLoad{ i }{ j };
                        for k = 1:numel( nextDiagrams )
                            idx = idx + 1;
                            diagramsToLoad( idx ) = nextDiagrams( k );
                        end
                    end
                end
            end
        end
    end
end

