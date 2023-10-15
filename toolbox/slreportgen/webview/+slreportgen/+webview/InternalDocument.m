classdef InternalDocument < slreportgen.webview.DocumentBase

    properties
        InitialBlock;
        HomeSystem;
        Systems;
        SystemView;
        OptionalViews;
        IncludeNotes logical = false;
        IncrementalExport logical = false;
    end

    properties ( Constant, Access = private )
        TargetPackagePath string = "support/slwebview.json";
        SupportPackagePath string = "support/slwebview_files";
    end

    methods
        function this = InternalDocument( outputFileName, packageType )
            arguments
                outputFileName string
                packageType string
            end
            this@slreportgen.webview.DocumentBase( outputFileName );

            this.PackageType = packageType;


            this.TemplatePath = fullfile( slreportgen.webview.TemplatesDir, 'slwebview.htmtx' );
        end

        function fillslwebview( this )
            modelElement = slreportgen.webview.ModelElement( this,  ...
                'slwebview',  ...
                '100%',  ...
                '100%',  ...
                char( this.TargetPackagePath ) );

            append( this, createDomElement( modelElement ) );

            if ( slreportgen.webview.internal.version(  ) == 3 )
                this.exportVersion3(  );
            else
                this.exportVersion2( modelElement );
            end
        end

    end

    methods ( Access = private )
        function exportVersion2( this, modelElement )

            modelExporter = slreportgen.webview.ModelExporter( modelElement );


            modelExporter.IncludeNotes = this.IncludeNotes;


            if ~isempty( this.SystemView )
                modelExporter.SystemView = this.SystemView;
            end


            modelExporter.OptionalViews = this.OptionalViews;


            addChild( this.ProgressMonitor, modelExporter.ProgressMonitor );


            export( modelExporter, this.Systems, this.HomeSystem, this.InitialBlock );
        end

        function exportVersion3( this )
            project = this.createProject(  );

            director = slreportgen.webview.internal.ExportDirector(  );
            director.Project = project;
            director.TargetPackagePath = this.TargetPackagePath;
            director.SupportPackagePath = this.SupportPackagePath;
            director.Indent = 1;
            director.IncludeNotes = this.IncludeNotes;
            director.Cache = this.IncrementalExport;


            if isempty( this.SystemView )
                systemView = slreportgen.webview.views.SystemViewExporter(  );
            elseif strcmp( class( this.SystemView ), "slreportgen.webview.ViewExporter" )
                systemView = slreportgen.webview.views.SystemViewExporter(  );
                systemView.InspectorDataExporter = this.SystemView.InspectorDataExporter;
                systemView.InformerDataExporter = this.SystemView.InformerDataExporter;
                systemView.ObjectViewerDataExporter = this.SystemView.ObjectViewerDataExporter;
                systemView.ViewerDataExporter = this.SystemView.ViewerDataExporter;
                systemView.FinderDataExporter = this.SystemView.FinderDataExporter;
            else
                systemView = this.SystemView;
            end
            director.SystemView = systemView;

            if iscell( this.OptionalViews )
                director.OptionalViews = [ this.OptionalViews{ : } ];
            else
                director.OptionalViews = this.OptionalViews;
            end


            this.ProgressMonitor.addChild( director.ProgressMonitor );

            director.export( this );
        end


        function project = createProject( this )
            builder = slreportgen.webview.internal.ProjectBuilder( Cache = this.IncrementalExport );
            systems = this.Systems;

            if ischar( systems )
                systems = string( systems );
            elseif isa( systems, "slreportgen.webview.ModelHierarchy" )
                systems = systems.getAllItemPaths(  );
            end

            for i = 1:numel( systems )
                if iscell( systems )
                    builder.add( systems{ i } );
                else
                    builder.add( systems( i ) );
                end
            end
            project = builder.build(  );
        end
    end
end


