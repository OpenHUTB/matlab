


classdef(Abstract)RTEProxyFileGeneratorBase<handle
    properties(GetAccess=protected)
Model
CodeDesc
FileType
Writer
Service
    end

    properties(Constant,GetAccess=public)


        HeaderFilename='_timer_proxy.h';
        SourceFilename='_timer_proxy.c';
    end

    methods(Abstract)


        writeSections(this)
    end

    methods(Access=public)
        function build(this)
            if~isempty(this.Writer)
                this.displayProgressInfo;
                this.writeSections;
            end
        end
    end

    methods(Access=protected)

        function this=RTEProxyFileGeneratorBase(model,fileType)


            filePath=coder.internal.rteproxy.RTEProxyFileGeneratorBase.getFilePath(model,fileType);
            fileName=coder.internal.rteproxy.RTEProxyFileGeneratorBase.getFileName(model,fileType);
            codeDesc=coder.getCodeDescriptor(filePath);

            fileFullName=fullfile(filePath,fileName);
            needGenFile=coder.internal.rteproxy.RTEProxyFileGeneratorBase.getNeedGenerateFile(...
            fileFullName,fileType,codeDesc);

            if needGenFile
                this.Model=model;
                this.FileType=fileType;
                this.CodeDesc=codeDesc;
                this.Writer=rtw.connectivity.CodeWriter.create(...
                'language',get_param(model,'TargetLang'),...
                'callCBeautifier',true,...
                'filename',fileFullName,...
                'append',false);
                this.Service=coder.internal.rteproxy.TimerServiceProxyContentWriter(...
                this.Writer,this.CodeDesc);
            else
                this.Model=[];
                this.FileType=[];
                this.CodeDesc=[];
                this.Writer=[];
                this.Service=[];
            end
        end
    end

    methods(Access=private)

        function displayProgressInfo(this)
            if get_param(this.Model,'RTWVerbose')

                if this.FileType==coder.internal.rteproxy.RTEProxyFileType.SubassemblyHeader
                    fileTypeStr='header';
                else
                    fileTypeStr='source';
                end


                fprintf('%s### Writing %s file %s\n',...
                coder.internal.rteproxy.RTEProxyFileGeneratorBase.getIndentation,...
                fileTypeStr,...
                coder.internal.rteproxy.RTEProxyFileGeneratorBase.getFileName(this.Model,this.FileType));
            end
        end

    end

    methods(Static,Access=private)

        function needGenFile=getNeedGenerateFile(fileName,fileType,codeDesc)

            needGenFile=false;


            if exist(fileName,'file')||...
                isempty(codeDesc.getFullComponentInterface)||...
                isempty(codeDesc.getFullComponentInterface.PlatformServices)||...
                isempty(codeDesc.getFullComponentInterface.PlatformServices.TimerService)
                return;
            end

            interface=codeDesc.getFullComponentInterface.PlatformServices.TimerService;
            switch fileType
            case coder.internal.rteproxy.RTEProxyFileType.SubassemblyHeader

                needGenFile=(interface.TimerFunctions.Size>0);

            case coder.internal.rteproxy.RTEProxyFileType.SubassemblySource


                needGenFile=(interface.ServiceRequiredSubassemblyList.Size>0);
            end
        end
    end

    methods(Static,Access=public)


        function indentStr=getIndentation(idx)
            if nargin==0
                idx=1;
            end
            indentStr=repmat('    ',1,idx);
        end


        function folder=getFilePath(model,fileType)
            buildDirs=RTW.getBuildDir(model);
            switch fileType
            case coder.internal.rteproxy.RTEProxyFileType.SubassemblyHeader
                folder=fullfile(buildDirs.CodeGenFolder,buildDirs.ModelRefRelativeBuildDir);
            case coder.internal.rteproxy.RTEProxyFileType.SubassemblySource
                folder=fullfile(buildDirs.CodeGenFolder,buildDirs.RelativeBuildDir);
            end
        end


        function fileName=getFileName(model,fileType)
            switch fileType
            case coder.internal.rteproxy.RTEProxyFileType.SubassemblyHeader
                fileName=[model,coder.internal.rteproxy.RTEProxyFileGeneratorBase.HeaderFilename];
            case coder.internal.rteproxy.RTEProxyFileType.SubassemblySource
                fileName=[model,coder.internal.rteproxy.RTEProxyFileGeneratorBase.SourceFilename];
            end
        end

    end
end


