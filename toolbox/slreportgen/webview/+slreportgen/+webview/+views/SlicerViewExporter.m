classdef SlicerViewExporter<slreportgen.webview.views.OptionalViewExporter






    properties
        HighlightBeforeExport=false;
    end

    methods
        function h=SlicerViewExporter()
            h=h@slreportgen.webview.views.OptionalViewExporter();
            h.Id='modelslicer';
            h.Name='Model Slicer';
            h.InformerDataExporter=slreportgen.webview.views.SlicerDataExporter();
            h.ViewerDataExporter=slreportgen.webview.ViewerDataExporter();
            h.FinderDataExporter=slreportgen.webview.FinderDataExporter();
        end

        function tf=isWidgetVisible(h)%#ok
            tf=license('test','Simulink_Design_Verifier');
        end

        function tf=isWidgetEnabled(h)%#ok
            tf=true;
        end

        function preExport(h,varargin)
            preExport@slreportgen.webview.views.OptionalViewExporter(h,varargin{:});
        end
    end
end
