classdef ExportDirector<handle































    properties

        Project slreportgen.webview.internal.Project


        HomeDiagram slreportgen.webview.internal.Diagram


        SystemView slreportgen.webview.ViewExporter


OptionalViews


        IncludeNotes logical=false;


        TargetPackagePath string="support/slwebview.json"


        SupportPackagePath string="support/slwebview_files"


        Indent=0;


        Cache logical=false;
    end

    properties(SetAccess=private)



        ProgressMonitor slreportgen.webview.ProgressMonitor
    end

    properties(Access=private)
Document
        SupportFolderPath string
WarningBacktraceStatus

        IsExportComplete logical
        IsCacheEnabled logical
EnabledViewCacheValue
EnabledOptionalViewsCacheValue
        ModelCaches struct
    end

    methods
        function this=ExportDirector()

            this.ProgressMonitor=slreportgen.webview.ProgressMonitor(0,0);
        end

        function export(this,document)





            cleanup=this.prepare(document);
            this.IsExportComplete=false;


            hierarchyExporter=slreportgen.webview.internal.HierarchyExporter(this);
            hierarchyExporter.TargetPackagePath=this.TargetPackagePath;
            hierarchyExporter.TargetFilePath=fullfile(this.Document.WorkingDir,this.TargetPackagePath);
            graphicsExporter=slreportgen.webview.internal.GraphicsExporter(this);
            backingExporter=slreportgen.webview.internal.BackingExporter(this);
            iconsExporter=slreportgen.webview.internal.IconExporter(this);
            notesExporter=slreportgen.webview.internal.NotesExporter(this);
            notesExporter.Enabled=this.IncludeNotes;


            pm=this.ProgressMonitor;
            pm.addChild(graphicsExporter.ProgressMonitor,4);
            pm.addChild(backingExporter.ProgressMonitor,4);
            pm.addChild(iconsExporter.ProgressMonitor,1);
            pm.addChild(notesExporter.ProgressMonitor,1*notesExporter.Enabled);
            pm.addChild(hierarchyExporter.ProgressMonitor,1);


            exporters={...
            graphicsExporter,...
            backingExporter,...
            iconsExporter,...
            notesExporter,...
hierarchyExporter
            };

            nExporters=numel(exporters);
            for i=1:nExporters
                exporter=exporters{i};
                if(exporter.Enabled&&~this.ProgressMonitor.isCanceled())
                    exporter.preExport();
                end
            end
            for i=1:nExporters
                exporter=exporters{i};
                if(exporter.Enabled&&~this.ProgressMonitor.isCanceled())
                    exporter.export();
                end
            end
            for i=1:nExporters
                exporter=exporters{i};
                if(exporter.Enabled&&~this.ProgressMonitor.isCanceled())
                    exporter.postExport();
                end
            end


            this.IsExportComplete=true;
            delete(cleanup);
        end

        function set.SupportPackagePath(this,value)
            if value.endsWith("/")||value.endsWith("\")
                value=value.extractBefore(strlength(value));
            end
            this.SupportPackagePath=value;
        end
    end

    methods(Access=?slreportgen.webview.internal.ExporterInterface)
        function addFile(this,filePath,packagePath)
            this.Document.addFile(filePath,packagePath);
        end

        function out=supportFolderPath(this)
            out=this.SupportFolderPath;
        end

        function out=cache(this,sid)
            if this.isCacheEnabled()
                modelName=sid.extractBefore(":");
                if ismissing(modelName)
                    modelName=sid;
                end

                if~isfield(this.ModelCaches,modelName)
                    cacheManager=slreportgen.webview.internal.CacheManager.instance();
                    if~cacheManager.isOpen()
                        cacheManager.open();
                    end
                    this.ModelCaches.(modelName)=cacheManager.get(modelName);
                end
                out=this.ModelCaches.(modelName);
            else
                out=[];
            end
        end

        function out=enabledViews(this)
            if isempty(this.EnabledViewCacheValue)
                this.EnabledViewCacheValue=[this.SystemView,this.enabledOptionalViews()];
            end
            out=this.EnabledViewCacheValue;
        end

        function out=enabledOptionalViews(this)
            if isempty(this.EnabledOptionalViewsCacheValue)
                nOptionalViews=numel(this.OptionalViews);
                enabledIndex=true(1,nOptionalViews);
                for i=1:nOptionalViews
                    enabledIndex(i)=this.OptionalViews(i).isEnabled();
                end
                this.EnabledOptionalViewsCacheValue=this.OptionalViews(enabledIndex);
            end
            out=this.EnabledOptionalViewsCacheValue;
        end
    end

    methods(Access=private)
        function out=prepare(this,document)

            if~builtin('license','checkout','SIMULINK_Report_Gen')
                error(message('slreportgen_webview:exporter:LicenseCheckoutFailed'));
            end


            this.WarningBacktraceStatus=warning("backtrace","off");


            drawnow();

            this.ModelCaches=struct();


            this.Document=document;


            this.SupportFolderPath=fullfile(document.WorkingDir,this.SupportPackagePath);
            if~isfolder(this.SupportFolderPath)
                mkdir(this.SupportFolderPath);
            end


            project=this.Project;
            progressMonitor=this.ProgressMonitor;
            progressMonitor.setMessage(...
            message('slreportgen_webview:exporter:ExportingSystem',project.Models(1).Name),...
            progressMonitor.ImportantMessagePriority);


            project.ExportData=slreportgen.webview.internal.ProjectExportData(project);
            project.ExportData.BaseURL=this.SupportPackagePath;
            models=project.Models;
            for iModel=1:numel(models)
                model=models(iModel);
                model.ExportData=slreportgen.webview.internal.ModelExportData(model);
            end


            if~isempty(this.HomeDiagram)
                homeDiagram=this.HomeDiagram;
            else
                homeDiagram=project.Models(1).RootDiagram;
            end


            diagrams=project.Diagrams;
            for iDiagram=1:numel(diagrams)
                diagram=diagrams(iDiagram);
                diagram.ExportData=slreportgen.webview.internal.DiagramExportData(diagram);
                diagram.ExportData.ID=iDiagram;
                if diagram.Selected
                    elements=diagram.elements();
                    for iElement=1:numel(elements)
                        element=elements(iElement);
                        if isempty(element.ExportData)
                            element.ExportData=slreportgen.webview.internal.ElementExportData(element);
                        else

                            break;
                        end
                    end
                end
            end
            project.ExportData.HomeHID=homeDiagram.ExportData.ID;



            parts=project.Parts;
            for iPart=1:numel(parts)
                part=parts(iPart);
                part.ExportData=slreportgen.webview.internal.PartExportData(part);
            end



            this.pruneExportHierarchy(homeDiagram);


            this.IsCacheEnabled=[];


            this.EnabledViewCacheValue=[];
            this.EnabledOptionalViewsCacheValue=[];
            views=[this.SystemView,this.OptionalViews];
            for iView=1:numel(views)
                view=views(iView);
                view.setModel(homeDiagram.Model);
                view.setHomeSystem(homeDiagram);
                view.setSupportPath(this.SupportPackagePath);
                view.setSupportFolder(this.supportFolderPath());
            end
            this.SystemView.setIsSystemView(true);


            out=onCleanup(@()this.cleanup());
        end

        function cleanup(this)
            views=[this.SystemView,this.OptionalViews];
            for iView=1:numel(views)
                view=views(iView);
                view.setModel([]);
                view.setHomeSystem([]);
                view.setSupportPath(string.empty());
                view.setSupportFolder(string.empty());
            end
            this.Document=[];
            this.EnabledViewCacheValue=[];
            this.EnabledOptionalViewsCacheValue=[];
            this.IsCacheEnabled=[];


            names=fieldnames(this.ModelCaches);
            canceled=this.ProgressMonitor.isCanceled()||~this.IsExportComplete;
            for iNames=1:numel(names)
                cache=this.ModelCaches.(names{iNames});
                if~isempty(cache)
                    if canceled
                        if cache.isModified()
                            cache.clear();
                        end
                        cache.close(Save=0);
                    else
                        cache.close(Save=cache.isModified());
                    end
                end
            end
            slreportgen.webview.internal.CacheManager.instance().close();
            this.ModelCaches=struct.empty();

            warning(this.WarningBacktraceStatus);
        end

        function tf=isCacheEnabled(this)
            if isempty(this.IsCacheEnabled)
                cacheManager=slreportgen.webview.internal.CacheManager.instance();
                this.IsCacheEnabled=this.Cache...
                &&cacheManager.isEnabled()...
                &&this.SystemView.isCacheEnabled()...
                &&isempty(this.enabledOptionalViews());
            end
            tf=this.IsCacheEnabled;
        end

        function pruneExportHierarchy(this,homeDiagram)
            diagrams=this.Project.Diagrams;




            for i=numel(diagrams):-1:1
                diagram=diagrams(i);

                if diagram.Selected||(diagram==homeDiagram)
                    diagram.ExportData.IsPartOfExportHierarchy=true;
                else

                    diagram.ExportData.IsPartOfExportHierarchy=false;



                    for j=1:numel(diagram.Children)
                        child=diagram.Children(j);

                        if(child.Selected||child.ExportData.IsPartOfExportHierarchy)
                            diagram.ExportData.IsPartOfExportHierarchy=true;
                            break;
                        end
                    end
                end
            end
        end
    end
end
