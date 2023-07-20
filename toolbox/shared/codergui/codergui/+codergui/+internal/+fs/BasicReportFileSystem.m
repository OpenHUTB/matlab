classdef BasicReportFileSystem<codergui.internal.fs.ReportFileSystem




    properties(Dependent,SetAccess=private,GetAccess=public)
Writable
    end

    methods(Access={?codergui.internal.fs.ReportFileSystem})
        function this=BasicReportFileSystem(reportFile)
            this=this@codergui.internal.fs.ReportFileSystem(reportFile);
        end
    end

    methods(Access=protected)
        function data=loadRelativeMatFile(this,relPath,varName)
            if~isempty(varName)
                varArg={varName};
            else
                varArg={};
            end
            data=load(fullfile(fileparts(this.ReportFile),relPath),varArg{:});
        end

        function text=readRelativeTextFile(this,relPath,encoding)
            text=this.doReadTextFile(fullfile(fileparts(this.ReportFile),relPath),encoding);
        end

        function exists=relativeFileExists(this,relPath)
            file=fullfile(fileparts(this.ReportFile),relPath);
            exists=exist(file,'file')||exist(file,'dir');
        end
    end

    methods
        function ioService=createFileIoService(this,defaultEncoding,requestChannel,replyChannel)
            ioService=codergui.internal.fs.ReportFileIoService(this,requestChannel,replyChannel);
            ioService.DefaultEncoding=defaultEncoding;
            ioService.WorkingDirectory=fileparts(this.ReportFile);
        end

        function writable=get.Writable(this)
            writable=codergui.internal.util.isWritable(fileparts(this.ReportFile));
        end

        function addFile(this,fileName,srcFilePath)
            assert(codergui.internal.util.isAbsolute(srcFilePath)&&...
            ~codergui.internal.util.isAbsolute(fileName));
            copyfile(srcFilePath,fullfile(fileparts(this.ReportFile),fileName));
        end
    end
end