classdef(Sealed)VirtualReportFileSystem<codergui.internal.fs.ReportFileSystem




    properties(SetAccess=immutable)
VirtualReport
    end

    properties(SetAccess=private,GetAccess=public)
        Writable=false
    end

    methods(Access={?codergui.internal.fs.ReportFileSystem})
        function this=VirtualReportFileSystem(virtualReport)
            this=this@codergui.internal.fs.ReportFileSystem('');
            this.VirtualReport=virtualReport;
        end
    end

    methods(Access=protected)
        function data=loadRelativeMatFile(this,relPath,varName)
            data=this.VirtualReport.getMatlabContent(relPath);
            if~isempty(varName)&&~isfield(data,varName)
                data=[];
            end
        end

        function text=readRelativeTextFile(this,relPath,~)
            text=this.VirtualReport.getPartitionContent(relPath);
        end

        function exists=relativeFileExists(this,relPath)
            exists=this.VirtualReport.hasPartitionContent(relPath)||...
            this.VirtualReport.hasMatlabContent(relPath);
        end
    end

    methods
        function ioService=createFileIoService(this,defaultEncoding,requestChannel,replyChannel)
            ioService=codergui.internal.fs.VirtualReportFileIoService(...
            this,requestChannel,replyChannel);
            ioService.DefaultEncoding=defaultEncoding;
        end

        function addFile(~,~,~)
        end
    end
end