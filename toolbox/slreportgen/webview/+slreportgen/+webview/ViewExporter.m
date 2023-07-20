classdef ViewExporter<handle&matlab.mixin.Heterogeneous








    properties
        InformerDataExporter;
        InspectorDataExporter;
        ObjectViewerDataExporter;
        ViewerDataExporter;
        FinderDataExporter;
    end

    properties(SetAccess=protected)
        ProgressMonitor;

        BaseName='';
        BaseUrl='';
        BaseDir='';
    end

    properties(SetAccess=protected,Dependent)
        HomeSystem;
        Model;
    end

    properties(Access=private)
        SupportFiles string
        SupportPaths string

        ModelSource=[]
        HomeSystemSource=[]
    end


    methods(Access=public,Static)
        function obj=getDefaultObject
            obj=ViewExporter();
        end
    end

    methods
        function this=ViewExporter()
            this.ProgressMonitor=slreportgen.webview.ProgressMonitor();
        end

        function tf=isEnabled(~)
            tf=true;
        end

        function addFile(this,file,path,varargin)
            if(nargin<3)
                [~,fName,fExt]=fileparts(file);
                path=strcat(this.BaseUrl,'/',fName,fExt);
            end

            this.SupportFiles=[this.SupportFiles,file];
            this.SupportPaths=[this.SupportPaths,path];
        end

        function objBaseName=getObjectBaseName(this,obj)
            objId=strrep(getObjectId(obj),':','_');
            objBaseName=fullfile(this.BaseDir,objId);
        end

        function objBaseUrl=getObjectBaseUrl(this,obj)
            objId=strrep(getObjectId(obj),':','_');
            objBaseUrl=[this.BaseUrl,'/',objId];
        end

        function preExport(this,varargin)


            baseName=this.BaseName;
            if isempty(baseName)
                this.BaseDir=char(this.SupportFolder);
                this.BaseUrl=char(this.SupportPath);
            else
                this.BaseDir=char(fullfile(this.SupportFolder,baseName));
                this.BaseUrl=char(strcat(this.SupportPath,'/',baseName));
            end

            baseDir=this.BaseDir;
            if~exist(baseDir,'dir')
                mkdir(baseDir)
            end
        end

        function preExportDataExporters(this)
            if~isempty(this.InspectorDataExporter)
                preExport(this.InspectorDataExporter,this);
            end
            if~isempty(this.ViewerDataExporter)
                preExport(this.ViewerDataExporter,this);
            end
            if~isempty(this.InformerDataExporter)
                preExport(this.InformerDataExporter,this);
            end
            if~isempty(this.ObjectViewerDataExporter)
                preExport(this.ObjectViewerDataExporter,this);
            end
            if~isempty(this.FinderDataExporter)
                preExport(this.FinderDataExporter,this);
            end
        end

        function export(this,writer,obj)






            if~isempty(this.InspectorDataExporter)
                writer.name('inspector');
                writer.value(export(this.InspectorDataExporter,obj));
            end

            if~isempty(this.InformerDataExporter)
                writer.name('informer');
                writer.value(export(this.InformerDataExporter,obj));
            end

            if~isempty(this.ViewerDataExporter)
                writer.name('viewer');
                writer.value(export(this.ViewerDataExporter,obj));
            end

            if~isempty(this.ObjectViewerDataExporter)
                writer.name('obj_viewer');
                writer.value(export(this.ObjectViewerDataExporter,obj));
            end

            if~isempty(this.FinderDataExporter)
                writer.name('finder');
                writer.value(export(this.FinderDataExporter,obj));
            end
        end

        function postExport(this)

            this.Model=[];
            this.HomeSystem=[];
            this.BaseDir='';
            this.BaseUrl='';
        end

        function postExportDataExporters(this)
            if~isempty(this.InspectorDataExporter)
                postExport(this.InspectorDataExporter);
            end
            if~isempty(this.ViewerDataExporter)
                postExport(this.ViewerDataExporter);
            end
            if~isempty(this.InformerDataExporter)
                postExport(this.InformerDataExporter);
            end
            if~isempty(this.ObjectViewerDataExporter)
                postExport(this.ObjectViewerDataExporter);
            end
            if~isempty(this.FinderDataExporter)
                postExport(this.FinderDataExporter);
            end
        end

        function tf=isSystemView(this)
            tf=this.IsSystemView;
        end

        function[files,paths]=supportFiles(this)
            files=this.SupportFiles;
            paths=this.SupportPaths;
        end

        function resetSupportFiles(this)
            this.SupportFiles=[];
            this.SupportPaths=[];
        end

        function set.Model(this,value)
            this.ModelSource=value;
        end

        function set.HomeSystem(this,value)
            this.HomeSystemSource=value;
        end

        function out=get.Model(this)
            if isa(this.ModelSource,"slreportgen.webview.internal.Model")
                out=this.ModelSource.RootDiagram.handle();
            else
                out=this.ModelSource;
            end
        end

        function out=get.HomeSystem(this)
            if isa(this.HomeSystemSource,"slreportgen.webview.internal.Diagram")
                out=this.HomeSystemSource.handle();
            else
                out=this.HomeSystemSource;
            end
        end
    end

    properties(Access=private)
        IsSystemView logical=false
        SupportFolder string
        SupportPath string
    end

    methods
        function out=supportFolder(this)
            out=this.SupportFolder;
        end

        function out=supportPath(this)
            out=this.SupportPath;
        end
    end

    methods(Hidden)
        function tf=isCacheEnabled(h)
            tf=false;
        end
    end

    methods(Access={?slreportgen.webview.ModelExporter,?slreportgen.webview.internal.ExportDirector})
        function setModel(this,value)
            this.ModelSource=value;
        end

        function setHomeSystem(this,value)
            this.HomeSystemSource=value;
        end

        function setSupportFolder(this,value)
            this.SupportFolder=value;
        end

        function setSupportPath(this,value)
            this.SupportPath=value;
        end

        function setIsSystemView(this,value)
            this.IsSystemView=value;
        end
    end
end

function id=getObjectId(obj)
    if isa(obj,'slreportgen.webview.SlProxyObject')
        id=getId(obj);
    else
        slobj=slreportgen.webview.SlProxyObject(obj);
        id=getId(slobj);
    end
end

