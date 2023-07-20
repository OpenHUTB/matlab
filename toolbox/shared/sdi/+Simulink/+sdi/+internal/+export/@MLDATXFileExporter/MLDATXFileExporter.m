classdef MLDATXFileExporter<Simulink.sdi.internal.export.FileExporter





    methods

        function success=export(this,runIDs,~,~,~,~,~,bCmdLine)
            success=true;
            try
                Simulink.sdi.saveRuns(this.FileName,bCmdLine,int32(runIDs));
            catch me
                success=false;
                errorStr=me.message;
                error(errorStr);
                return;
            end
        end


        function fileType=getFileType(this)
            fileType=this.FileType;
        end


        function this=setFileName(this,fileName)
            this.FileName=fileName;
        end
    end


    properties(Access=private)
        FileType='.mldatx';
    end
end