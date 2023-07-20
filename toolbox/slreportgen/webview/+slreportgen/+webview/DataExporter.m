classdef DataExporter<slreportgen.webview.Dispatcher









    properties(SetAccess=protected)
        ViewExporter=[];
        BaseUrl='';
        BaseDir='';
    end

    properties(Dependent)
HomeSystem
Model
    end

    methods
        function h=DataExporter()
        end

        function out=get.HomeSystem(h)


            if~isempty(h.ViewExporter)
                out=h.ViewExporter.HomeSystem;
            else
                out=[];
            end
        end

        function out=get.Model(h)


            if~isempty(h.ViewExporter)
                out=h.ViewExporter.Model;
            else
                out=[];
            end
        end

        function addFile(h,varargin)
            addFile(h.ViewExporter,varargin{:});
        end

        function objBaseName=getObjectBaseName(h,obj)
            objBaseName=getObjectBaseName(h.ViewExporter,obj);
        end

        function objBaseUrl=getObjectBaseUrl(h,obj)
            objBaseUrl=getObjectBaseUrl(h.ViewExporter,obj);
        end

        function preExport(h,viewExporter)
            h.ViewExporter=viewExporter;
            h.BaseDir=viewExporter.BaseDir;
            h.BaseUrl=viewExporter.BaseUrl;
        end

        function data=export(h,obj)
            if~isa(obj,'slreportgen.webview.SlProxyObject')
                slpobj=slreportgen.webview.SlProxyObject(obj);
            else
                slpobj=obj;
            end
            data=dispatch(h,slpobj);
        end

        function data=noExport(h,obj)%#ok
            data=[];
        end

        function postExport(h)
            h.ViewExporter=[];
            h.BaseUrl='';
            h.BaseDir='';
        end
    end

end
