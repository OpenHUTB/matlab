classdef BackingExporter<slreportgen.webview.internal.ExporterInterface



















    properties(Access=private)
        DiagramBackingExporter slreportgen.webview.internal.DiagramBackingExporter
        ElementBackingExporter slreportgen.webview.internal.ElementBackingExporter

        PreExportProgressMonitor slreportgen.webview.ProgressMonitor;
        PostExportProgressMonitor slreportgen.webview.ProgressMonitor;
    end

    methods
        function this=BackingExporter(director)
            this=this@slreportgen.webview.internal.ExporterInterface(director);
            this.DiagramBackingExporter=slreportgen.webview.internal.DiagramBackingExporter(director);
            this.ElementBackingExporter=slreportgen.webview.internal.ElementBackingExporter(director);

            this.ProgressMonitor.setMaxValue(0);
            this.PreExportProgressMonitor=slreportgen.webview.ProgressMonitor(0,1);
            this.PostExportProgressMonitor=slreportgen.webview.ProgressMonitor(0,1);
            this.ProgressMonitor.addChild(this.PreExportProgressMonitor,2);
            this.ProgressMonitor.addChild(this.DiagramBackingExporter.ProgressMonitor,7);
            this.ProgressMonitor.addChild(this.ElementBackingExporter.ProgressMonitor,90);
            this.ProgressMonitor.addChild(this.PostExportProgressMonitor,1);
        end

        function export(this)




            this.DiagramBackingExporter.export();
            this.ElementBackingExporter.export();
        end

        function preExport(this)



            views=this.views();
            nViews=numel(views);
            for iView=1:nViews
                if this.ProgressMonitor.isCanceled()
                    return
                end
                view=views(iView);
                view.preExport();
                view.preExportDataExporters();
                [viewSupportFilePaths,viewSupportPackagePaths]=view.supportFiles();
                for j=1:numel(viewSupportFilePaths)
                    this.addFile(viewSupportFilePaths(j),viewSupportPackagePaths(j));
                end
                view.resetSupportFiles();
                this.PreExportProgressMonitor.setValue(iView/nViews);
            end

            if this.ProgressMonitor.isCanceled()
                return
            end
            this.DiagramBackingExporter.preExport();
            this.ElementBackingExporter.preExport();
        end

        function postExport(this)



            views=this.views();
            nViews=numel(views);
            for iView=1:nViews
                if this.ProgressMonitor.isCanceled()
                    return
                end
                view=views(iView);
                view.postExport();
                view.postExportDataExporters();
                [viewSupportFilePaths,viewSupportPackagePaths]=view.supportFiles();
                for iFilePaths=1:numel(viewSupportFilePaths)
                    this.addFile(viewSupportFilePaths(iFilePaths),viewSupportPackagePaths(iFilePaths));
                end
                view.resetSupportFiles();
                this.PostExportProgressMonitor.setValue(iView/nViews);
            end

            if this.ProgressMonitor.isCanceled()
                return
            end
            this.DiagramBackingExporter.postExport();
            this.ElementBackingExporter.postExport();
        end
    end
end
