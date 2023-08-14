classdef FileExporter<handle





    methods
        function this=FileExporter()
        end

        this=registerFileExporter(this,className)
        this=createPendingExporters(this)
        exporter=getExporter(this,extension)

        this=setFileName(this,fileName)
        fileType=getFileType(this)

        this=exportToFile(this,runIDs,signalIDs,activeApp,eng,...
        fileName,overwrite,exportToFileOptions,bCmdLine)


        success=export(this,runIDs,signalIDs,activeApp,eng,...
        overwrite,exportToFileOptions,bCmdLine)


        function ret=supportsCancel(~)
            ret=false;
        end
    end


    properties(Access=private)
        PendingExporters={...
        'Simulink.sdi.internal.export.MATFileExporter',...
        'Simulink.sdi.internal.export.XLFileExporter',...
        'Simulink.sdi.internal.export.MLDATXFileExporter',...
'Simulink.sdi.internal.export.MP4FileExporter'
        };
        CreatedExporters=Simulink.sdi.Map;
    end
    properties(Access=public)
FileName
ProgressTracker
    end
end