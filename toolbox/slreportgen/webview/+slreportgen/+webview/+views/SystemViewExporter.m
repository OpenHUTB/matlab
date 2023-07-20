classdef SystemViewExporter<slreportgen.webview.ViewExporter



    properties
        Id='sys'
Name
Icon
    end

    methods

        function this=SystemViewExporter
            this.InspectorDataExporter=slreportgen.webview.InspectorDataExporter();
            this.InformerDataExporter=[];
            this.ObjectViewerDataExporter=slreportgen.webview.ObjectViewerDataExporter();
            this.ViewerDataExporter=slreportgen.webview.ViewerDataExporter();
            this.FinderDataExporter=slreportgen.webview.FinderDataExporter();
        end

        function tf=isCacheEnabled(~)
            tf=true;
        end
    end
end