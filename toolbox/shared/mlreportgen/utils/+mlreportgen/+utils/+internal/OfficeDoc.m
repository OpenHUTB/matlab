classdef(Abstract,Hidden)OfficeDoc<handle





























    properties(SetAccess=private)
        FileName=string.empty();
    end

    properties(Hidden,Constant,Abstract)
FileExtensions
    end

    properties(Access=private)
        NETObj=[];
        MaxRetries=5;
    end

    methods(Abstract)
        show(this)
        hide(this)
        close(this,varargin)
        tf=isReadOnly(this)
        tf=isSaved(this)
        tf=isVisible(this)
        pdfFullPath=exportToPDF(this,varargin)
    end

    methods(Abstract,Static,Hidden,Access=protected)
        hNETObj=createNETObj()
        flushNETObj(hNETObj);
        hController=controller()
    end

    methods
        function this=OfficeDoc(fileName)
            if~ispc()
                error(message("mlreportgen:utils:error:supportedOnlyOnWindows"));
            end

            fullFilePath=mlreportgen.utils.findFile(...
            fileName,...
            "FileExtensions",this.FileExtensions);
            if isempty(fullFilePath)
                error(message("mlreportgen:utils:error:fileNotFound",fileName));
            end
            [~,~,fExt]=fileparts(fullFilePath);
            if~ismember(fExt,this.FileExtensions)
                error(message("mlreportgen:utils:error:unexpectedFileType",...
                fileName,strjoin(this.FileExtensions," ")));
            end
            this.FileName=fullFilePath;


            hController=this.controller();
            if isLoaded(hController,this.FileName)
                hDoc=doc(hController,this.FileName);
                if isOpen(hDoc)
                    error(message("mlreportgen:utils:error:fileAlreadyOpened",this.FileName));
                end
            end


            this.NETObj=this.createNETObj(fullFilePath);
            registerDoc(hController,this);
        end

        function delete(this)



            try
                if~isempty(this.NETObj)
                    close(this);
                end
            catch
            end
        end

        function save(this)



            hNETObj=netobj(this);
            executeWithRetries(this,@()hNETObj.Save());
        end

        function print(this)



            hNETObj=netobj(this);
            if~isVisible(this)
                show(this);
                scopeHide=onCleanup(@()hide(this));
            end
            executeWithRetries(this,@()hNETObj.PrintOut());
        end

        function tf=isOpen(this)




            if~isempty(this.NETObj)
                try
                    this.NETObj.FullName;
                    tf=true;
                catch ME
                    errmsg=lower(ME.message);
                    if(contains(errmsg,"0x80010001")||contains(errmsg,"RPC_E_CALL_REJECTED"))


                        tf=true;
                    else



                        tf=false;
                        clearNETObj(this);
                    end
                end
            else
                tf=false;
            end
        end

        function flush(this,varargin)
            if isOpen(this)
                try
                    hNETObj=netobj(this);

                    if~isempty(varargin)
                        visibleFlush=varargin{1};
                    else
                        visibleFlush=true;
                    end

                    if visibleFlush
                        executeWithRetries(this,@()this.flushNETObj(hNETObj));
                    else
                        mlreportgen.utils.internal.executeRPC(@()this.flushNETObj(hNETObj));
                    end

                catch ME
                    errmsg=lower(ME.message);
                    if~(contains(errmsg,"RPC_E_DISCONNECTED")||contains(errmsg,"0x80010108"))
                        rethrow(ME);
                    end
                end
            end
        end
    end

    methods(Sealed)
        function hNETObj=netobj(this)




            if~isOpen(this)
                hController=this.controller();
                error(message("mlreportgen:utils:error:appClosed",hController.Name));
            else
                hNETObj=this.NETObj;
            end
        end
    end

    methods(Access=protected)
        function resetNETObj(this,netObj)
            this.NETObj=netObj;
        end

        function clearNETObj(this)
            this.NETObj=[];
            hController=this.controller();
            unregisterDoc(hController,this);

            System.GC.Collect();
            System.GC.WaitForPendingFinalizers();
            System.GC.Collect();
            System.GC.WaitForPendingFinalizers();
        end

        function varargout=executeWithRetries(this,fcn,varargin)
            if(nargout>0)
                [varargout{1:nargout}]=...
                mlreportgen.utils.internal.executeRPC(fcn,"RetryPreFcn",@()show(this));
            else
                mlreportgen.utils.internal.executeRPC(fcn);
            end
        end
    end
end
