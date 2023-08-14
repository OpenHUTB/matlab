classdef(Abstract,Hidden)OfficeController<handle
































    properties(Abstract,Constant)
Name
FileExtensions
    end

    properties(Access=private)
App
Docs
    end

    methods(Abstract,Static)
instance
    end

    methods(Abstract)
        tf=isAvailable(this)
    end

    methods(Abstract,Static,Access=protected)
        hApp=createApp()
        hDoc=createDoc(fullPath)
    end

    methods
        function hApp=start(this)

            hApp=this.App;
            if(isempty(hApp)||~isOpen(hApp))
                hApp=this.createApp();
                this.App=hApp;
            end
        end

        function out=show(this,varargin)

            out=setVisiblity(this,true,varargin{:});
        end

        function out=hide(this,varargin)

            out=setVisiblity(this,false,varargin{:});
        end

        function hDoc=load(this,fileName)

            start(this);

            key=getKeyFromFileName(this,fileName);
            if isKey(this.Docs,key)
                if~isOpen(this.Docs(key))
                    this.Docs(key)=this.createDoc(key);
                end
            else
                hDoc=this.createDoc(key);
                this.Docs(key)=hDoc;
            end

            hDoc=this.Docs(key);
        end

        function hDoc=open(this,fileName)

            hDoc=load(this,fileName);
            show(hDoc);
        end

        function tf=close(this,varargin)

            closeFlag=true;
            if isempty(varargin)
                tf=closeApp(this,closeFlag);
            else
                n=numel(varargin);
                arg1=varargin{1};
                if(islogical(arg1)||isnumeric(arg1))
                    closeFlag=arg1;
                    tf=closeApp(this,closeFlag);
                else
                    fileName=arg1;
                    if(n>1)
                        closeFlag=varargin{2};
                    end
                    tf=closeDoc(this,fileName,closeFlag);
                end
            end
        end

        function tf=closeAll(this,varargin)

            if isempty(varargin)
                closeFlag=true;
            else
                closeFlag=varargin{1};
            end

            tf=true;
            fNames=this.Docs.keys();
            n=numel(fNames);
            for i=1:n
                hDoc=this.Docs(fNames{i});
                if isOpen(hDoc)
                    tf=tf&close(hDoc,closeFlag);
                else

                end
            end
        end

        function tf=closeApp(this,closeFlag)

            tf=false;

            if(~isStarted(this)&&~closeFlag)

                start(this);
            end

            if isStarted(this)
                hApp=this.App;
                if close(hApp,closeFlag)
                    this.App=[];
                    this.Docs=containers.Map();
                    tf=true;
                end
            else

                tf=true;
                this.App=[];
                this.Docs=containers.Map();
            end
        end

        function tf=closeDoc(this,fileName,closeFlag)

            key=getKeyFromFileName(this,fileName);
            if isKey(this.Docs,key)
                hDoc=this.Docs(key);
                tf=close(hDoc,closeFlag);
            else
                error(message("mlreportgen:utils:error:fileNotOpen",key));
            end
        end

        function out=filenames(this)


            if isStarted(this)
                docKeys=string(this.Docs.keys());
                nDocKeys=numel(docKeys);

                isFileOpened=true(1,nDocKeys);
                for i=1:nDocKeys
                    key=docKeys(i);
                    isFileOpened(i)=isOpen(this.Docs(key));
                end

                out=docKeys(isFileOpened);
            else
                this.Docs=containers.Map();
                out=string.empty();
            end
        end

        function tf=isStarted(this)

            if~isempty(this.App)&&isOpen(this.App)
                tf=true;
            else
                tf=false;
                this.App=[];
            end
        end

        function tf=isLoaded(this,fileName)

            key=getKeyFromFileName(this,fileName);
            tf=isKey(this.Docs,key)&&isOpen(this.Docs(key));
        end

        function hApp=app(this)

            if this.isStarted()
                hApp=this.App;
            else
                error(message("mlreportgen:utils:error:appNotStarted",this.Name));
            end
        end

        function hDoc=doc(this,fileName)

            key=getKeyFromFileName(this,fileName);
            if isKey(this.Docs,key)
                hDoc=this.Docs(key);
                if~isOpen(hDoc)
                    remove(this.Docs,key);
                    error(message("mlreportgen:utils:error:fileNotOpen",fileName));
                end
            else
                error(message("mlreportgen:utils:error:fileNotOpen",fileName));
            end
        end
    end

    methods(Access=protected)
        function this=OfficeController()
            this.Docs=containers.Map();
        end
    end

    methods(Access=?mlreportgen.utils.internal.OfficeDoc)
        function registerDoc(this,hDoc)
            key=this.getKey(hDoc.FileName);
            this.Docs(key)=hDoc;
        end

        function unregisterDoc(this,hDoc)
            key=this.getKey(hDoc.FileName);
            if(~isempty(key)&&~isempty(this.Docs)&&isKey(this.Docs,key))
                remove(this.Docs,key);
            end
        end
    end

    methods(Static,Access=private)
        function key=getKey(fullPath)
            key=char(fullPath);
        end
    end

    methods(Access=private)
        function key=getKeyFromFileName(this,fileName)
            fullPath=mlreportgen.utils.findFile(...
            fileName,...
            "FileExtensions",this.FileExtensions,...
            "FileMustExist",false);
            key=this.getKey(fullPath);
        end

        function out=setVisiblity(this,visibleFlag,varargin)
            hApp=app(this);
            if isempty(varargin)
                if visibleFlag
                    show(hApp);
                else
                    hide(hApp);
                end
                out=hApp;
            else
                fileName=varargin{1};
                fullPath=mlreportgen.utils.findFile(...
                fileName,...
                "FileExtensions",this.FileExtensions);
                key=this.getKey(fullPath);
                if isKey(this.Docs,key)
                    hDoc=this.Docs(key);
                    if visibleFlag
                        show(hDoc);
                    else
                        hide(hDoc);
                    end
                    out=hDoc;
                else
                    error(message("mlreportgen:utils:error:fileNotOpen",fullPath));
                end
            end
        end
    end
end
