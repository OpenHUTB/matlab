classdef(Abstract)ReportType<handle






    properties(Hidden,Constant)
        GENERIC_FILE_CATEGORY='Code_Generation_Report'
        DEFAULT_PAGE='toolbox/coder/coder/web/reportviewer/index.html'
        DEFAULT_DEBUG_PAGE='toolbox/coder/coder/web/reportviewer/index-debug.html'
    end

    properties(Abstract,Constant)


ClientTypeValue



FileCategory
    end

    properties(SetAccess=protected)

        AppendFilePathToTitle logical=true

        Priority=0


        MapFilePath=''

        MainDocTopic='help_button_compilation_report_emlc'

        BaseProducts={}
    end

    methods(Abstract)



        matched=isType(this,reportContext)



        title=getWindowTitle(this,reportManifest)
    end

    methods
        function customArgs=getReportViewerArgs(this)%#ok<MANU>


            customArgs={};
        end

        function checkRequiredLicenses(this,reportManifest)%#ok<*INUSD>



        end

        function page=getRootPage(this,debug)

            if~debug
                page=this.DEFAULT_PAGE;
            else
                page=this.DEFAULT_DEBUG_PAGE;
            end
        end

        function desc=getFileDescription(this,contribContext)


            epNames=this.getEntryPointNames(contribContext);
            if~isempty(epNames)
                desc=strrep(this.FileCategory,'_',' ');
                desc=sprintf('%s - %s',desc,strjoin(epNames,', '));
            else
                desc='';
            end
        end

        function[mapPath,anchorId]=resolveDocPage(this,manifest,anchorId)
            if~isempty(this.MapFilePath)&&exist(this.MapFilePath,'file')
                mapPath=this.MapFilePath;
            else
                mapPath='';
            end
            if nargin<3||isempty(anchorId)
                anchorId=this.MainDocTopic;
            end
        end

        function products=getProductsUsed(this,reportContext)
            products=this.BaseProducts;
        end

        function yes=canHaveMainDocTopic(~)
            yes=true;
        end
    end

    methods
        function set.BaseProducts(this,baseProducts)
            if ischar(baseProducts)
                this.BaseProducts={baseProducts};
            else
                this.BaseProducts=baseProducts;
            end
        end

        function set.MapFilePath(this,path)
            curDocRoot=docroot();
            if startsWith(path,curDocRoot)
                path=path(numel(curDocRoot)+1:end);
            end
            this.MapFilePath=path;
        end

        function path=get.MapFilePath(this)
            if~isempty(this.MapFilePath)

                path=fullfile(docroot(),this.MapFilePath);
            else
                path='';
            end
        end
    end

    methods(Static,Access=protected)
        function title=getDefaultWindowTitle()
            title=message('coderWeb:matlab:browserTitleGeneric').getString();
        end

        function epNames=getEntryPointNames(contribContext)
            if~isempty(contribContext.ReportContext.CoderProject)
                epNames={contribContext.ReportContext.CoderProject.EntryPoints.Name};
            else
                epNames={};
            end
            if isempty(epNames)
                if~isfield(contribContext.ReportContext.Report,'inference')||...
                    isempty(contribContext.ReportContext.Report.inference)
                    return;
                end
                inference=contribContext.ReportContext.Report.inference;
                if~isfield(inference,'RootFunctionIDs')||isempty(inference.RootFunctionIDs)
                    return;
                end
                rootIds=inference.RootFunctionIDs(ismember(inference.RootFunctionIDs,...
                contribContext.IncludedFunctionIds));
                if isempty(rootIds)
                    return;
                end
                rootScriptIds=[inference.Functions(rootIds).ScriptID];
                rootScriptIds=unique(rootScriptIds(rootScriptIds>0));
                epNames={inference.Scripts(rootScriptIds).ScriptName};
            end
        end
    end
end
