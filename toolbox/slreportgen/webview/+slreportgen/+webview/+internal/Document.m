classdef Document < slreportgen.webview.DocumentBase



































    properties


        Project slreportgen.webview.internal.Project



        HomeDiagram slreportgen.webview.internal.Diagram




        SystemView slreportgen.webview.ViewExporter




        OptionalViews slreportgen.webview.ViewExporter


        IncludeNotes logical = false;


        IncrementalExport logical = false;
    end

    properties ( Constant, Access = private )
        WebAppID string = "slwebview";
        TargetPackagePath string = "support/slwebview.json";
        SupportPackagePath string = "support/slwebview_files";
    end

    methods
        function this = Document( outputFileName, packageType )
            arguments
                outputFileName string
                packageType string
            end
            this@slreportgen.webview.DocumentBase( outputFileName );
            this.PackageType = packageType;
            this.SystemView = slreportgen.webview.views.SystemViewExporter;
        end

        function fillslwebview( this )
            modelElement = slreportgen.webview.ModelElement( this,  ...
                char( this.WebAppID ),  ...
                '100%',  ...
                '100%',  ...
                char( this.TargetPackagePath ) );
            this.append( modelElement.createDomElement(  ) );

            director = slreportgen.webview.internal.ExportDirector(  );
            director.Project = this.Project;
            director.HomeDiagram = this.HomeDiagram;
            director.SystemView = this.SystemView;
            director.OptionalViews = this.OptionalViews;
            director.TargetPackagePath = this.TargetPackagePath;
            director.SupportPackagePath = this.SupportPackagePath;
            director.IncludeNotes = this.IncludeNotes;
            director.Cache = this.IncrementalExport;
            director.Indent = 1;


            this.ProgressMonitor.setMaxValue( 0 );
            this.ProgressMonitor.addChild( director.ProgressMonitor );

            director.export( this );
        end
    end
end

