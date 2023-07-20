classdef HTMXDoc<handle



















    properties(SetAccess=private)
        FileName=string.empty();
    end

    properties(Constant,Hidden)
        FileExtensions=[".htmx",".zip",".htmtx",".pdftx"];
    end

    properties(Constant,Access=private)
        ConnectorAddOnName="mlreportgenhtmtxviewer";
        ConnectorAddOnPath=fullfile(tempdir,"mlreportgen_htmtxviewer");
    end

    properties(Access=private)
        Impl=[];
        ExpandedFolder=string.empty();
    end

    methods
        function this=HTMXDoc(fileName)
            filePath=char(mlreportgen.utils.findFile(...
            fileName,...
            "FileExtensions",this.FileExtensions));

            if isempty(filePath)
                error(message("mlreportgen:utils:error:fileNotFound",fileName));
            end
            this.FileName=filePath;

            [~,~,fExt]=fileparts(filePath);
            if~ismember(fExt,this.FileExtensions)
                error(message("mlreportgen:utils:error:unexpectedFileType",...
                fileName,strjoin(this.FileExtensions," ")));
            end


            namePart=this.getMainPart(this.FileName);
            this.ExpandedFolder=tempname(char(this.ConnectorAddOnPath));
            mkdir(this.ExpandedFolder);
            unzip(this.FileName,this.ExpandedFolder);
            expandedFilePath=fullfile(this.ExpandedFolder,namePart);


            connector.ensureServiceOn();
            connector.addWebAddOnsPath(this.ConnectorAddOnName,this.ConnectorAddOnPath);


            addOnBaseURL=connector.getBaseUrl()+"addons/"+this.ConnectorAddOnName+"/";
            url=regexprep(...
            mlreportgen.utils.fileToURI(expandedFilePath),...
            mlreportgen.utils.fileToURI(this.ConnectorAddOnPath),...
            addOnBaseURL);

            this.Impl=mlreportgen.utils.internal.MATLABWebBrowser(...
            url,...
            "ShowAddressBox",false);
        end

        function delete(this)
            try
                cleanup(this);
                delete(this.Impl);
            catch
            end
        end

        function show(this)


            show(this.Impl);
        end

        function hide(this)


            hide(this.Impl);
        end

        function tf=isVisible(this)



            tf=~isempty(this.Impl)&&isVisible(this.Impl);
        end

        function tf=close(this)



            tf=close(this.Impl);
            cleanup(this);
        end

        function tf=isOpen(this)



            tf=~isempty(this.Impl)&&isOpen(this.Impl);
        end
    end

    methods(Access=private)
        function cleanup(this)
            if~isempty(this.ExpandedFolder)&&isfolder(this.ExpandedFolder)
                rmdir(this.ExpandedFolder,'s');
            end

            if(~isempty(this.ExpandedFolder)...
                &&isfolder(this.ConnectorAddOnPath)...
                &&(numel(dir(this.ConnectorAddOnPath))<=2))
                rmdir(this.ConnectorAddOnPath);
            end
        end
    end

    methods(Static,Hidden)
        function mainPart=getMainPart(fileName)
            try
                mainPart=mlreportgen.dom.Document.getOPCMainPart(fileName,"html");
            catch ME
                error(message("mlreportgen:utils:error:invalidReportPackage",fileName,ME.message));
            end
        end
    end
end
