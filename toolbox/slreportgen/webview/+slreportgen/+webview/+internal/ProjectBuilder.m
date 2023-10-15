classdef ProjectBuilder < handle
































    properties ( Dependent )

        IncludeMaskedSubsystems


        IncludeSimulinkLibraryLinks


        IncludeUserLibraryLinks


        IncludeReferencedModels




        CurrentAndBelowCallback
    end

    properties ( SetAccess = private )
        Cache logical;
    end

    properties ( Access = private )
        Selector slreportgen.webview.internal.DiagramSelector
        Result slreportgen.webview.internal.Project
        ModelBuilder slreportgen.webview.internal.ModelBuilder
        ModelNamePattern = regexpPattern( '/|:' );
    end

    methods
        function this = ProjectBuilder( options )
            arguments
                options.Cache logical = true
            end
            this.ModelBuilder = slreportgen.webview.internal.ModelBuilder(  );
            this.Selector = slreportgen.webview.internal.DiagramSelector(  );
            this.Result = slreportgen.webview.internal.Project(  );
            this.Cache = options.Cache;
        end

        function out = get.IncludeMaskedSubsystems( this )
            out = this.Selector.IncludeMaskedSubsystems;
        end
        function set.IncludeMaskedSubsystems( this, value )
            this.Selector.IncludeMaskedSubsystems = value;
        end

        function out = get.IncludeSimulinkLibraryLinks( this )
            out = this.Selector.IncludeSimulinkLibraryLinks;
        end
        function set.IncludeSimulinkLibraryLinks( this, value )
            this.Selector.IncludeSimulinkLibraryLinks = value;
        end

        function out = get.IncludeUserLibraryLinks( this )
            out = this.Selector.IncludeUserLibraryLinks;
        end
        function set.IncludeUserLibraryLinks( this, value )
            this.Selector.IncludeUserLibraryLinks = value;
        end

        function out = get.IncludeReferencedModels( this )
            out = this.Selector.IncludeReferencedModels;
        end
        function set.IncludeReferencedModels( this, value )
            this.Selector.IncludeReferencedModels = value;
        end

        function out = get.CurrentAndBelowCallback( this )
            out = this.Selector.TraversalCallback;
        end
        function set.CurrentAndBelowCallback( this, value )
            this.Selector.TraversalCallback = value;
        end

        function add( this, sys )



            diagram = this.getCreateDiagram( sys );
            this.Selector.Scope = "Current";
            this.Selector.select( diagram );
        end

        function addAll( this, sys )




            diagram = this.getCreateDiagram( sys );
            this.Selector.Scope = "CurrentAndBelow";
            this.Selector.select( diagram.Model.RootDiagram );
        end

        function addDown( this, sys )





            diagram = this.getCreateDiagram( sys );
            this.Selector.Scope = "CurrentAndBelow";
            this.Selector.select( diagram );
        end

        function addUp( this, sys )



            diagram = this.getCreateDiagram( sys );
            this.Selector.Scope = "CurrentAndAbove";
            this.Selector.select( diagram );
        end

        function out = build( this )



            out = this.Result;
            this.Result = slreportgen.webview.internal.Project(  );
        end

        function out = paths( this )



            out = this.Selector.getSelectedPaths( this.Result.Models );
        end
    end

    methods ( Access = private )
        function out = getCreateDiagram( this, sys )
            prj = this.Result;
            out = prj.resolveDiagram( sys );
            if isempty( out )
                if ( ischar( sys ) || isstring( sys ) )
                    modelName = this.extractModelName( sys );
                else
                    modelH = slreportgen.utils.getModelHandle( sys );
                    modelName = get_param( modelH, "Name" );
                end
                model = this.ModelBuilder.build( modelName, Cache = this.Cache );
                model.loadReferencedSubsystems(  );
                this.Selector.unselectAll( model );

                prj.addModel( model );
                out = model.resolveDiagram( sys );
            end

        end

        function modelName = extractModelName( this, name )
            arguments
                this
                name string
            end

            modelName = extractBefore( name, this.ModelNamePattern );
            if isempty( modelName ) || ismissing( modelName )
                modelName = name;
            end
        end
    end
end


