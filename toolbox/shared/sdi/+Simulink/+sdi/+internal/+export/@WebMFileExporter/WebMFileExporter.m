classdef WebMFileExporter<Simulink.sdi.internal.export.FileExporter





    methods

        function success=export(this,runIDs,signalIDs,~,eng,~,...
            exportToFileOptions,bCmdLine)
            success=false;
            if length(signalIDs)~=1
                locDisplayError(message('SDI:sdi:ExportVideoSingleSignalError'),bCmdLine);
                return;
            end

            path=sdi.PluggableStorage.getSignalStoragePath(signalIDs);
            [filepath,name,ext]=fileparts(path);
            isVideo=strcmp(ext,this.FileType);

            if isempty(path)||~isVideo||exist(path)==0
                locDisplayError(message('SDI:sdi:ExportVideoIncorrectSignalError'),bCmdLine);
                return;
            end

            ok=copyfile(path,this.FileName);
            if~ok
                locDisplayError(message('SDI:sdi:ExportVideoCopyFailureError'),bCmdLine);
                return;
            end
            success=true;
        end


        function fileType=getFileType(this)
            fileType=this.FileType;
        end


        function this=setFileName(this,fileName)
            this.FileName=fileName;
        end
    end


    properties(Access=private)
        FileType='.webm';
    end
end


function locDisplayError(msgStr,bCmdLine)
    if bCmdLine
        error(msgStr);
    else
        titleStr=getString(message('SDI:sdi:ExportError'));
        okStr=getString(message('SDI:sdi:OKShortcut'));
        Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
        'default',...
        titleStr,...
        msgStr,...
        {okStr},...
        0,...
        -1,...
        []);
    end
end
