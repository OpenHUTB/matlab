classdef HTMLDoc<handle



















    properties(SetAccess=private)
        FileName=string.empty();
    end

    properties(Constant,Hidden)
        FileExtensions=[".html",".htm",".htmt"];
    end

    properties(Access=private)
        Impl=[];
        ConnectorAddOnName=string.empty();
    end

    methods
        function this=HTMLDoc(fileName)
            filePath=mlreportgen.utils.findFile(...
            fileName,...
            "FileExtensions",this.FileExtensions);

            if isempty(filePath)
                error(message("mlreportgen:utils:error:fileNotFound",fileName));
            end
            this.FileName=filePath;

            [~,~,fExt]=fileparts(filePath);
            if~ismember(fExt,this.FileExtensions)
                error(message("mlreportgen:utils:error:unexpectedFileType",...
                fileName,strjoin(this.FileExtensions," ")));
            end

            if strcmp(fExt,".htmt")

                url=mlreportgen.utils.fileToURI(filePath);
            else
                url=fileToConnector(this);
            end

            import matlab.internal.lang.capability.Capability;
            if Capability.isSupported(Capability.LocalClient)
                this.Impl=mlreportgen.utils.internal.MATLABWebBrowser(...
                url,...
                "ShowAddressBox",false);
            else

                [~,fName]=fileparts(this.FileName);
                this.Impl=mlreportgen.utils.internal.WebWindow(url,'Title',fName);
            end

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
            pool=this.addOnNamePool();
            if~isempty(this.ConnectorAddOnName)
                key=char(this.ConnectorAddOnName);
                pool(key)=[];%#ok
            end
        end

        function url=fileToConnector(this)
            pool=this.addOnNamePool();


            this.ConnectorAddOnName=string.empty();
            addOnNames=keys(pool);
            n=numel(addOnNames);
            for i=1:n
                key=addOnNames{i};
                if isempty(pool(key))
                    pool(key)=this.FileName;
                    this.ConnectorAddOnName=string(key);
                end
            end

            if isempty(this.ConnectorAddOnName)
                this.ConnectorAddOnName="htmlviewer"+(n+1);
                key=char(this.ConnectorAddOnName);
                pool(key)=this.FileName;%#ok
            end

            [fPath,fName,fExt]=fileparts(this.FileName);

            connector.ensureServiceOn();
            connector.addWebAddOnsPath(this.ConnectorAddOnName,fPath);

            url=connector.getBaseUrl()...
            +"addons/"...
            +this.ConnectorAddOnName+"/"...
            +fName+fExt;
        end
    end

    methods(Static)
        function pool=addOnNamePool()
            persistent POOL
            if isempty(POOL)
                POOL=containers.Map();
            end
            pool=POOL;
        end
    end
end
